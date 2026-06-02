import 'package:flutter/material.dart';
import '../main.dart' show AppColorsExt;

class FeedSkeletonItem extends StatefulWidget {
  const FeedSkeletonItem({super.key});

  @override
  State<FeedSkeletonItem> createState() => _FeedSkeletonItemState();
}

class _FeedSkeletonItemState extends State<FeedSkeletonItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final base = isDark
            ? Color.lerp(const Color(0xFF2A1F4A), const Color(0xFF1C1040), _anim.value)!
            : Color.lerp(const Color(0xFFEDE8F8), const Color(0xFFF5F0FF), _anim.value)!;
        return Container(
          color: context.colBgCard,
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(children: [
                  _Box(width: 44, height: 44, radius: 22, color: base),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Box(width: 110, height: 12, radius: 4, color: base),
                    const SizedBox(height: 6),
                    _Box(width: 60, height: 10, radius: 4, color: base),
                  ]),
                ]),
              ),
              _Box(
                width: double.infinity, height: 360,
                radius: 0, color: base,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Box(width: 90, height: 12, radius: 4, color: base),
                    const SizedBox(height: 8),
                    _Box(width: double.infinity, height: 11, radius: 4, color: base),
                    const SizedBox(height: 5),
                    _Box(width: 180, height: 11, radius: 4, color: base),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  final double width, height, radius;
  final Color color;
  const _Box({
    required this.width, required this.height,
    required this.radius, required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width, height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
