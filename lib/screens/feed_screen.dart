import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post_model.dart';
import '../widgets/fashion_icon.dart';
import '../main.dart' show AppColors;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _activeFilter = 0;
  final List<String> _filters = ['Para ti', 'Siguiendo', 'Tendencias', 'Cerca'];

  final List<PostModel> _posts = [
    PostModel(username: 'sofia.styles', avatar: 'S', avatarColor: Color(0xFF3CB87A), timeAgo: 'Hace 12 min',
        outfitTitle: 'Look casual viernes',
        description: 'Mi look favorito para el trabajo — blazer oversize + vaqueros slouchy. Comodidad sin sacrificar el estilo.',
        likes: 3420, comments: 284, tags: ['Casual', 'Oficina', 'OOTD'],
        placeholderColor: Color(0xFF1B6B44), placeholderColorEnd: Color(0xFF3CB87A),
        fashionCategory: FashionCategory.tops, isLiked: true),
    PostModel(username: 'marta.fashion', avatar: 'M', avatarColor: Color(0xFF9C27B0), timeAgo: 'Hace 1h',
        outfitTitle: 'Streetwear primavera',
        description: 'Tonos pastel para celebrar la primavera. La paleta coral y lavanda es mi obsesión esta temporada.',
        likes: 8910, comments: 641, tags: ['Streetwear', 'Pastel', 'Spring'],
        placeholderColor: Color(0xFF7B1FA2), placeholderColorEnd: Color(0xFFCE93D8),
        fashionCategory: FashionCategory.pants, isLiked: false),
    PostModel(username: 'lucia.vintage', avatar: 'L', avatarColor: Color(0xFF6D4C41), timeAgo: 'Hace 3h',
        outfitTitle: 'Vintage meets modern',
        description: 'Abrigo de lana del mercadillo de Malasaña por 15€. El thrift shopping no tiene precio.',
        likes: 12430, comments: 1120, tags: ['Vintage', 'Thrift', 'Sostenible'],
        placeholderColor: Color(0xFF4E342E), placeholderColorEnd: Color(0xFF8D6E63),
        fashionCategory: FashionCategory.coat, isLiked: false),
    PostModel(username: 'andrea.glam', avatar: 'A', avatarColor: Color(0xFF455A64), timeAgo: 'Hace 5h',
        outfitTitle: 'Night out ready',
        description: 'Para las noches de verano — vestido satinado y sandalias doradas. Less is more.',
        likes: 21040, comments: 870, tags: ['NightOut', 'Elegante', 'Summer'],
        placeholderColor: Color(0xFF263238), placeholderColorEnd: Color(0xFF546E7A),
        fashionCategory: FashionCategory.dress, isLiked: false),
  ];

  final List<_Story> _stories = [
    _Story(label: 'sofia.s',   color: Color(0xFF1B6B44), initial: 'S', hasNew: true),
    _Story(label: 'marta.f',   color: Color(0xFF9C27B0), initial: 'M', hasNew: true),
    _Story(label: 'lucia.v',   color: Color(0xFF6D4C41), initial: 'L', hasNew: false),
    _Story(label: 'andrea.g',  color: Color(0xFF455A64), initial: 'A', hasNew: true),
    _Story(label: 'carmen.b',  color: Color(0xFF00838F), initial: 'C', hasNew: false),
    _Story(label: 'paula.m',   color: Color(0xFF2E7D32), initial: 'P', hasNew: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true, snap: true,
            backgroundColor: AppColors.bgCard,
            elevation: 0, scrolledUnderElevation: 0.3,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryMed],
              ).createShader(b),
              child: Text('OUTFY',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 5,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showNotifications(context),
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
                  Positioned(right: 1, top: 1,
                    child: Container(width: 7, height: 7,
                      decoration: const BoxDecoration(color: AppColors.primaryMed, shape: BoxShape.circle))),
                ]),
              ),
              IconButton(
                onPressed: () => _showSearch(context),
                icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 22),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Stories ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.bgCard,
              padding: const EdgeInsets.only(bottom: 14, top: 6),
              child: SizedBox(
                height: 98,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _stories.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) return _buildMyStory(context);
                    return _buildStoryItem(_stories[i - 1]);
                  },
                ),
              ),
            ),
          ),

          // ── Divider ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),

          // ── Filters ────────────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterDelegate(
              filters: _filters,
              activeFilter: _activeFilter,
              onChanged: (i) => setState(() => _activeFilter = i),
            ),
          ),

          // ── Posts ──────────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == _posts.length) return const SizedBox(height: 20);
                return _PostCard(
                  post: _posts[i],
                  onLike: () => setState(() {
                    final p = _posts[i];
                    _posts[i] = p.copyWith(
                      isLiked: !p.isLiked,
                      likes: p.isLiked ? p.likes - 1 : p.likes + 1,
                    );
                  }),
                  onComment: () => _showComments(context, _posts[i]),
                );
              },
              childCount: _posts.length + 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Story Builders ──────────────────────────────────────────────────────────
  Widget _buildMyStory(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Añadir a tu historia',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)))),
      child: _StoryBubble(
        initial: '+',
        label: 'Tu historia',
        color: AppColors.primaryMed,
        hasNew: false,
        isMe: true,
      ),
    );
  }

  Widget _buildStoryItem(_Story s) {
    return GestureDetector(
      onTap: () {},
      child: _StoryBubble(
        initial: s.initial,
        label: s.label.length > 7 ? '${s.label.substring(0, 6)}…' : s.label,
        color: s.color,
        hasNew: s.hasNew,
        isMe: false,
      ),
    );
  }

  // ── Sheets ─────────────────────────────────────────────────────────────────
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: DraggableScrollableSheet(
          initialChildSize: 0.55, minChildSize: 0.35, maxChildSize: 0.88, expand: false,
          builder: (_, ctrl) => _NotificationsSheet(controller: ctrl),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _SearchSheet(),
        ),
      ),
    );
  }

  void _showComments(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: DraggableScrollableSheet(
          initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
          builder: (_, ctrl) => _CommentsSheet(scrollController: ctrl, username: post.username),
        ),
      ),
    );
  }
}

class _Story {
  final String label, initial;
  final Color color;
  final bool hasNew;
  const _Story({required this.label, required this.color, required this.initial, required this.hasNew});
}

// ─── Story Bubble ─────────────────────────────────────────────────────────────
class _StoryBubble extends StatelessWidget {
  final String initial, label;
  final Color color;
  final bool hasNew, isMe;
  const _StoryBubble({required this.initial, required this.label,
      required this.color, required this.hasNew, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 66, height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasNew
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : null,
              color: hasNew ? null : AppColors.border,
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard),
              padding: const EdgeInsets.all(2),
              child: isMe
                  ? Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentBg),
                      child: Icon(Icons.add_rounded, color: AppColors.primary, size: 26),
                    )
                  : CircleAvatar(
                      backgroundColor: color,
                      child: Text(initial,
                          style: GoogleFonts.dmSans(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    ),
            ),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: hasNew ? FontWeight.w600 : FontWeight.w400,
                  color: hasNew ? AppColors.textPrimary : AppColors.textHint)),
        ],
      ),
    );
  }
}

// ─── Filter Header ────────────────────────────────────────────────────────────
class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final List<String> filters;
  final int activeFilter;
  final Function(int) onChanged;
  const _FilterDelegate({required this.filters, required this.activeFilter, required this.onChanged});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.bgCard,
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final on = activeFilter == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: on ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: on ? AppColors.primary : AppColors.border, width: 1.5),
              ),
              child: Text(filters[i],
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                      color: on ? Colors.white : AppColors.textSec)),
            ),
          );
        },
      ),
    );
  }

  @override double get maxExtent => 52;
  @override double get minExtent => 52;
  @override bool shouldRebuild(_FilterDelegate old) => old.activeFilter != activeFilter;
}

// ─── Post Card ────────────────────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  const _PostCard({required this.post, required this.onLike, required this.onComment});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with SingleTickerProviderStateMixin {
  bool _saved = false;
  late AnimationController _heartCtrl;
  late Animation<double> _heartAnim;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _heartAnim = Tween<double>(begin: 1.0, end: 1.4)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_heartCtrl);
  }

  @override
  void dispose() { _heartCtrl.dispose(); super.dispose(); }

  void _handleLike() {
    widget.onLike();
    _heartCtrl.forward(from: 0);
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCard,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                // Avatar with gradient ring
                Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgCard),
                    padding: const EdgeInsets.all(1.5),
                    child: CircleAvatar(
                      backgroundColor: widget.post.avatarColor,
                      child: Text(widget.post.avatar,
                          style: GoogleFonts.dmSans(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.username,
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700, fontSize: 14,
                              color: AppColors.textPrimary, letterSpacing: -0.2)),
                      const SizedBox(height: 1),
                      Text(widget.post.timeAgo,
                          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
                    ],
                  ),
                ),
                // Seguir button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryMed.withOpacity(0.4)),
                  ),
                  child: Text('Seguir',
                      style: GoogleFonts.dmSans(
                          color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => _showOptions(context),
                  icon: const Icon(Icons.more_horiz, color: AppColors.textHint, size: 20),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── Image ───────────────────────────────────────────────────────────
          GestureDetector(
            onDoubleTap: _handleLike,
            child: SizedBox(
              width: double.infinity,
              height: 400,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.post.placeholderColor, widget.post.placeholderColorEnd],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -24, bottom: -24,
                    child: FashionIcon(
                      category: widget.post.fashionCategory,
                      color: Colors.white.withOpacity(0.06),
                      size: 300, strokeWidth: 3.0,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: FashionIcon(
                        category: widget.post.fashionCategory,
                        color: Colors.white.withOpacity(0.9),
                        size: 72, strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  // Bottom gradient
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 64, 16, 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(widget.post.outfitTitle,
                                style: GoogleFonts.playfairDisplay(
                                    color: Colors.white, fontSize: 16,
                                    fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text('Ver outfit',
                                style: GoogleFonts.dmSans(
                                    color: Colors.white, fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Heart like animation
                  Center(
                    child: ScaleTransition(
                      scale: _heartAnim,
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _heartCtrl,
                          builder: (_, _) => _heartCtrl.value > 0
                              ? Icon(Icons.favorite_rounded,
                                  color: Colors.white.withOpacity(1 - _heartCtrl.value),
                                  size: 90)
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Action Row ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _ActionBtn(
                  icon: widget.post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: widget.post.isLiked ? const Color(0xFFEF5350) : AppColors.textPrimary,
                  onTap: _handleLike,
                  scale: _heartAnim,
                ),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppColors.textPrimary,
                  onTap: widget.onComment,
                ),
                _ActionBtn(
                  icon: Icons.near_me_outlined,
                  color: AppColors.textPrimary,
                  onTap: () => _sharePost(context),
                ),
                const Spacer(),
                _ActionBtn(
                  icon: _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _saved ? AppColors.primary : AppColors.textPrimary,
                  onTap: () => setState(() => _saved = !_saved),
                ),
              ],
            ),
          ),

          // ── Caption & Stats ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Likes
                Text('${_fmt(widget.post.likes)} me gusta',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 13,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 5),
                // Caption with username prefix
                RichText(
                  text: TextSpan(children: [
                    TextSpan(text: '${widget.post.username}  ',
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700, fontSize: 13,
                            color: AppColors.textPrimary)),
                    TextSpan(text: widget.post.description,
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppColors.textSec, height: 1.45)),
                  ]),
                ),
                const SizedBox(height: 7),
                // Hashtags
                Wrap(
                  spacing: 6, runSpacing: 2,
                  children: widget.post.tags.map((tag) => Text(
                    '#$tag',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  )).toList(),
                ),
                const SizedBox(height: 6),
                // Comments link
                GestureDetector(
                  onTap: widget.onComment,
                  child: Text(
                    'Ver los ${_fmt(widget.post.comments)} comentarios',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.textHint,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _SheetHandle(),
            const SizedBox(height: 6),
            ListTile(
              leading: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.bookmark_add_outlined, color: AppColors.primary, size: 18)),
              title: Text('Guardar', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              onTap: () { setState(() => _saved = true); Navigator.pop(context); }),
            ListTile(
              leading: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.share_outlined, color: AppColors.primary, size: 18)),
              title: Text('Compartir', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _sharePost(context); }),
            ListTile(
              leading: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.person_add_outlined, color: AppColors.primary, size: 18)),
              title: Text('Seguir a @${widget.post.username}', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Siguiendo a @${widget.post.username}'))); }),
            ListTile(
              leading: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.flag_outlined, color: Colors.red, size: 18)),
              title: Text('Reportar', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () { Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicación reportada'))); }),
            const SizedBox(height: 8),
          ],
        ),
      )),
    );
  }

  void _sharePost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enlace copiado al portapapeles',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w500))));
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Animation<double>? scale;
  const _ActionBtn({required this.icon, required this.color, required this.onTap, this.scale});

  @override
  Widget build(BuildContext context) {
    Widget btn = GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 24, color: color),
      ),
    );
    if (scale != null) {
      return ScaleTransition(scale: scale!, child: btn);
    }
    return btn;
  }
}

// ─── Bottom Sheet Wrapper ─────────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final Widget child;
  const _BottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

// ─── Sheet Handle ─────────────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
          color: AppColors.border, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

// ─── Comments Sheet ───────────────────────────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String username;
  const _CommentsSheet({required this.scrollController, required this.username});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();
  final List<Map<String, String>> _comments = [
    {'user': 'carmen.b',     'text': 'Esta combinación es perfecta. Donde es el blazer?', 'time': '5 min'},
    {'user': 'ana.trends',   'text': 'Me tienes obsesionada con este look', 'time': '12 min'},
    {'user': 'paula.style',  'text': 'Inspiración total para mañana', 'time': '23 min'},
    {'user': 'sara.moda',    'text': 'Los colores tierra son mi nueva obsesión', 'time': '1h'},
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(children: [
            _SheetHandle(),
            const SizedBox(height: 12),
            Text('Comentarios', style: GoogleFonts.dmSans(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _comments.length,
            itemBuilder: (_, i) => _CommentRow(comment: _comments[i]),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 14),
          decoration: const BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              Container(width: 34, height: 34,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.accentBg),
                  child: const Center(child: Icon(Icons.person, size: 18, color: AppColors.primary))),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: GoogleFonts.dmSans(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Añade un comentario...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (_ctrl.text.isNotEmpty) {
                    setState(() { _comments.insert(0, {'user': 'tú', 'text': _ctrl.text, 'time': 'Ahora'}); _ctrl.clear(); });
                  }
                },
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  final Map<String, String> comment;
  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentBg),
            child: Center(child: Text(comment['user']![0].toUpperCase(),
                style: GoogleFonts.dmSans(
                    color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: '${comment['user']}  ',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700, fontSize: 13,
                          color: AppColors.textPrimary)),
                  TextSpan(text: comment['text'],
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.textSec, height: 1.4)),
                ])),
                const SizedBox(height: 4),
                Text(comment['time']!,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notifications Sheet ──────────────────────────────────────────────────────
class _NotificationsSheet extends StatelessWidget {
  final ScrollController controller;
  const _NotificationsSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final notifs = [
      ('sofia.styles',  'le dio like a tu outfit',       '2 min',  Icons.favorite_rounded,  AppColors.primaryMed),
      ('marta.fashion', 'comentó tu publicación',         '15 min', Icons.chat_bubble_rounded, Color(0xFF9C27B0)),
      ('lucia.vintage', 'empezó a seguirte',              '1h',     Icons.person_add_rounded,  Color(0xFF00838F)),
      ('andrea.glam',   'guardó tu publicación',          '2h',     Icons.bookmark_rounded,    Color(0xFFFF9800)),
      ('carmen.b',      'te mencionó en un comentario',   '3h',     Icons.alternate_email,     Color(0xFF2E7D32)),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(children: [
            _SheetHandle(),
            const SizedBox(height: 12),
            Text('Notificaciones', style: GoogleFonts.dmSans(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: controller,
            itemCount: notifs.length,
            itemBuilder: (_, i) {
              final n = notifs[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                      color: n.$5.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(n.$4, color: n.$5, size: 20)),
                title: RichText(text: TextSpan(children: [
                  TextSpan(text: '${n.$1}  ',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, fontSize: 13)),
                  TextSpan(text: n.$2,
                      style: GoogleFonts.dmSans(color: AppColors.textSec, fontSize: 13)),
                ])),
                trailing: Text(n.$3,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Search Sheet ─────────────────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();
  final _results = ['sofia.styles', 'marta.fashion', 'lucia.vintage', 'andrea.glam', 'carmen.b'];
  List<String> _filtered = [];

  @override
  void initState() { super.initState(); _filtered = _results; }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: GoogleFonts.dmSans(fontSize: 14),
            onChanged: (v) => setState(() =>
                _filtered = _results.where((r) => r.contains(v.toLowerCase())).toList()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
              hintText: 'Buscar usuarios, outfits, estilos...',
            ),
          ),
          const SizedBox(height: 12),
          ..._filtered.map((r) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentBg),
              child: Center(child: Text(r[0].toUpperCase(),
                  style: GoogleFonts.dmSans(
                      color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16))),
            ),
            title: Text(r, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Diseñadora de moda',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryMed.withOpacity(0.4))),
              child: Text('Seguir',
                  style: GoogleFonts.dmSans(
                      color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
