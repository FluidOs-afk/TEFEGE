import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../widgets/fashion_icon.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _profile = ProfileService.instance.profile;
    ProfileService.instance.addListener(_onProfileChanged);
    ProfileService.instance.load();
  }

  void _onProfileChanged() {
    if (mounted) setState(() => _profile = ProfileService.instance.profile);
  }

  @override
  void dispose() {
    ProfileService.instance.removeListener(_onProfileChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
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
                  onPressed: _openEditProfile),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final percent =
                    (constraints.maxHeight - kToolbarHeight) / 240;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient backdrop
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
                    // Profile card
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
          children: [_grid(), _grid(), _grid()],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar with gradient ring
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
              child: Text(_profile.initials,
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const Spacer(),
          // Edit button
          OutlinedButton(
            onPressed: _openEditProfile,
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
        Text(_profile.username,
            style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 3),
        if (_profile.location.isNotEmpty) ...[
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 13, color: AppColors.textHint),
            const SizedBox(width: 3),
            Text(_profile.location,
                style: GoogleFonts.dmSans(
                    color: AppColors.textHint, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
        ],
        if (_profile.bio.isNotEmpty)
          Text(_profile.bio,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSec,
                  height: 1.5)),
        const SizedBox(height: 14),
        // Stats row
        Row(children: [
          Expanded(child: _stat('24', 'Posts')),
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
          style:
              GoogleFonts.dmSans(fontSize: 10, color: AppColors.textHint)),
    ]);
  }

  // ─── Grid tiles ──────────────────────────────────────────────────────────────
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
            // Watermark
            Positioned(
              right: -8,
              bottom: -8,
              child: FashionIcon(
                category: cat,
                color: Colors.white.withOpacity(0.08),
                size: 64,
                strokeWidth: 1.5,
              ),
            ),
            // Centre icon
            Center(
              child: FashionIcon(
                category: cat,
                color: Colors.white.withOpacity(0.9),
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
