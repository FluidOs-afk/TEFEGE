import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../services/users_service.dart';
import '../utils/image_utils.dart';
import 'profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});
  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<UserModel> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final q = _ctrl.text.trim();
    if (q.isEmpty) {
      setState(() { _results = []; _searched = false; _loading = false; });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

  Future<void> _search(String q) async {
    final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';
    try {
      final results = await UsersService.instance.searchByUsername(q);
      if (mounted) {
        setState(() {
          _results = results.where((u) => u.uid != currentUid).toList();
          _searched = true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Buscar usuarios',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            style: GoogleFonts.dmSans(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Busca por nombre de usuario...',
              hintStyle: GoogleFonts.dmSans(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear_rounded, color: AppColors.textHint, size: 18),
                      onPressed: () => _ctrl.clear())
                  : null,
              filled: true, fillColor: AppColors.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : !_searched
                  ? _emptyState(icon: Icons.people_outline_rounded,
                      title: 'Busca a alguien',
                      subtitle: 'Escribe el nombre de usuario para encontrar gente')
                  : _results.isEmpty
                      ? _emptyState(icon: Icons.search_off_rounded,
                          title: 'Sin resultados',
                          subtitle: 'No encontramos usuarios con ese nombre')
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _results.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, i) => _UserTile(
                            user: _results[i],
                            currentUid: currentUser?.uid ?? '',
                            isFollowing: currentUser?.following.contains(_results[i].uid) ?? false,
                            onFollowChanged: () async {
                              final uid = currentUser?.uid ?? '';
                              if (uid.isEmpty) return;
                              final target = _results[i].uid;
                              final following = currentUser?.following.contains(target) ?? false;
                              if (following) {
                                await ProfileService.instance.unfollow(uid, target);
                              } else {
                                await ProfileService.instance.follow(uid, target);
                              }
                              if (context.mounted) {
                                await context.read<AuthProvider>().refreshCurrentUser();
                              }
                            },
                          ),
                        ),
        ),
      ]),
    );
  }

  Widget _emptyState({required IconData icon, required String title, required String subtitle}) =>
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 56, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textHint)),
      ]));
}

class _UserTile extends StatefulWidget {
  final UserModel user;
  final String currentUid;
  final bool isFollowing;
  final Future<void> Function() onFollowChanged;
  const _UserTile({required this.user, required this.currentUid, required this.isFollowing, required this.onFollowChanged});
  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.user.uid))),
      child: Container(
        color: AppColors.bgCard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.user.nombre,
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('@${widget.user.username}', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint)),
            if (widget.user.bio.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(widget.user.bio, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSec),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ])),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: _loading
                ? const Center(child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);
                      await widget.onFollowChanged();
                      if (mounted) setState(() => _loading = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isFollowing ? AppColors.bgPage : AppColors.primary,
                      foregroundColor: widget.isFollowing ? AppColors.textPrimary : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
                          side: widget.isFollowing ? const BorderSide(color: AppColors.border) : BorderSide.none),
                      elevation: 0,
                    ),
                    child: Text(widget.isFollowing ? 'Siguiendo' : 'Seguir',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAvatar() {
    const size = 52.0;
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle,
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
      padding: const EdgeInsets.all(2),
      child: ClipOval(child: widget.user.avatarBase64.isNotEmpty
          ? ImageUtils.imageFromBase64(widget.user.avatarBase64, placeholder: _fallback())
          : _fallback()),
    );
  }

  Widget _fallback() => CircleAvatar(
    backgroundColor: AppColors.primaryMed,
    child: Text(widget.user.nombre.isNotEmpty ? widget.user.nombre[0].toUpperCase() : '?',
        style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
  );
}
