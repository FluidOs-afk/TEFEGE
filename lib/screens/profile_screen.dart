import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final String _username = 'sergio.outfy';
  final String _bio =
      '✨ Apasionado de la moda\n🧥 Armario curado con amor\n📍 Madrid · DAM 2025';

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  Widget _divider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            actions: const [
              Icon(Icons.share_outlined),
              SizedBox(width: 12),
              Icon(Icons.settings_outlined),
              SizedBox(width: 12),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final percent =
                    (constraints.maxHeight - kToolbarHeight) / 240;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient Header
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFE8537A),
                            Color(0xFFFF8FAB),
                            Color(0xFFFFC2D4)
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Opacity(
                        opacity: percent.clamp(0, 1),
                        child: _buildHeaderContent(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabDelegate(
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFE8537A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFE8537A),
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on_rounded)),
                  Tab(icon: Icon(Icons.checkroom_rounded)),
                  Tab(icon: Icon(Icons.bookmark_border)),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _grid(),
            _grid(),
            _grid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8537A), Color(0xFFFF8FAB)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SR',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),

              const Spacer(),

              // Edit button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Editar perfil"),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _username,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          const Text(
            "Madrid, España 🇪🇸",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 8),

          Text(_bio),

          const SizedBox(height: 16),

          // 🔥 STATS PERFECTOS (SIN OVERFLOW)
          Row(
            children: [
              Expanded(child: _stat("24", "Posts")),
              _divider(),
              Expanded(child: _stat("1.2K", "Seguidores")),
              _divider(),
              Expanded(child: _stat("348", "Siguiendo")),
              _divider(),
              Expanded(child: _stat("48", "Prendas")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

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
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabDelegate oldDelegate) => false;
}