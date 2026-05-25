import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart' show AppColors;
import '../models/post_model.dart';
import '../services/profile_service.dart';
import '../widgets/fashion_icon.dart';
import 'profile_screen.dart';
import 'user_search_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _activeFilter = 0;
  bool _hasUnreadNotifications = true;
  final ImagePicker _picker = ImagePicker();
  final Set<String> _followingUsers = {};

  final List<String> _filters = ['Para ti', 'Siguiendo', 'Tendencias', 'Cerca'];

  final List<PostModel> _posts = [
    const PostModel(
      userId: 'u_sofia',
      username: 'sofia.styles',
      avatar: 'S',
      avatarColor: Color(0xFF3CB87A),
      timeAgo: 'Hace 12 min',
      outfitTitle: 'Look casual viernes',
      description:
          'Mi look favorito para el trabajo: blazer oversize y vaqueros slouchy. Comodidad sin sacrificar estilo.',
      likes: 3420,
      comments: 4,
      tags: ['Casual', 'Oficina', 'OOTD'],
      placeholderColor: Color(0xFF1B6B44),
      placeholderColorEnd: Color(0xFF3CB87A),
      fashionCategory: FashionCategory.tops,
      isLiked: true,
    ),
    const PostModel(
      userId: 'u_marta',
      username: 'marta.fashion',
      avatar: 'M',
      avatarColor: Color(0xFF8E44AD),
      timeAgo: 'Hace 1 h',
      outfitTitle: 'Streetwear primavera',
      description:
          'Tonos pastel para celebrar la primavera. Coral, lavanda y zapatillas limpias para todo el dia.',
      likes: 8910,
      comments: 3,
      tags: ['Streetwear', 'Pastel', 'Spring'],
      placeholderColor: Color(0xFF6A4C93),
      placeholderColorEnd: Color(0xFFEAC7C7),
      fashionCategory: FashionCategory.pants,
      isLiked: false,
    ),
    const PostModel(
      userId: 'u_lucia',
      username: 'lucia.vintage',
      avatar: 'L',
      avatarColor: Color(0xFF9A6B4F),
      timeAgo: 'Hace 3 h',
      outfitTitle: 'Vintage meets modern',
      description:
          'Abrigo de lana del mercadillo de Malasana por 15 euros. La segunda mano tambien puede verse premium.',
      likes: 12430,
      comments: 3,
      tags: ['Vintage', 'Thrift', 'Sostenible'],
      placeholderColor: Color(0xFF5D4E46),
      placeholderColorEnd: Color(0xFFD7B49E),
      fashionCategory: FashionCategory.coat,
      isLiked: false,
    ),
    const PostModel(
      userId: 'u_andrea',
      username: 'andrea.glam',
      avatar: 'A',
      avatarColor: Color(0xFF455A64),
      timeAgo: 'Hace 5 h',
      outfitTitle: 'Night out ready',
      description:
          'Vestido satinado, sandalias doradas y bolso pequeno. Para salir elegante sin parecer demasiado producida.',
      likes: 21040,
      comments: 2,
      tags: ['NightOut', 'Elegante', 'Summer'],
      placeholderColor: Color(0xFF263238),
      placeholderColorEnd: Color(0xFF8EA4B2),
      fashionCategory: FashionCategory.dress,
      isLiked: false,
    ),
  ];

  final List<_Story> _stories = [
    _Story(
      userId: 'u_sofia',
      label: 'sofia.s',
      color: const Color(0xFF1B6B44),
      initial: 'S',
      hasNew: true,
      title: 'Capsula de oficina',
      detail: 'Blazer, denim recto y mocasin pulido.',
      category: FashionCategory.tops,
    ),
    _Story(
      userId: 'u_marta',
      label: 'marta.f',
      color: const Color(0xFF8E44AD),
      initial: 'M',
      hasNew: true,
      title: 'Paleta pastel',
      detail: 'Coral suave con lavanda y accesorios plata.',
      category: FashionCategory.pants,
    ),
    _Story(
      userId: 'u_lucia',
      label: 'lucia.v',
      color: const Color(0xFF9A6B4F),
      initial: 'L',
      hasNew: false,
      title: 'Hallazgo vintage',
      detail: 'Abrigo de lana, cuello alto y bolso estructurado.',
      category: FashionCategory.coat,
    ),
    _Story(
      userId: 'u_andrea',
      label: 'andrea.g',
      color: const Color(0xFF455A64),
      initial: 'A',
      hasNew: true,
      title: 'Noche satinada',
      detail: 'Texturas brillantes con sandalias finas.',
      category: FashionCategory.dress,
    ),
    _Story(
      userId: 'u_carmen',
      label: 'carmen.b',
      color: const Color(0xFF00838F),
      initial: 'C',
      hasNew: false,
      title: 'Azules limpios',
      detail: 'Camisa abierta, camiseta blanca y pantalon amplio.',
      category: FashionCategory.accessory,
    ),
    _Story(
      userId: 'u_paula',
      label: 'paula.m',
      color: const Color(0xFF2E7D32),
      initial: 'P',
      hasNew: false,
      title: 'Verde urbano',
      detail: 'Cargo fluido con top negro y bolso mini.',
      category: FashionCategory.shoes,
    ),
  ];

  final Map<String, List<Map<String, String>>> _commentsByPost = {
    'sofia.styles': [
      {
        'user': 'carmen.b',
        'text': 'Esta combinacion es perfecta. Donde es el blazer?',
        'time': '5 min',
      },
      {
        'user': 'ana.trends',
        'text': 'Me tienes obsesionada con este look',
        'time': '12 min',
      },
      {
        'user': 'paula.style',
        'text': 'Inspiracion total para manana',
        'time': '23 min',
      },
      {
        'user': 'sara.moda',
        'text': 'Los colores tierra son mi nueva obsesion',
        'time': '1 h',
      },
    ],
    'marta.fashion': [
      {
        'user': 'sofia.styles',
        'text': 'El lavanda con coral queda increible.',
        'time': '8 min',
      },
      {
        'user': 'nerea.fit',
        'text': 'Necesito esas zapatillas.',
        'time': '19 min',
      },
      {
        'user': 'laura.mod',
        'text': 'Muy primaveral y nada obvio.',
        'time': '1 h',
      },
    ],
    'lucia.vintage': [
      {
        'user': 'marta.fashion',
        'text': 'Ese abrigo parece de boutique.',
        'time': '14 min',
      },
      {'user': 'carmen.b', 'text': 'Malasana nunca falla.', 'time': '36 min'},
      {
        'user': 'alba.slow',
        'text': 'Mas looks sostenibles asi, por favor.',
        'time': '2 h',
      },
    ],
    'andrea.glam': [
      {
        'user': 'paula.style',
        'text': 'Elegante sin pasarse. Perfecto.',
        'time': '20 min',
      },
      {
        'user': 'sofia.styles',
        'text': 'El bolso pequeno lo cambia todo.',
        'time': '1 h',
      },
    ],
  };

  List<PostModel> get _visiblePosts {
    switch (_activeFilter) {
      case 1:
        return _posts
            .where((post) => _followingUsers.contains(post.username))
            .toList();
      case 2:
        return [..._posts]..sort((a, b) => b.likes.compareTo(a.likes));
      case 3:
        return _posts
            .where((post) => post.tags.any((tag) => tag != 'Summer'))
            .toList();
      default:
        return _posts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = _visiblePosts;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 550));
          if (!mounted) return;
          setState(() => _hasUnreadNotifications = true);
          _toast('Inicio actualizado');
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.bgCard,
              elevation: 0,
              scrolledUnderElevation: 0.3,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryMed],
                ).createShader(bounds),
                child: Text(
                  'OUTFY',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 5,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Notificaciones',
                  onPressed: () {
                    setState(() => _hasUnreadNotifications = false);
                    _showNotifications(context);
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                      if (_hasUnreadNotifications)
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryMed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Buscar',
                  onPressed: () => _showSearch(context),
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.bgCard,
                padding: const EdgeInsets.only(bottom: 14, top: 6),
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _stories.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) return _buildMyStory(context);
                      return _buildStoryItem(index - 1);
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 1, color: AppColors.border),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterDelegate(
                filters: _filters,
                activeFilter: _activeFilter,
                onChanged: (index) => setState(() => _activeFilter = index),
              ),
            ),
            SliverToBoxAdapter(
              child: _FeedStatusBar(
                title: _filters[_activeFilter],
                subtitle:
                    '${posts.length} looks seleccionados para inspirarte hoy',
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((_, index) {
                if (index == posts.length) return const SizedBox(height: 20);
                final post = posts[index];
                final realIndex = _posts.indexWhere(
                  (item) => item.username == post.username,
                );

                return _PostCard(
                  key: ValueKey(post.username),
                  post: post,
                  isFollowing: _followingUsers.contains(post.username),
                  onFollowChanged: () => _toggleFollow(post.username),
                  onLike: () => setState(() {
                    final current = _posts[realIndex];
                    _posts[realIndex] = current.copyWith(
                      isLiked: !current.isLiked,
                      likes: current.isLiked
                          ? current.likes - 1
                          : current.likes + 1,
                    );
                  }),
                  onComment: () => _showComments(context, post),
                  onOpenOutfit: () => _showOutfitPreview(context, post),
                );
              }, childCount: posts.length + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyStory(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateStory(context),
      child: const _StoryBubble(
        initial: '+',
        label: 'Tu historia',
        color: AppColors.primaryMed,
        hasNew: false,
        isMe: true,
      ),
    );
  }

  Widget _buildStoryItem(int index) {
    final story = _stories[index];
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder<void>(
            opaque: false,
            barrierColor: Colors.black,
            pageBuilder: (_, _, _) => _StoryViewer(
              stories: _stories,
              initialIndex: index,
              onViewed: (viewedIndex) {
                if (!mounted) return;
                setState(() {
                  _stories[viewedIndex] = _stories[viewedIndex].copyWith(
                    hasNew: false,
                  );
                });
              },
            ),
          ),
        );
      },
      child: _StoryBubble(
        initial: story.initial,
        label: story.label.length > 8
            ? '${story.label.substring(0, 7)}...'
            : story.label,
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
                _SheetHandle(),
                const SizedBox(height: 18),
                Text(
                  'Crear historia',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige un formato rapido para mostrar tu outfit. Es una maqueta funcional en memoria.',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSec,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionTile(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camara',
                        onTap: () {
                          Navigator.pop(context);
                          _pickStoryImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionTile(
                        icon: Icons.photo_library_outlined,
                        title: 'Galeria',
                        onTap: () {
                          Navigator.pop(context);
                          _pickStoryImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickStoryImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 86,
      maxWidth: 1400,
    );
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      _stories.insert(
        0,
        _Story(
          userId: ProfileService.instance.profile.userId,
          label: 'tu.look',
          color: AppColors.primary,
          initial: 'T',
          hasNew: true,
          title: source == ImageSource.camera ? 'Foto nueva' : 'Desde galeria',
          detail: 'Historia creada durante esta sesion.',
          category: FashionCategory.tops,
          imageBytes: bytes,
        ),
      );
    });
    _toast('Historia creada');
  }

  void _toggleFollow(String username) {
    setState(() {
      _followingUsers.contains(username)
          ? _followingUsers.remove(username)
          : _followingUsers.add(username);
    });
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: DraggableScrollableSheet(
          initialChildSize: 0.56,
          minChildSize: 0.35,
          maxChildSize: 0.88,
          expand: false,
          builder: (_, controller) =>
              _NotificationsSheet(controller: controller),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UserSearchScreen()));
  }

  void _showComments(BuildContext context, PostModel post) {
    final comments = _commentsByPost.putIfAbsent(post.username, () => []);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: DraggableScrollableSheet(
          initialChildSize: 0.68,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, controller) => _CommentsSheet(
            scrollController: controller,
            username: post.username,
            comments: comments,
            onChanged: () => _syncCommentCount(post.username),
          ),
        ),
      ),
    );
  }

  void _syncCommentCount(String username) {
    final index = _posts.indexWhere((post) => post.username == username);
    if (index == -1) return;
    setState(() {
      _posts[index] = _posts[index].copyWith(
        comments: _commentsByPost[username]?.length ?? 0,
      );
    });
  }

  void _showOutfitPreview(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(child: _OutfitPreview(post: post)),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _Story {
  final String userId;
  final String label;
  final String initial;
  final Color color;
  final bool hasNew;
  final String title;
  final String detail;
  final FashionCategory category;
  final Uint8List? imageBytes;

  const _Story({
    required this.userId,
    required this.label,
    required this.color,
    required this.initial,
    required this.hasNew,
    required this.title,
    required this.detail,
    required this.category,
    this.imageBytes,
  });

  _Story copyWith({bool? hasNew}) => _Story(
    userId: userId,
    label: label,
    color: color,
    initial: initial,
    hasNew: hasNew ?? this.hasNew,
    title: title,
    detail: detail,
    category: category,
    imageBytes: imageBytes,
  );
}

class _StoryBubble extends StatelessWidget {
  final String initial;
  final String label;
  final Color color;
  final bool hasNew;
  final bool isMe;

  const _StoryBubble({
    required this.initial,
    required this.label,
    required this.color,
    required this.hasNew,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasNew
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: hasNew ? null : AppColors.border,
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCard,
              ),
              padding: const EdgeInsets.all(2),
              child: isMe
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBg,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: color,
                      child: Text(
                        initial,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: hasNew ? FontWeight.w700 : FontWeight.w500,
              color: hasNew ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryViewer extends StatefulWidget {
  final List<_Story> stories;
  final int initialIndex;
  final ValueChanged<int> onViewed;

  const _StoryViewer({
    required this.stories,
    required this.initialIndex,
    required this.onViewed,
  });

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer> {
  late final PageController _controller;
  late int _index;
  Timer? _timer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onViewed(_index);
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;
      setState(() => _progress = (_progress + 0.02).clamp(0, 1));
      if (_progress >= 1) _next();
    });
  }

  void _next() {
    if (_index == widget.stories.length - 1) {
      Navigator.pop(context);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    if (_index == 0) {
      _startTimer();
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openProfile(_Story story) async {
    _timer?.cancel();
    final currentUserId = ProfileService.instance.profile.userId;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => story.userId == currentUserId
            ? const ProfileScreen()
            : ProfileScreen(userId: story.userId),
      ),
    );
    if (mounted) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.stories.length,
              onPageChanged: (value) {
                setState(() => _index = value);
                widget.onViewed(value);
                _startTimer();
              },
              itemBuilder: (_, index) => _StoryPage(
                story: widget.stories[index],
                onProfileTap: _openProfile,
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  final value = index < _index
                      ? 1.0
                      : (index == _index ? _progress : 0.0);
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.28),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Positioned.fill(
              top: 112,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _previous,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _next,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 24,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  final _Story story;
  final ValueChanged<_Story> onProfileTap;

  const _StoryPage({required this.story, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [story.color, Color.lerp(story.color, Colors.black, 0.52)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 58, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onProfileTap(story),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.18),
                    child: Text(
                      story.initial,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    story.label,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: story.imageBytes == null
                  ? Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: Center(
                        child: FashionIcon(
                          category: story.category,
                          color: Colors.white,
                          size: 112,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.memory(
                        story.imageBytes!,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.52,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const Spacer(),
            Text(
              story.title,
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              story.detail,
              style: GoogleFonts.dmSans(
                color: Colors.white.withOpacity(0.86),
                fontSize: 15,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            _PillButton(
              icon: Icons.bookmark_add_outlined,
              label: 'Guardar idea',
              color: Colors.white,
              foreground: AppColors.textPrimary,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Idea guardada de ${story.label}')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final List<String> filters;
  final int activeFilter;
  final ValueChanged<int> onChanged;

  const _FilterDelegate({
    required this.filters,
    required this.activeFilter,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.bgCard,
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        itemBuilder: (_, index) {
          final isActive = activeFilter == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.bgPage,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                filters[index],
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSec,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 54;

  @override
  double get minExtent => 54;

  @override
  bool shouldRebuild(_FilterDelegate oldDelegate) =>
      oldDelegate.activeFilter != activeFilter;
}

class _FeedStatusBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FeedStatusBar({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgPage,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSec,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  'Filtros',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final PostModel post;
  final bool isFollowing;
  final VoidCallback onFollowChanged;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onOpenOutfit;

  const _PostCard({
    super.key,
    required this.post,
    required this.isFollowing,
    required this.onFollowChanged,
    required this.onLike,
    required this.onComment,
    required this.onOpenOutfit,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard>
    with SingleTickerProviderStateMixin {
  bool _saved = false;
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _heartScale = Tween<double>(
      begin: 0.7,
      end: 1.45,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_heartController);
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleLike() {
    HapticFeedback.selectionClick();
    widget.onLike();
    _heartController.forward(from: 0);
  }

  String _fmt(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000)
      return '${(value / 1000).toStringAsFixed(value % 1000 >= 100 ? 1 : 0)}K';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
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
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(userId: widget.post.userId),
                    ),
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
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
                      backgroundColor: widget.post.avatarColor,
                      child: Text(
                        widget.post.avatar,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileScreen(userId: widget.post.userId),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.post.timeAgo,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onFollowChanged,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(78, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    foregroundColor: widget.isFollowing
                        ? AppColors.textSec
                        : AppColors.primary,
                    backgroundColor: widget.isFollowing
                        ? AppColors.bgPage
                        : AppColors.accentBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.isFollowing ? 'Siguiendo' : 'Seguir',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mas opciones',
                  onPressed: () => _showOptions(context),
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onOpenOutfit,
            onDoubleTap: _handleLike,
            child: SizedBox(
              width: double.infinity,
              height: 390,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.post.placeholderColor,
                          widget.post.placeholderColorEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    bottom: -34,
                    child: FashionIcon(
                      category: widget.post.fashionCategory,
                      color: Colors.white.withOpacity(0.07),
                      size: 310,
                      strokeWidth: 3,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                        ),
                      ),
                      child: Center(
                        child: FashionIcon(
                          category: widget.post.fashionCategory,
                          color: Colors.white.withOpacity(0.92),
                          size: 76,
                          strokeWidth: 2.2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 72, 16, 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.68),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.post.outfitTitle,
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _MiniOverlayButton(
                            label: 'Ver outfit',
                            onTap: widget.onOpenOutfit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedBuilder(
                      animation: _heartController,
                      builder: (_, _) {
                        if (_heartController.value == 0 ||
                            _heartController.value == 1) {
                          return const SizedBox.shrink();
                        }
                        return Transform.scale(
                          scale: _heartScale.value,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.white.withOpacity(
                              1 - _heartController.value,
                            ),
                            size: 88,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _ActionBtn(
                  icon: widget.post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: widget.post.isLiked
                      ? const Color(0xFFE74C3C)
                      : AppColors.textPrimary,
                  onTap: _handleLike,
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
                  icon: _saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _saved ? AppColors.primary : AppColors.textPrimary,
                  onTap: () {
                    setState(() => _saved = !_saved);
                    _toast(
                      context,
                      _saved ? 'Publicacion guardada' : 'Guardado eliminado',
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_fmt(widget.post.likes)} me gusta',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.post.username}  ',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: widget.post.description,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSec,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.post.tags
                      .map(
                        (tag) => GestureDetector(
                          onTap: () => _toast(context, 'Explorando #$tag'),
                          child: Text(
                            '#$tag',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: widget.onComment,
                  child: Text(
                    'Ver los ${_fmt(widget.post.comments)} comentarios',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w600,
                    ),
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
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _SheetHandle(),
              const SizedBox(height: 8),
              _OptionTile(
                icon: _saved
                    ? Icons.bookmark_remove_outlined
                    : Icons.bookmark_add_outlined,
                title: _saved ? 'Quitar guardado' : 'Guardar publicacion',
                onTap: () {
                  setState(() => _saved = !_saved);
                  Navigator.pop(context);
                  _toast(
                    context,
                    _saved ? 'Publicacion guardada' : 'Guardado eliminado',
                  );
                },
              ),
              _OptionTile(
                icon: Icons.share_outlined,
                title: 'Compartir',
                onTap: () {
                  Navigator.pop(context);
                  _sharePost(context);
                },
              ),
              _OptionTile(
                icon: widget.isFollowing
                    ? Icons.person_remove_outlined
                    : Icons.person_add_outlined,
                title: widget.isFollowing
                    ? 'Dejar de seguir a @${widget.post.username}'
                    : 'Seguir a @${widget.post.username}',
                onTap: () {
                  widget.onFollowChanged();
                  Navigator.pop(context);
                  _toast(
                    context,
                    widget.isFollowing
                        ? 'Ya no sigues a @${widget.post.username}'
                        : 'Ahora sigues a @${widget.post.username}',
                  );
                },
              ),
              _OptionTile(
                icon: Icons.flag_outlined,
                title: 'Reportar',
                danger: true,
                onTap: () {
                  Navigator.pop(context);
                  _toast(context, 'Reporte enviado para revision');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _sharePost(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: 'https://outfy.app/post/${widget.post.username}'),
    );
    _toast(context, 'Enlace copiado al portapapeles');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 24, color: color),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      splashRadius: 22,
    );
  }
}

class _MiniOverlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MiniOverlayButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

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

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgPage,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFD64545) : AppColors.primary;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700,
          color: danger ? color : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String username;
  final List<Map<String, String>> comments;
  final VoidCallback onChanged;

  const _CommentsSheet({
    required this.scrollController,
    required this.username,
    required this.comments,
    required this.onChanged,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            children: [
              _SheetHandle(),
              const SizedBox(height: 12),
              Text(
                'Comentarios',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '@${widget.username}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: widget.comments.length,
            itemBuilder: (_, index) =>
                _CommentRow(comment: widget.comments[index]),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 14,
            right: 14,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 14,
          ),
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.accentBg,
                child: Icon(Icons.person, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 3,
                  style: GoogleFonts.dmSans(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Anade un comentario...',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    widget.comments.insert(0, {
                      'user': 'tu',
                      'text': text,
                      'time': 'Ahora',
                    });
                    _controller.clear();
                  });
                  widget.onChanged();
                },
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 17,
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
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.accentBg,
            child: Text(
              comment['user']![0].toUpperCase(),
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment['user']}  ',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: comment['text'],
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSec,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment['time']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSheet extends StatefulWidget {
  final ScrollController controller;

  const _NotificationsSheet({required this.controller});

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late final List<_NotificationItem> _items = [
    _NotificationItem(
      'sofia.styles',
      'le dio like a tu outfit',
      '2 min',
      Icons.favorite_rounded,
      AppColors.primaryMed,
    ),
    _NotificationItem(
      'marta.fashion',
      'comento tu publicacion',
      '15 min',
      Icons.chat_bubble_rounded,
      const Color(0xFF8E44AD),
    ),
    _NotificationItem(
      'lucia.vintage',
      'empezo a seguirte',
      '1 h',
      Icons.person_add_rounded,
      const Color(0xFF00838F),
    ),
    _NotificationItem(
      'andrea.glam',
      'guardo tu publicacion',
      '2 h',
      Icons.bookmark_rounded,
      const Color(0xFFFF9800),
    ),
    _NotificationItem(
      'carmen.b',
      'te menciono en un comentario',
      '3 h',
      Icons.alternate_email,
      const Color(0xFF2E7D32),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            children: [
              _SheetHandle(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notificaciones',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _items.clear()),
                    child: Text(
                      'Limpiar',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _items.isEmpty
              ? Center(
                  child: Text(
                    'Todo al dia',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: widget.controller,
                  itemCount: _items.length,
                  itemBuilder: (_, index) {
                    final item = _items[index];
                    return Dismissible(
                      key: ValueKey('${item.user}-${item.time}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: const Color(0xFFD64545),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) =>
                          setState(() => _items.removeAt(index)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${item.user}  ',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: item.text,
                                style: GoogleFonts.dmSans(
                                  color: AppColors.textSec,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Text(
                          item.time,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Abriendo actividad de ${item.user}'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NotificationItem {
  final String user;
  final String text;
  final String time;
  final IconData icon;
  final Color color;

  const _NotificationItem(
    this.user,
    this.text,
    this.time,
    this.icon,
    this.color,
  );
}

class _SearchSheet extends StatefulWidget {
  final ValueChanged<String> onSelect;

  const _SearchSheet({required this.onSelect});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  final Set<String> _following = {};
  final List<_SearchResult> _results = const [
    _SearchResult('sofia.styles', 'Capsulas de oficina', Icons.work_outline),
    _SearchResult(
      'marta.fashion',
      'Streetwear y color',
      Icons.palette_outlined,
    ),
    _SearchResult(
      'lucia.vintage',
      'Vintage sostenible',
      Icons.recycling_outlined,
    ),
    _SearchResult('andrea.glam', 'Looks de noche', Icons.nightlife_outlined),
    _SearchResult('carmen.b', 'Minimal mediterraneo', Icons.wb_sunny_outlined),
    _SearchResult('#Oficina', 'Blazers, mocasines y denim', Icons.tag),
    _SearchResult('#Sostenible', 'Ideas de segunda mano', Icons.eco_outlined),
  ];

  String _query = '';

  List<_SearchResult> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _results;
    return _results
        .where(
          (item) =>
              item.title.toLowerCase().contains(query) ||
              item.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.74,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              style: GoogleFonts.dmSans(fontSize: 14),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                hintText: 'Buscar usuarios, outfits, estilos...',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Sin resultados',
                        style: GoogleFonts.dmSans(color: AppColors.textHint),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final result = filtered[index];
                        final isFollowing = _following.contains(result.title);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.accentBg,
                            child: Icon(
                              result.icon,
                              color: AppColors.primary,
                              size: 19,
                            ),
                          ),
                          title: Text(
                            result.title,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            result.subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                          trailing: result.title.startsWith('#')
                              ? const Icon(Icons.chevron_right_rounded)
                              : TextButton(
                                  onPressed: () => setState(() {
                                    isFollowing
                                        ? _following.remove(result.title)
                                        : _following.add(result.title);
                                  }),
                                  style: TextButton.styleFrom(
                                    foregroundColor: isFollowing
                                        ? AppColors.textSec
                                        : AppColors.primary,
                                    backgroundColor: isFollowing
                                        ? AppColors.bgPage
                                        : AppColors.accentBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isFollowing ? 'Siguiendo' : 'Seguir',
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSelect(result.title);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SearchResult(this.title, this.subtitle, this.icon);
}

class _OutfitPreview extends StatelessWidget {
  final PostModel post;

  const _OutfitPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            const SizedBox(height: 18),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [post.placeholderColor, post.placeholderColorEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: FashionIcon(
                  category: post.fashionCategory,
                  color: Colors.white,
                  size: 82,
                  strokeWidth: 2.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              post.outfitTitle,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.description,
              style: GoogleFonts.dmSans(
                color: AppColors.textSec,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: post.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      avatar: const Icon(
                        Icons.tag,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Look anadido a favoritos')),
                    ),
                    icon: const Icon(Icons.favorite_border_rounded, size: 18),
                    label: const Text('Inspirarme'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: 'https://outfy.app/outfit/${post.username}',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Outfit copiado')),
                    );
                  },
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
