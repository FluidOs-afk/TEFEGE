import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../services/users_service.dart';
import '../services/profile_service.dart';
import 'profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  late TextEditingController _searchController;
  List<User> _searchResults = [];
  bool _hasSearched = false;
  final String _currentUserId = ProfileService.instance.profile.userId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _hasSearched = false;
        _searchResults = [];
      } else {
        _hasSearched = true;
        _searchResults = UsersService.instance.searchUsers(
          _searchController.text,
          _currentUserId,
        );
      }
    });
  }

  void _openUserProfile(String userId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Buscar usuarios',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Busca por nombre o usuario...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.textHint),
                prefixIcon: const Icon(
                  Icons.search_outlined,
                  color: AppColors.textHint,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_outlined,
                          color: AppColors.textHint,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.bgCard,
              ),
              style: GoogleFonts.dmSans(color: AppColors.textPrimary),
            ),
          ),
          // Resultados
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Busca usuarios por nombre o usuario',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Encuentra gente interesante para seguir',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'No se encontraron usuarios',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final user = _searchResults[index];
        final isFollowing = UsersService.instance.isFollowing(user.userId);

        return GestureDetector(
          onTap: () => _openUserProfile(user.userId),
          child: Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF8E44AD),
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nombre y usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.followersCount} seguidores',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textSec,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Botón Follow/Unfollow
                SizedBox(
                  width: 90,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isFollowing) {
                        UsersService.instance.unfollowUser(user.userId);
                      } else {
                        UsersService.instance.followUser(user.userId);
                      }
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? AppColors.bgPage
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: isFollowing
                            ? const BorderSide(color: AppColors.border)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      isFollowing ? 'Siguiendo' : 'Seguir',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: isFollowing
                            ? AppColors.textPrimary
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
