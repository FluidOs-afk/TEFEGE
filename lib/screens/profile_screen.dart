import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../models/user_post.dart';
import '../services/posts_service.dart';
import '../widgets/fashion_icon.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  final String _username = 'sergio.outfy';
  final String _bio =
      'Apasionado de la moda\nArmario curado con amor\nMadrid · DAM 2025';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    PostsService.instance.addListener(_onPostsChanged);
  }

  void _onPostsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    PostsService.instance.removeListener(_onPostsChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }

  void _confirmDelete(UserPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar publicación',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text(
            '¿Eliminar "${post.title}"? Esta acción no se puede deshacer.',
            style: GoogleFonts.dmSans(color: AppColors.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar',
                style: GoogleFonts.dmSans(color: AppColors.textSec)),
          ),
          TextButton(
            onPressed: () {
              PostsService.instance.remove(post.id);
              Navigator.of(ctx).pop();
            },
            child: Text('Eliminar',
                style: GoogleFonts.dmSans(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: _selectedTab == 0
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
                  onPressed: () {}),
              IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {}),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (ctx, constraints) {
                final percent =
                    (constraints.maxHeight - kToolbarHeight) / 240;
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
    final postCount = PostsService.instance.count;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: Center(
              child: Text('SR',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Editar perfil',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(_username,
            style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 3),
        Row(children: [
          const Icon(Icons.location_on_outlined,
              size: 13, color: AppColors.textHint),
          const SizedBox(width: 3),
          Text('Madrid, España',
              style: GoogleFonts.dmSans(
                  color: AppColors.textHint, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text(_bio,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.textSec, height: 1.5)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _stat('$postCount', 'Posts')),
          Container(width: 1, height: 28, color: AppColors.border),
          Expanded(child: _stat('1.2K', 'Seguidores')),
          Container(width: 1, height: 28, color: AppColors.border),
          Expanded(child: _stat('348', 'Siguiendo')),
          Container(width: 1, height: 28, color: AppColors.border),
          Expanded(child: _stat('48', 'Prendas')),
        ]),
      ]),
    );
  }

  Widget _stat(String value, String label) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(value,
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.primary)),
      const SizedBox(height: 1),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 10, color: AppColors.textHint)),
    ]);
  }

  // ─── Posts tab ────────────────────────────────────────────────────────────────
  Widget _postsTab() {
    final posts = PostsService.instance.posts;
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_off_rounded,
                size: 52, color: AppColors.textHint),
            const SizedBox(height: 14),
            Text('Sin publicaciones',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Pulsa + para crear tu primera publicación',
                style: GoogleFonts.dmSans(
                    color: AppColors.textHint, fontSize: 13)),
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
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(postId: post.id),
      ),
    );
  }

  Widget _postCell(UserPost post) {
    final hasPhoto =
        post.imagePath != null && File(post.imagePath!).existsSync();

    return GestureDetector(
      onTap: () => _openPost(post),
      onLongPress: () => _confirmDelete(post),
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
              child: Stack(fit: StackFit.expand, children: [
                Positioned(
                  right: -8, bottom: -8,
                  child: FashionIcon(
                    category: post.category,
                    color: Colors.white.withValues(alpha: 0.1),
                    size: 64, strokeWidth: 1.5,
                  ),
                ),
                Center(
                  child: FashionIcon(
                    category: post.category,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 30, strokeWidth: 1.8,
                  ),
                ),
              ]),
            ),
          // Título superpuesto
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(post.title,
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
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
          child: Stack(fit: StackFit.expand, children: [
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
          ]),
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.bgCard, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabDelegate old) => false;
}
