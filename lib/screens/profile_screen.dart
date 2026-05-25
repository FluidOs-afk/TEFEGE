import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../models/user_post.dart';
import '../services/posts_service.dart';
import '../services/profile_service.dart';
import '../services/users_service.dart';
import '../widgets/fashion_icon.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional: if null, show current user's profile

  const ProfileScreen({super.key, this.userId});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfile _profile;
  late User? _otherUserProfile;
  bool _isOwnProfile = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isOwnProfile = widget.userId == null;

    if (_isOwnProfile) {
      _profile = ProfileService.instance.profile;
      _otherUserProfile = null;
      ProfileService.instance.addListener(_onProfileChanged);
      ProfileService.instance.load();
    } else {
      _otherUserProfile = UsersService.instance.getUser(widget.userId!);
      ProfileService.instance.load();
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    PostsService.instance.addListener(_onPostsChanged);
    UsersService.instance.addListener(_onFollowingChanged);
  }

  void _onProfileChanged() {
    if (mounted) setState(() => _profile = ProfileService.instance.profile);
  }

  void _onPostsChanged() {
    if (mounted) setState(() {});
  }

  void _onFollowingChanged() {
    if (mounted && !_isOwnProfile) setState(() {});
  }

  @override
  void dispose() {
    if (_isOwnProfile) {
      ProfileService.instance.removeListener(_onProfileChanged);
    }
    PostsService.instance.removeListener(_onPostsChanged);
    UsersService.instance.removeListener(_onFollowingChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openEditProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()));
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _toggleFollow() {
    if (!_isOwnProfile && _otherUserProfile != null) {
      if (UsersService.instance.isFollowing(widget.userId!)) {
        UsersService.instance.unfollowUser(widget.userId!);
      } else {
        UsersService.instance.followUser(widget.userId!);
      }
    }
  }

  void _openChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  void _openCreatePost() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
  }

  void _confirmDelete(UserPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar publicación',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Eliminar "${post.title}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.dmSans(color: AppColors.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.dmSans(color: AppColors.textSec),
            ),
          ),
          TextButton(
            onPressed: () {
              PostsService.instance.remove(post.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Eliminar',
              style: GoogleFonts.dmSans(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: _isOwnProfile && _selectedTab == 0
          ? FloatingActionButton(
              onPressed: _openCreatePost,
              tooltip: 'Nueva publicación',
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ─── Collapsible AppBar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 310,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.bgCard,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              if (_isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: _openSettings,
                ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (ctx, constraints) {
                final percent = (constraints.maxHeight - kToolbarHeight) / 240;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryMed,
                            AppColors.primaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Opacity(
                        opacity: percent.clamp(0.0, 1.0),
                        child: _buildHeaderCard(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ─── Cambiar contraseña ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildChangePasswordTile(),
            ),
          ),

          // ─── Tab bar ──────────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on_rounded)),
                  Tab(icon: Icon(Icons.checkroom_rounded)),
                  Tab(icon: Icon(Icons.bookmark_border_rounded)),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_postsTab(), _grid(), _grid()],
        ),
      ),
    );
  }

  // ─── Header card ──────────────────────────────────────────────────────────────
  Widget _buildHeaderCard() {
    // Determina qué perfil mostrar
    final displayProfile = _isOwnProfile ? _profile : _otherUserProfile;
    if (displayProfile == null && !_isOwnProfile) {
      return const SizedBox.shrink();
    }

    final postCount = _isOwnProfile
        ? PostsService.instance.count
        : PostsService.instance.posts
              .where((post) => post.userId == widget.userId)
              .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar - Clickeable para perfil del usuario
              GestureDetector(
                onTap: !_isOwnProfile
                    ? () => Navigator.of(context).pop()
                    : null,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _isOwnProfile
                          ? _profile.initials
                          : (_otherUserProfile?.username
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                'U'),
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Botones: Editar para propio perfil, Seguir para otros
              if (_isOwnProfile) ...[
                IconButton.filled(
                  onPressed: _openCreatePost,
                  tooltip: 'Nueva publicación',
                  icon: const Icon(Icons.add_a_photo_outlined, size: 20),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _openEditProfile,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Editar perfil',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ] else ...[
                FilledButton(
                  onPressed: _toggleFollow,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        UsersService.instance.isFollowing(widget.userId!)
                        ? AppColors.bgCard
                        : AppColors.primary,
                    foregroundColor:
                        UsersService.instance.isFollowing(widget.userId!)
                        ? AppColors.primary
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: UsersService.instance.isFollowing(widget.userId!)
                          ? const BorderSide(color: AppColors.primary)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    UsersService.instance.isFollowing(widget.userId!)
                        ? 'Siguiendo'
                        : 'Seguir',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Nombre y usuario - Clickeables para ir a su perfil
          GestureDetector(
            onTap: !_isOwnProfile && _otherUserProfile != null
                ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfileScreen(userId: _otherUserProfile!.userId),
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOwnProfile
                      ? _profile.displayName
                      : (_otherUserProfile?.username ?? 'Usuario'),
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isOwnProfile
                      ? '@${_profile.username}'
                      : '@${_otherUserProfile?.username ?? 'usuario'}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSec,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if ((_isOwnProfile
                  ? _profile.location
                  : _otherUserProfile?.location ?? '')
              .isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 3),
                Text(
                  _isOwnProfile
                      ? _profile.location
                      : (_otherUserProfile?.location ?? ''),
                  style: GoogleFonts.dmSans(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if ((_isOwnProfile ? _profile.bio : _otherUserProfile?.bio ?? '')
              .isNotEmpty)
            Text(
              _isOwnProfile ? _profile.bio : (_otherUserProfile?.bio ?? ''),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSec,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _stat('$postCount', 'Posts')),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(
                child: _stat(
                  _isOwnProfile
                      ? '1.2K'
                      : '${_otherUserProfile?.followersCount ?? 0}',
                  'Seguidores',
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(
                child: _stat(
                  _isOwnProfile
                      ? '348'
                      : '${_otherUserProfile?.followingCount ?? 0}',
                  'Siguiendo',
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(child: _stat('48', 'Prendas')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textHint),
        ),
      ],
    );
  }

  // ─── Cambiar contraseña tile ──────────────────────────────────────────────────
  Widget _buildChangePasswordTile() {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _openChangePassword,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: Color(0xFF26A69A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cambiar contraseña',
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text('Actualiza tu contraseña de acceso',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.5, color: AppColors.textHint)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Posts tab ────────────────────────────────────────────────────────────────
  Widget _postsTab() {
    final posts = PostsService.instance.posts;
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.grid_off_rounded,
              size: 52,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 14),
            Text(
              'Sin publicaciones',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pulsa + para crear tu primera publicación',
              style: GoogleFonts.dmSans(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _openCreatePost,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nueva publicación'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (_, i) => _postCell(posts[i]),
    );
  }

  void _openPost(UserPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
    );
  }

  Widget _postCell(UserPost post) {
    final hasPhoto =
        post.imagePath != null && File(post.imagePath!).existsSync();

    return GestureDetector(
      onTap: () => _openPost(post),
      onLongPress: _isOwnProfile ? () => _confirmDelete(post) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo: foto real o gradiente
          if (hasPhoto)
            Image.file(File(post.imagePath!), fit: BoxFit.cover)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: post.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: FashionIcon(
                      category: post.category,
                      color: Colors.white.withValues(alpha: 0.1),
                      size: 64,
                      strokeWidth: 1.5,
                    ),
                  ),
                  Center(
                    child: FashionIcon(
                      category: post.category,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 30,
                      strokeWidth: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          // Título superpuesto
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                post.title,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Placeholder grid (tabs 2 y 3) ───────────────────────────────────────────
  static const _gridGradients = [
    [Color(0xFF1B6B44), Color(0xFF3CB87A)],
    [Color(0xFF37474F), Color(0xFF78909C)],
    [Color(0xFF4A1275), Color(0xFF9C27B0)],
    [Color(0xFF5D3A2A), Color(0xFF8D6E63)],
    [Color(0xFF1A5E38), Color(0xFF4CAF50)],
    [Color(0xFF263238), Color(0xFF607D8B)],
  ];

  static const _gridCats = [
    FashionCategory.tops,
    FashionCategory.coat,
    FashionCategory.dress,
    FashionCategory.shoes,
    FashionCategory.pants,
    FashionCategory.accessory,
  ];

  Widget _grid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 30,
      itemBuilder: (_, i) {
        final colors = _gridGradients[i % _gridGradients.length];
        final cat = _gridCats[i % _gridCats.length];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: FashionIcon(
                  category: cat,
                  color: Colors.white.withValues(alpha: 0.08),
                  size: 64,
                  strokeWidth: 1.5,
                ),
              ),
              Center(
                child: FashionIcon(
                  category: cat,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 30,
                  strokeWidth: 1.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tab bar delegate ─────────────────────────────────────────────────────────
class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.bgCard, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabDelegate old) => false;
}
