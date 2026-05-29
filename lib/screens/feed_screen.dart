import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../services/posts_service.dart';
import '../utils/image_utils.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import 'user_search_screen.dart';

String _timeAgo(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return 'Ahora';
  if (d.inMinutes < 60) return 'Hace ${d.inMinutes}min';
  if (d.inHours < 24) return 'Hace ${d.inHours}h';
  if (d.inDays < 7) return 'Hace ${d.inDays}d';
  return 'Hace ${(d.inDays / 7).floor()}sem';
}

String _fmtCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  return n.toString();
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _limit = 10;
  bool _hasUnread = true;

  void _loadMore() => setState(() => _limit += 10);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.currentUser?.uid ?? '';
    final following = auth.currentUser?.following ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          setState(() => _limit = 10);
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true, snap: true,
              backgroundColor: AppColors.bgCard,
              elevation: 0,
              scrolledUnderElevation: 0.3,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryMed]).createShader(bounds),
                child: Text('OUTFY',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 26, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 5)),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() => _hasUnread = false);
                    _showNotifications(context);
                  },
                  icon: Stack(clipBehavior: Clip.none, children: [
                    const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
                    if (_hasUnread)
                      Positioned(right: 1, top: 1,
                          child: Container(width: 8, height: 8,
                              decoration: const BoxDecoration(color: AppColors.primaryMed, shape: BoxShape.circle))),
                  ]),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserSearchScreen())),
                  icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 22),
                ),
                const SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: StreamBuilder<List<PostModel>>(
                stream: currentUid.isNotEmpty
                    ? PostsService.instance.streamFeedPosts(currentUid, following, limit: _limit)
                    : const Stream.empty(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }
                  final posts = snap.data ?? [];
                  if (following.isEmpty) {
                    return _EmptyFeed(
                      icon: Icons.people_outline_rounded,
                      title: 'Empieza a seguir usuarios',
                      subtitle: 'Busca usuarios en el buscador y sigue a quienes te inspiren',
                      onAction: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const UserSearchScreen())),
                      actionLabel: 'Buscar usuarios',
                    );
                  }
                  if (posts.isEmpty) {
                    return const _EmptyFeed(
                      icon: Icons.photo_outlined,
                      title: 'Aún no hay publicaciones',
                      subtitle: 'Las personas que sigues aún no han publicado nada',
                    );
                  }
                  return Column(
                    children: [
                      ...posts.map((post) => _PostCard(
                            key: ValueKey(post.id),
                            post: post,
                            currentUid: currentUid,
                          )),
                      if (posts.length >= _limit)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextButton.icon(
                            onPressed: _loadMore,
                            icon: const Icon(Icons.expand_more_rounded),
                            label: Text('Ver más', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: DraggableScrollableSheet(
          initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.85, expand: false,
          builder: (_, ctrl) => _NotificationsSheet(controller: ctrl),
        ),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUid;
  const _PostCard({super.key, required this.post, required this.currentUid});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with SingleTickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;
  bool _likeLoading = false;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _heartScale = Tween<double>(begin: 0.7, end: 1.45)
        .chain(CurveTween(curve: Curves.easeOutBack)).animate(_heartCtrl);
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  bool get _isLiked => widget.post.isLikedBy(widget.currentUid);

  Future<void> _handleLike() async {
    if (_likeLoading) return;
    HapticFeedback.selectionClick();
    _heartCtrl.forward(from: 0);
    setState(() => _likeLoading = true);
    await PostsService.instance.toggleLike(widget.post.id, widget.currentUid);
    if (mounted) setState(() => _likeLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      color: AppColors.bgCard,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProfileScreen(userId: post.userId))),
                  child: _Avatar(base64: post.userAvatarBase64, name: post.username),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProfileScreen(userId: post.userId))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(post.username,
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                      Text(_timeAgo(post.createdAt),
                          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
                    ]),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz, color: AppColors.textHint, size: 20),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: _handleLike,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id))),
            child: SizedBox(
              width: double.infinity, height: 380,
              child: Stack(fit: StackFit.expand, children: [
                post.imageBase64.isNotEmpty
                    ? ImageUtils.imageFromBase64(post.imageBase64)
                    : Container(color: AppColors.accentBg,
                        child: const Icon(Icons.checkroom_outlined, size: 64, color: AppColors.primaryMed)),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Text(post.title,
                        style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                ),
                Center(
                  child: AnimatedBuilder(
                    animation: _heartCtrl,
                    builder: (_, _) {
                      if (_heartCtrl.value == 0 || _heartCtrl.value == 1) return const SizedBox.shrink();
                      return Transform.scale(
                        scale: _heartScale.value,
                        child: Icon(Icons.favorite_rounded,
                            color: Colors.white.withValues(alpha: 1 - _heartCtrl.value), size: 88),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _ActionBtn(
                  icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isLiked ? const Color(0xFFE74C3C) : AppColors.textPrimary,
                  onTap: _handleLike,
                ),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppColors.textPrimary,
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id))),
                ),
                _ActionBtn(
                  icon: Icons.near_me_outlined,
                  color: AppColors.textPrimary,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: 'outfy://post/${post.id}'));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado')));
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_fmtCount(post.likes)} me gusta',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                if (post.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: '${post.username}  ',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                    TextSpan(text: post.description,
                        style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSec, height: 1.45)),
                  ])),
                ],
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8, runSpacing: 2,
                    children: post.tags.map((t) => Text('#$t',
                        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700))).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String base64;
  final String name;
  const _Avatar({required this.base64, required this.name});

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: base64.isNotEmpty
            ? ImageUtils.imageFromBase64(base64, placeholder: _fallback())
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => CircleAvatar(
    backgroundColor: AppColors.primaryMed,
    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
  );
}

class _EmptyFeed extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  const _EmptyFeed({required this.icon, required this.title, required this.subtitle, this.onAction, this.actionLabel});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
    child: Column(
      children: [
        Icon(icon, size: 56, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle, style: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 13), textAlign: TextAlign.center),
        if (onAction != null) ...[const SizedBox(height: 20), ElevatedButton(onPressed: onAction, child: Text(actionLabel ?? ''))],
      ],
    ),
  );
}

class _NotificationsSheet extends StatefulWidget {
  final ScrollController controller;
  const _NotificationsSheet({required this.controller});
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  final _items = [
    _NotifItem('Un usuario', 'le dio like a tu outfit', '2 min', Icons.favorite_rounded, AppColors.primaryMed),
    _NotifItem('Un usuario', 'comentó tu publicación', '15 min', Icons.chat_bubble_rounded, Color(0xFF8E44AD)),
    _NotifItem('Un usuario', 'empezó a seguirte', '1 h', Icons.person_add_rounded, Color(0xFF00838F)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(children: [
            _Handle(),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text('Notificaciones', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800))),
              TextButton(
                  onPressed: () => setState(() => _items.clear()),
                  child: Text('Limpiar', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700))),
            ]),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text('Todo al día', style: GoogleFonts.dmSans(color: AppColors.textHint)))
              : ListView.builder(
                  controller: widget.controller,
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Dismissible(
                      key: ValueKey('${item.user}-$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red, alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.white)),
                      onDismissed: (_) => setState(() => _items.removeAt(i)),
                      child: ListTile(
                        leading: Container(width: 42, height: 42,
                            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Icon(item.icon, color: item.color, size: 20)),
                        title: RichText(text: TextSpan(children: [
                          TextSpan(text: '${item.user}  ', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13)),
                          TextSpan(text: item.text, style: GoogleFonts.dmSans(color: AppColors.textSec, fontSize: 13)),
                        ])),
                        trailing: Text(item.time, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
                      ),
                    );
                  }),
        ),
      ],
    );
  }
}

class _NotifItem {
  final String user, text, time;
  final IconData icon;
  final Color color;
  const _NotifItem(this.user, this.text, this.time, this.icon, this.color);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap, icon: Icon(icon, size: 24, color: color),
    padding: const EdgeInsets.all(8), constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
  );
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 40, height: 4,
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))));
}

class _BottomSheet extends StatelessWidget {
  final Widget child;
  const _BottomSheet({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    clipBehavior: Clip.hardEdge, child: child,
  );
}
