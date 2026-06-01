import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors, AppColorsExt;
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../providers/auth_provider.dart';
import '../services/posts_service.dart';
import '../services/stories_service.dart';
import '../utils/image_utils.dart';
import '../widgets/avatar_with_frame.dart';
import '../widgets/share_sheet.dart';
import 'messages_list_screen.dart';
import 'notifications_screen.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import 'story_viewer_screen.dart';
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
  final _picker = ImagePicker();

  void _loadMore() => setState(() => _limit += 10);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.currentUser?.uid ?? '';
    final following = auth.currentUser?.following ?? [];
    final bgCard = context.colBgCard;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          setState(() => _limit = 10);
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar ──────────────────────────────────────────────────────
            SliverAppBar(
              floating: true, snap: true,
              backgroundColor: bgCard,
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
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MessagesListScreen())),
                  icon: Icon(Icons.mail_outline_rounded, color: context.colText, size: 22),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  icon: Icon(Icons.notifications_none_rounded, color: context.colText, size: 22),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserSearchScreen())),
                  icon: Icon(Icons.search_rounded, color: context.colText, size: 22),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ── Historias ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: bgCard,
                padding: const EdgeInsets.only(bottom: 12, top: 6),
                child: SizedBox(
                  height: 100,
                  child: StreamBuilder<List<StoryModel>>(
                    stream: currentUid.isNotEmpty
                        ? StoriesService.instance.streamActiveStories()
                        : const Stream.empty(),
                    builder: (context, snap) {
                      final stories = snap.data ?? [];
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: stories.length + 1,
                        itemBuilder: (_, index) {
                          if (index == 0) return _buildMyStory(context, auth, stories, currentUid);
                          final story = stories[index - 1];
                          return _buildStoryBubble(context, story, currentUid);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider(height: 1)),

            // ── Posts como SliverList para evitar flash ─────────────────────
            _PostsSliver(
              currentUid: currentUid,
              following: following,
              limit: _limit,
              onLoadMore: _loadMore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyStory(BuildContext context, AuthProvider auth,
      List<StoryModel> stories, String currentUid) {
    final user = auth.currentUser;
    final myStory = stories.where((s) => s.userId == currentUid).firstOrNull;
    final hasStory = myStory != null;
    final initial = user?.nombre.isNotEmpty == true ? user!.nombre[0].toUpperCase() : '+';

    return GestureDetector(
      onTap: hasStory
          ? () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StoryViewerScreen(story: myStory, currentUid: currentUid)))
          : () => _showCreateStory(context),
      child: _StoryBubble(
        initial: hasStory ? initial : '+',
        label: 'Tu historia',
        avatarBase64: user?.avatarBase64,
        frameStyle: user?.frameStyle ?? 'none',
        hasNew: hasStory,
        isMe: true,
      ),
    );
  }

  Widget _buildStoryBubble(BuildContext context, StoryModel story, String currentUid) {
    final isViewed = story.isViewedBy(currentUid);
    final label = story.username.length > 8 ? '${story.username.substring(0, 7)}…' : story.username;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StoryViewerScreen(story: story, currentUid: currentUid))),
      child: _StoryBubble(
        initial: story.username.isNotEmpty ? story.username[0].toUpperCase() : '?',
        label: label,
        avatarBase64: story.avatarBase64,
        frameStyle: story.frameStyle ?? 'none',
        hasNew: !isViewed,
        isMe: false,
      ),
    );
  }

  void _showCreateStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: context.colBorder, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 18),
                Text('Crear historia', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: context.colText)),
                const SizedBox(height: 6),
                Text('Muestra tu outfit del día en una historia.', style: GoogleFonts.dmSans(color: context.colTextSec, fontSize: 13)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _sourceOption(context, Icons.camera_alt_outlined, 'Cámara', ImageSource.camera)),
                  const SizedBox(width: 10),
                  Expanded(child: _sourceOption(context, Icons.photo_library_outlined, 'Galería', ImageSource.gallery)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sourceOption(BuildContext ctx, IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () { Navigator.pop(ctx); _pickStoryImage(source); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: ctx.colBgPage,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ctx.colBorder),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13, color: ctx.colText)),
        ]),
      ),
    );
  }

  Future<void> _pickStoryImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 86, maxWidth: 1400);
    if (image == null || !mounted) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    try {
      await StoriesService.instance.createStory(user.uid, user, image);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historia publicada')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al publicar la historia')));
      }
    }
  }
}

// ── Posts: StatefulWidget con stream estable para evitar el flash blanco ────────
//
// IMPORTANTE: _PostsSliver debe ser StatefulWidget.
// Si fuera StatelessWidget, cada rebuild de FeedScreen (por AuthProvider.notifyListeners)
// crearía un NUEVO objeto stream → StreamBuilder resetea a ConnectionState.waiting → flash.
// Al guardar el stream en estado y solo recrearlo cuando cambian uid/following/limit,
// StreamBuilder mantiene la suscripción existente y no parpadea.
class _PostsSliver extends StatefulWidget {
  final String currentUid;
  final List<String> following;
  final int limit;
  final VoidCallback onLoadMore;

  const _PostsSliver({
    required this.currentUid,
    required this.following,
    required this.limit,
    required this.onLoadMore,
  });

  @override
  State<_PostsSliver> createState() => _PostsSliverState();
}

class _PostsSliverState extends State<_PostsSliver> {
  Stream<List<PostModel>>? _stream;

  @override
  void initState() {
    super.initState();
    _rebuildStream();
  }

  @override
  void didUpdateWidget(_PostsSliver old) {
    super.didUpdateWidget(old);
    // Solo recrear el stream si los parámetros realmente cambiaron
    if (old.currentUid != widget.currentUid ||
        old.limit != widget.limit ||
        !_sameList(old.following, widget.following)) {
      _rebuildStream();
    }
  }

  bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _rebuildStream() {
    _stream = widget.currentUid.isNotEmpty
        ? PostsService.instance.streamFeedPosts(
            widget.currentUid, widget.following, limit: widget.limit)
        : const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: _stream,
      builder: (context, snap) {
        // Solo mostrar loading si NO tenemos datos previos
        if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          );
        }

        final posts = snap.data ?? [];

        if (widget.following.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyFeed(
              icon: Icons.people_outline_rounded,
              title: 'Empieza a seguir usuarios',
              subtitle: 'Busca usuarios en el buscador y sigue a quienes te inspiren',
              onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserSearchScreen())),
              actionLabel: 'Buscar usuarios',
            ),
          );
        }

        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyFeed(
              icon: Icons.photo_outlined,
              title: 'Aún no hay publicaciones',
              subtitle: 'Las personas que sigues aún no han publicado nada',
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              if (i == posts.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: widget.onLoadMore,
                      icon: const Icon(Icons.expand_more_rounded),
                      label: Text('Ver más', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  ),
                );
              }
              if (i == posts.length + 1) {
                return const SizedBox(height: 20);
              }
              return RepaintBoundary(
                child: _PostCard(
                  key: ValueKey(posts[i].id),
                  post: posts[i],
                  currentUid: widget.currentUid,
                ),
              );
            },
            childCount: posts.length < widget.limit ? posts.length + 1 : posts.length + 2,
          ),
        );
      },
    );
  }
}

// ── PostCard ───────────────────────────────────────────────────────────────────
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

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSheet(
        postId: widget.post.id,
        postTitle: widget.post.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final bgCard = context.colBgCard;
    final textPrimary = context.colText;
    final textSec = context.colTextSec;
    final textHint = context.colTextHint;

    return Container(
      color: bgCard,
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
                  child: AvatarWithFrame(
                    base64: post.userAvatarBase64.isNotEmpty ? post.userAvatarBase64 : null,
                    frameStyle: 'none',
                    radius: 22,
                    initials: post.username.isNotEmpty ? post.username[0].toUpperCase() : '?',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProfileScreen(userId: post.userId))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(post.username,
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 14, color: textPrimary)),
                      Text(_timeAgo(post.createdAt),
                          style: GoogleFonts.dmSans(fontSize: 11, color: textHint)),
                    ]),
                  ),
                ),
                IconButton(
                  onPressed: () => _showShareSheet(context),
                  icon: Icon(Icons.more_horiz, color: textHint, size: 20),
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
                  color: _isLiked ? const Color(0xFFE74C3C) : textPrimary,
                  onTap: _handleLike,
                ),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: textPrimary,
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id))),
                ),
                _ActionBtn(
                  icon: Icons.near_me_outlined,
                  color: textPrimary,
                  onTap: () => _showShareSheet(context),
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
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 13, color: textPrimary)),
                if (post.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: '${post.username}  ',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 13, color: textPrimary)),
                    TextSpan(text: post.description,
                        style: GoogleFonts.dmSans(fontSize: 13, color: textSec, height: 1.45)),
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

// ── Widgets de apoyo ───────────────────────────────────────────────────────────
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
        Icon(icon, size: 56, color: context.colTextHint),
        const SizedBox(height: 16),
        Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16, color: context.colText), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle, style: GoogleFonts.dmSans(color: context.colTextHint, fontSize: 13), textAlign: TextAlign.center),
        if (onAction != null) ...[const SizedBox(height: 20), ElevatedButton(onPressed: onAction, child: Text(actionLabel ?? ''))],
      ],
    ),
  );
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

class _BottomSheet extends StatelessWidget {
  final Widget child;
  const _BottomSheet({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: context.colBgCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
    clipBehavior: Clip.hardEdge, child: child,
  );
}

// ── Stories ────────────────────────────────────────────────────────────────────
class _StoryBubble extends StatelessWidget {
  final String initial;
  final String label;
  final String? avatarBase64;
  final String frameStyle;
  final bool hasNew;
  final bool isMe;

  const _StoryBubble({
    required this.initial, required this.label,
    this.avatarBase64, required this.frameStyle,
    required this.hasNew, required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 12),
      child: Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 68, height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasNew
                ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: hasNew ? null : context.colBorder,
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.colBgCard),
            padding: const EdgeInsets.all(2),
            child: isMe && (avatarBase64 == null || avatarBase64!.isEmpty)
                ? Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: context.colAccentBg),
                    child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 26))
                : AvatarWithFrame(
                    base64: avatarBase64,
                    frameStyle: 'none',
                    radius: 28,
                    initials: initial,
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: hasNew ? FontWeight.w700 : FontWeight.w500,
              color: hasNew ? context.colText : context.colTextHint,
            )),
      ]),
    );
  }
}
