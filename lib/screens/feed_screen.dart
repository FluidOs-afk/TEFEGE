import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../services/posts_service.dart';
import '../utils/image_utils.dart';
import '../widgets/fashion_icon.dart';
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
  final _picker = ImagePicker();

  final List<_Story> _stories = [
    _Story(label: 'sofia.s',   color: const Color(0xFF1B6B44), initial: 'S', hasNew: true,  title: 'Cápsula oficina',    detail: 'Blazer, denim recto y mocasín.',        category: FashionCategory.tops),
    _Story(label: 'marta.f',   color: const Color(0xFF8E44AD), initial: 'M', hasNew: true,  title: 'Paleta pastel',      detail: 'Coral suave con lavanda y plata.',      category: FashionCategory.pants),
    _Story(label: 'lucia.v',   color: const Color(0xFF9A6B4F), initial: 'L', hasNew: false, title: 'Hallazgo vintage',   detail: 'Abrigo de lana y bolso estructurado.',  category: FashionCategory.coat),
    _Story(label: 'andrea.g',  color: const Color(0xFF455A64), initial: 'A', hasNew: true,  title: 'Noche satinada',     detail: 'Texturas brillantes con sandalias.',     category: FashionCategory.dress),
    _Story(label: 'carmen.b',  color: const Color(0xFF00838F), initial: 'C', hasNew: false, title: 'Azules limpios',     detail: 'Camisa abierta y pantalón amplio.',     category: FashionCategory.accessory),
  ];

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
              child: Container(
                color: AppColors.bgCard,
                padding: const EdgeInsets.only(bottom: 12, top: 6),
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _stories.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) return _buildMyStory(context, auth);
                      return _buildStoryItem(index - 1);
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider(height: 1, color: AppColors.border)),
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

  Widget _buildMyStory(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final initial = user?.nombre.isNotEmpty == true ? user!.nombre[0].toUpperCase() : '+';
    return GestureDetector(
      onTap: () => _showCreateStory(context),
      child: _StoryBubble(initial: initial, label: 'Tu historia', color: AppColors.primaryMed, hasNew: false, isMe: true),
    );
  }

  Widget _buildStoryItem(int index) {
    final story = _stories[index];
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(PageRouteBuilder<void>(
          opaque: false,
          barrierColor: Colors.black,
          pageBuilder: (_, __, ___) => _StoryViewer(
            stories: _stories,
            initialIndex: index,
            onViewed: (i) { if (mounted) setState(() { _stories[i] = _stories[i].copyWith(hasNew: false); }); },
          ),
        ));
      },
      child: _StoryBubble(
        initial: story.initial,
        label: story.label.length > 8 ? '${story.label.substring(0, 7)}…' : story.label,
        color: story.color,
        hasNew: story.hasNew,
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
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 18),
                Text('Crear historia', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Muestra tu outfit del día en una historia.', style: GoogleFonts.dmSans(color: AppColors.textSec, fontSize: 13)),
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
        decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }

  Future<void> _pickStoryImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 86, maxWidth: 1400);
    if (image == null || !mounted) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    setState(() {
      _stories.insert(0, _Story(
        label: user?.username ?? 'tu.look',
        color: AppColors.primary,
        initial: user?.nombre.isNotEmpty == true ? user!.nombre[0].toUpperCase() : 'T',
        hasNew: true,
        title: source == ImageSource.camera ? 'Foto nueva' : 'Desde galería',
        detail: 'Historia creada en esta sesión.',
        category: FashionCategory.tops,
        imageBytes: bytes,
      ));
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historia creada')));
    }
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

// ── Stories ────────────────────────────────────────────────────────────────────

class _Story {
  final String label;
  final String initial;
  final Color color;
  final bool hasNew;
  final String title;
  final String detail;
  final FashionCategory category;
  final Uint8List? imageBytes;

  const _Story({
    required this.label, required this.color, required this.initial,
    required this.hasNew, required this.title, required this.detail,
    required this.category, this.imageBytes,
  });

  _Story copyWith({bool? hasNew}) => _Story(
    label: label, color: color, initial: initial,
    hasNew: hasNew ?? this.hasNew, title: title, detail: detail,
    category: category, imageBytes: imageBytes,
  );
}

class _StoryBubble extends StatelessWidget {
  final String initial;
  final String label;
  final Color color;
  final bool hasNew;
  final bool isMe;

  const _StoryBubble({
    required this.initial, required this.label, required this.color,
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
            color: hasNew ? null : AppColors.border,
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard),
            padding: const EdgeInsets.all(2),
            child: isMe
                ? Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentBg),
                    child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 26))
                : CircleAvatar(
                    backgroundColor: color,
                    child: Text(initial, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: hasNew ? FontWeight.w700 : FontWeight.w500,
              color: hasNew ? AppColors.textPrimary : AppColors.textHint,
            )),
      ]),
    );
  }
}

class _StoryViewer extends StatefulWidget {
  final List<_Story> stories;
  final int initialIndex;
  final ValueChanged<int> onViewed;

  const _StoryViewer({required this.stories, required this.initialIndex, required this.onViewed});

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer> {
  late final PageController _ctrl;
  late int _index;
  Timer? _timer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _ctrl = PageController(initialPage: _index);
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) widget.onViewed(_index); });
    _startTimer();
  }

  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  void _startTimer() {
    _timer?.cancel(); _progress = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) return;
      setState(() => _progress = (_progress + 0.02).clamp(0, 1));
      if (_progress >= 1) _next();
    });
  }

  void _next() {
    if (_index == widget.stories.length - 1) { Navigator.pop(context); return; }
    _ctrl.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
  }

  void _prev() {
    if (_index == 0) { _startTimer(); return; }
    _ctrl.previousPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.stories.length,
            onPageChanged: (v) { setState(() => _index = v); widget.onViewed(v); _startTimer(); },
            itemBuilder: (_, i) => _StoryPage(story: widget.stories[i]),
          ),
          Positioned(
            top: 10, left: 10, right: 10,
            child: Row(
              children: List.generate(widget.stories.length, (i) {
                final val = i < _index ? 1.0 : (i == _index ? _progress : 0.0);
                return Expanded(child: Container(
                  height: 3, margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(8)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft, widthFactor: val,
                    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  ),
                ));
              }),
            ),
          ),
          Positioned.fill(
            top: 112,
            child: Row(children: [
              Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _prev)),
              Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _next)),
            ]),
          ),
          Positioned(top: 24, right: 8,
              child: IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white))),
        ]),
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  final _Story story;
  const _StoryPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [story.color, Color.lerp(story.color, Colors.black, 0.52)!],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 58, 22, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              child: Text(story.initial, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Text(story.label, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
          ]),
          const Spacer(),
          Center(
            child: story.imageBytes == null
                ? Container(
                    width: 210, height: 210,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Center(child: FashionIcon(category: story.category, color: Colors.white, size: 112, strokeWidth: 2.5)),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.memory(story.imageBytes!, width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.52, fit: BoxFit.cover)),
          ),
          const Spacer(),
          Text(story.title, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.05)),
          const SizedBox(height: 10),
          Text(story.detail, style: GoogleFonts.dmSans(color: Colors.white.withValues(alpha: 0.86), fontSize: 15, height: 1.35)),
        ]),
      ),
    );
  }
}
