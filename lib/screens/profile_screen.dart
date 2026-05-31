import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../utils/image_utils.dart';
import 'create_post_screen.dart';
import 'edit_profile_screen.dart';
import 'follow_requests_screen.dart';
import 'followers_screen.dart';
import 'post_detail_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Stream<UserModel>? _stream;
  String _targetUid = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    final currentUid = auth.currentUser?.uid ?? '';
    final newTarget = widget.userId ?? currentUid;
    if (newTarget != _targetUid && newTarget.isNotEmpty) {
      _targetUid = newTarget;
      _stream = ProfileService.instance.streamUser(_targetUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.currentUser?.uid ?? '';
    final targetUid = widget.userId ?? currentUid;
    final isOwn = targetUid == currentUid;

    if (_targetUid.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return StreamBuilder<UserModel>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bgPage,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.bgPage,
            body: Center(child: Text('Usuario no encontrado')),
          );
        }
        return _ProfileBody(user: snap.data!, currentUid: currentUid, isOwn: isOwn);
      },
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final UserModel user;
  final String currentUid;
  final bool isOwn;
  const _ProfileBody({required this.user, required this.currentUid, required this.isOwn});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  bool _followLoading = false;

  bool get _isFollowing => widget.user.followers.contains(widget.currentUid);
  bool get _isPending => widget.user.pendingRequests.contains(widget.currentUid);

  Future<void> _toggleFollow() async {
    if (_followLoading) return;
    setState(() => _followLoading = true);
    try {
      if (_isFollowing) {
        await ProfileService.instance.unfollow(widget.currentUid, widget.user.uid);
      } else if (widget.user.isPrivate) {
        if (_isPending) {
          await ProfileService.instance.cancelFollowRequest(widget.currentUid, widget.user.uid);
        } else {
          await ProfileService.instance.sendFollowRequest(widget.currentUid, widget.user.uid);
        }
      } else {
        // Perfil público: si hay una solicitud residual la cancelamos antes de seguir
        if (_isPending) {
          await ProfileService.instance.cancelFollowRequest(widget.currentUid, widget.user.uid);
        }
        await ProfileService.instance.follow(widget.currentUid, widget.user.uid);
      }
      if (mounted) {
        await context.read<AuthProvider>().refreshCurrentUser();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ha ocurrido un error. Inténtalo de nuevo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrivateAndNotFollowing =
        !widget.isOwn && widget.user.isPrivate && !_isFollowing;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: widget.isOwn
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreatePostScreen())),
              tooltip: 'Nueva publicación',
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.bgCard,
            automaticallyImplyLeading: !widget.isOwn,
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              if (widget.isOwn)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (ctx, constraints) {
                final pct = ((constraints.maxHeight - kToolbarHeight) / 220).clamp(0.0, 1.0);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryMed, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16, right: 16, bottom: 16,
                      child: Opacity(
                        opacity: pct,
                        child: _buildHeaderCard(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        body: isPrivateAndNotFollowing ? _buildPrivateState() : _buildPostsGrid(),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(widget.user),
              const Spacer(),
              if (widget.isOwn)
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  child: Text('Editar perfil', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                )
              else
                _followLoading
                    ? const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : FilledButton(
                        onPressed: _toggleFollow,
                        style: FilledButton.styleFrom(
                          backgroundColor: _isFollowing || (widget.user.isPrivate && _isPending) ? AppColors.bgCard : AppColors.primary,
                          foregroundColor: _isFollowing || (widget.user.isPrivate && _isPending) ? AppColors.primary : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: _isFollowing || (widget.user.isPrivate && _isPending)
                                ? const BorderSide(color: AppColors.primary)
                                : BorderSide.none,
                          ),
                        ),
                        child: Text(
                            _isFollowing ? 'Siguiendo' : (widget.user.isPrivate && _isPending ? 'Solicitado' : 'Seguir'),
                            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                      ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.user.nombre,
              style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('@${widget.user.username}',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSec)),
          if (widget.user.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(widget.user.bio,
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSec, height: 1.5)),
          ],
          if (widget.isOwn && widget.user.pendingRequests.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FollowRequestsScreen(owner: widget.user))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.person_add_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.user.pendingRequests.length} solicitud${widget.user.pendingRequests.length == 1 ? '' : 'es'} de seguimiento',
                    style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildStatStream(widget.user.uid)),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FollowersScreen(
                            title: 'Seguidores',
                            uids: widget.user.followers,
                            currentUid: widget.currentUid,
                          ))),
                  child: _stat('${widget.user.followers.length}', 'Seguidores'),
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FollowersScreen(
                            title: 'Siguiendo',
                            uids: widget.user.following,
                            currentUid: widget.currentUid,
                          ))),
                  child: _stat('${widget.user.following.length}', 'Siguiendo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatStream(String uid) {
    return StreamBuilder<AggregateQuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts').where('userId', isEqualTo: uid).snapshots()
          .asyncMap((_) => FirebaseFirestore.instance
              .collection('posts').where('userId', isEqualTo: uid).count().get()),
      builder: (ctx, snap) => _stat('${snap.data?.count ?? 0}', 'Posts'),
    );
  }

  Widget _stat(String value, String label) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(value, style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
      const SizedBox(height: 1),
      Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textHint)),
    ],
  );

  Widget _buildAvatar(UserModel user) {
    const size = 72.0;
    if (user.avatarBase64.isNotEmpty) {
      return ClipOval(child: SizedBox(width: size, height: size,
          child: ImageUtils.imageFromBase64(user.avatarBase64)));
    }
    return _avatarFallback(user, size);
  }

  Widget _avatarFallback(UserModel user, double size) => Container(
    width: size, height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
    ),
    child: Center(child: Text(user.initials,
        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
  );

  Widget _buildPrivateState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _isPending ? Icons.schedule_rounded : Icons.lock_outline_rounded,
          size: 52,
          color: AppColors.textHint,
        ),
        const SizedBox(height: 14),
        Text('Esta cuenta es privada',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(
          _isPending
              ? 'Tu solicitud está pendiente de aprobación'
              : 'Sigue a este usuario para ver sus publicaciones',
          style: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildPostsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts').where('userId', isEqualTo: widget.user.uid)
          .orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final posts = (snap.data?.docs ?? []).map((d) => PostModel.fromFirestore(d)).toList();
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.grid_off_rounded, size: 52, color: AppColors.textHint),
                const SizedBox(height: 14),
                Text('Sin publicaciones',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                  widget.isOwn ? 'Pulsa + para crear tu primera publicación' : 'Este usuario no ha publicado nada aún',
                  style: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
          itemCount: posts.length,
          itemBuilder: (_, i) => _postCell(context, posts[i]),
        );
      },
    );
  }

  Widget _postCell(BuildContext context, PostModel post) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id))),
      onLongPress: widget.isOwn
          ? () => _confirmDelete(context, post)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          post.imageBase64.isNotEmpty
              ? ImageUtils.imageFromBase64(post.imageBase64)
              : Container(color: AppColors.accentBg,
                  child: const Icon(Icons.checkroom_outlined, color: AppColors.textHint)),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: Text(post.title,
                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar publicación', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar "${post.title}"? Esta acción no se puede deshacer.',
            style: GoogleFonts.dmSans(color: AppColors.textSec)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar', style: GoogleFonts.dmSans(color: AppColors.textSec))),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
              Navigator.of(ctx).pop();
            },
            child: Text('Eliminar',
                style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
