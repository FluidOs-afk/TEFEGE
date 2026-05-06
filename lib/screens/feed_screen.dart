import 'package:flutter/material.dart';
import '../models/post_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _activeFilter = 0;
  final List<String> _filters = ['Para ti', 'Siguiendo', 'Tendencias', 'Cerca'];

  final List<PostModel> _posts = [
    PostModel(username: 'sofia.styles', avatar: 'S', avatarColor: Color(0xFFE8537A), timeAgo: 'Hace 12 min',
        outfitTitle: 'Look casual viernes', description: 'Mi favorito para el trabajo: blazer oversize + vaqueros slouchy. Comodidad sin sacrificar el estilo ✨',
        likes: 342, comments: 28, tags: ['Casual', 'Oficina'], placeholderColor: Color(0xFFFCE4EC), placeholderEmoji: '👗', isLiked: true),
    PostModel(username: 'marta.fashion', avatar: 'M', avatarColor: Color(0xFF9C27B0), timeAgo: 'Hace 1h',
        outfitTitle: 'Streetwear primavera', description: 'Tonos pastel para celebrar la primavera! La paleta coral + lavanda está siendo mi obsesión 🌸',
        likes: 891, comments: 64, tags: ['Streetwear', 'Pastel'], placeholderColor: Color(0xFFF3E5F5), placeholderEmoji: '🌸', isLiked: false),
    PostModel(username: 'lucia.vintage', avatar: 'L', avatarColor: Color(0xFF795548), timeAgo: 'Hace 3h',
        outfitTitle: 'Vintage meets modern', description: 'Encontré este abrigo de lana en el mercadillo de Malasaña por 15€. Thrift shopping para ganar! ♻️',
        likes: 1243, comments: 112, tags: ['Vintage', 'Thrift'], placeholderColor: Color(0xFFEFEBE9), placeholderEmoji: '🧥', isLiked: false),
    PostModel(username: 'andrea.glam', avatar: 'A', avatarColor: Color(0xFFFF5722), timeAgo: 'Hace 5h',
        outfitTitle: 'Night out ready', description: 'Para las noches de verano: vestido satinado + sandalias doradas. Simple pero efectivo 🌙',
        likes: 2104, comments: 87, tags: ['Noche', 'Elegante'], placeholderColor: Color(0xFFFFF8E1), placeholderEmoji: '✨', isLiked: false),
  ];

  final List<_Story> _stories = [
    _Story(label: 'sofia.s', color: Color(0xFFE8537A), initial: 'S', hasNew: true),
    _Story(label: 'marta.f', color: Color(0xFF9C27B0), initial: 'M', hasNew: true),
    _Story(label: 'lucia.v', color: Color(0xFF795548), initial: 'L', hasNew: false),
    _Story(label: 'andrea.g', color: Color(0xFFFF5722), initial: 'A', hasNew: true),
    _Story(label: 'carmen.b', color: Color(0xFF00BCD4), initial: 'C', hasNew: false),
    _Story(label: 'paula.m', color: Color(0xFF4CAF50), initial: 'P', hasNew: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            centerTitle: true,
            title: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFE8537A), Color(0xFFFF8FAB)],
              ).createShader(b),
              child: const Text('OUTFY',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                      color: Colors.white, letterSpacing: 4)),
            ),
            actions: [
              IconButton(
                onPressed: () => _showNotifications(context),
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.notifications_outlined, color: Color(0xFF2D2D2D)),
                  Positioned(right: 0, top: 0,
                      child: Container(width: 7, height: 7,
                          decoration: const BoxDecoration(color: Color(0xFFE8537A), shape: BoxShape.circle))),
                ]),
              ),
              IconButton(
                onPressed: () => _showSearch(context),
                icon: const Icon(Icons.search_rounded, color: Color(0xFF2D2D2D)),
              ),
            ],
          ),
          // Stories
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 88,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _stories.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) return _buildMyStory(context);
                    return _buildStoryItem(_stories[i - 1]);
                  },
                ),
              ),
            ),
          ),
          // Filters
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverFilterHeader(
              filters: _filters,
              activeFilter: _activeFilter,
              onChanged: (i) => setState(() => _activeFilter = i),
            ),
          ),
          // Posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _PostCard(
                post: _posts[i],
                onLike: () => setState(() {
                  final p = _posts[i];
                  _posts[i] = p.copyWith(
                    isLiked: !p.isLiked,
                    likes: p.isLiked ? p.likes - 1 : p.likes + 1,
                  );
                }),
                onComment: () => _showComments(context, _posts[i]),
              ),
              childCount: _posts.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildMyStory(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📸 Añadir a tu historia'), backgroundColor: Color(0xFFE8537A))),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Stack(children: [
                const CircleAvatar(radius: 27, backgroundColor: Color(0xFFF5F5F5),
                    child: Icon(Icons.person, color: Color(0xFFBDBDBD), size: 28)),
                Positioned(bottom: 0, right: 0,
                    child: Container(width: 18, height: 18,
                        decoration: const BoxDecoration(color: Color(0xFFE8537A), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 12))),
              ]),
            ),
            const SizedBox(height: 4),
            const Text('Tu historia', style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(_Story story) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: story.hasNew
                    ? const LinearGradient(colors: [Color(0xFFE8537A), Color(0xFFFF8FAB)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: story.hasNew ? null : Colors.grey[300],
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: story.color,
                  child: Text(story.initial,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(story.label.length > 7 ? '${story.label.substring(0, 6)}…' : story.label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.85, expand: false,
        builder: (_, ctrl) => _NotificationsSheet(controller: ctrl),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _SearchSheet(),
      ),
    );
  }

  void _showComments(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (_, ctrl) => _CommentsSheet(scrollController: ctrl, username: post.username),
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

// ─── Filter Header ────────────────────────────────────────────────────────────
class _SliverFilterHeader extends SliverPersistentHeaderDelegate {
  final List<String> filters;
  final int activeFilter;
  final Function(int) onChanged;
  const _SliverFilterHeader({required this.filters, required this.activeFilter, required this.onChanged});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final isActive = activeFilter == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8537A) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(filters[i],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? Colors.white : const Color(0xFF666666))),
            ),
          );
        },
      ),
    );
  }

  @override double get maxExtent => 48;
  @override double get minExtent => 48;
  @override bool shouldRebuild(_SliverFilterHeader old) => old.activeFilter != activeFilter;
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

class _PostCardState extends State<_PostCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: widget.post.avatarColor,
                  child: Text(widget.post.avatar,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.username,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF2D2D2D))),
                      Text(widget.post.timeAgo,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showOptions(context),
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF9E9E9E)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          // Image
          Container(
            width: double.infinity,
            height: 340,
            color: widget.post.placeholderColor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(widget.post.placeholderEmoji, style: const TextStyle(fontSize: 72)),
                Positioned(
                  bottom: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(widget.post.outfitTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          // Actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onLike,
                  icon: Icon(
                    widget.post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: widget.post.isLiked ? const Color(0xFFE8537A) : const Color(0xFF2D2D2D),
                    size: 25,
                  ),
                ),
                IconButton(
                  onPressed: widget.onComment,
                  icon: const Icon(Icons.mode_comment_outlined, size: 23, color: Color(0xFF2D2D2D)),
                ),
                IconButton(
                  onPressed: () => _sharePost(context),
                  icon: const Icon(Icons.send_outlined, size: 23, color: Color(0xFF2D2D2D)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _saved = !_saved),
                  icon: Icon(
                    _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 23,
                    color: _saved ? const Color(0xFFE8537A) : const Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
          // Likes + caption
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.post.likes} me gustas',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2D2D2D))),
                const SizedBox(height: 4),
                Text(widget.post.description,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.4)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: widget.post.tags.map((tag) => GestureDetector(
                    onTap: () {},
                    child: Text('#$tag',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF3897F0), fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: widget.onComment,
                  child: Text('Ver los ${widget.post.comments} comentarios',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
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
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            ListTile(leading: const Icon(Icons.bookmark_add_outlined), title: const Text('Guardar'),
                onTap: () { setState(() => _saved = true); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.share_outlined), title: const Text('Compartir'),
                onTap: () { _sharePost(context); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.person_add_outlined), title: Text('Seguir a @${widget.post.username}'),
                onTap: () { Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Siguiendo a @${widget.post.username}'),
                      backgroundColor: const Color(0xFFE8537A))); }),
            ListTile(leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text('Reportar', style: TextStyle(color: Colors.red)),
                onTap: () { Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicación reportada'))); }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _sharePost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔗 Enlace copiado al portapapeles'), backgroundColor: Color(0xFFE8537A)));
  }
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
    {'user': 'carmen.b', 'text': '¡Me encanta esta combinación! 🔥', 'time': '5 min'},
    {'user': 'ana.trends', 'text': '¿De dónde es el blazer?', 'time': '12 min'},
    {'user': 'paula.style', 'text': 'Inspiración total ✨', 'time': '23 min'},
    {'user': 'sara.moda', 'text': 'El color me tiene obsesionada', 'time': '1h'},
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 10),
            const Text('Comentarios', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(14),
            itemCount: _comments.length,
            itemBuilder: (_, i) => _CommentRow(comment: _comments[i]),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 12, right: 12, top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12),
          decoration: BoxDecoration(color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!))),
          child: Row(
            children: [
              const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE8537A),
                  child: Text('Tú', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'Añade un comentario...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(22))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  if (_ctrl.text.isNotEmpty) {
                    setState(() { _comments.insert(0, {'user': 'tú', 'text': _ctrl.text, 'time': 'Ahora'}); _ctrl.clear(); });
                  }
                },
                child: const Text('Publicar', style: TextStyle(color: Color(0xFFE8537A), fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 16, backgroundColor: const Color(0xFFE8537A).withOpacity(0.12),
              child: Text(comment['user']![0].toUpperCase(),
                  style: const TextStyle(color: Color(0xFFE8537A), fontWeight: FontWeight.bold, fontSize: 12))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: '${comment['user']} ', style: const TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold, fontSize: 13)),
                  TextSpan(text: comment['text'], style: const TextStyle(color: Color(0xFF444444), fontSize: 13)),
                ])),
                const SizedBox(height: 2),
                Text(comment['time']!, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
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
      ('sofia.styles', 'le dio like a tu outfit', '2 min', Icons.favorite, Color(0xFFE8537A)),
      ('marta.fashion', 'comentó: "¡Increíble look!"', '15 min', Icons.comment, Color(0xFF9C27B0)),
      ('lucia.vintage', 'empezó a seguirte', '1h', Icons.person_add, Color(0xFF00BCD4)),
      ('andrea.glam', 'guardó tu publicación', '2h', Icons.bookmark, Color(0xFFFF9800)),
      ('carmen.b', 'mencionó en un comentario', '3h', Icons.alternate_email, Color(0xFF4CAF50)),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 10),
            const Text('Notificaciones', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                leading: CircleAvatar(backgroundColor: n.$5.withOpacity(0.12),
                    child: Icon(n.$4, color: n.$5, size: 18)),
                title: RichText(text: TextSpan(children: [
                  TextSpan(text: '${n.$1} ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D), fontSize: 13)),
                  TextSpan(text: n.$2, style: const TextStyle(color: Color(0xFF555555), fontSize: 13)),
                ])),
                trailing: Text(n.$3, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
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
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _filtered = _results.where((r) => r.contains(v.toLowerCase())).toList()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Color(0xFF9E9E9E)),
              hintText: 'Buscar usuarios, outfits...',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          ..._filtered.map((r) => ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFE8537A).withOpacity(0.12),
                child: Text(r[0].toUpperCase(), style: const TextStyle(color: Color(0xFFE8537A), fontWeight: FontWeight.bold))),
            title: Text(r),
            trailing: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE8537A),
                  side: const BorderSide(color: Color(0xFFE8537A)),
                  padding: const EdgeInsets.symmetric(horizontal: 14)),
              child: const Text('Seguir'),
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
