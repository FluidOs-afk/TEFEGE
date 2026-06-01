import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart' show AppColors;

class AvatarWithFrame extends StatelessWidget {
  final String? base64;
  final String frameStyle; // 'none', 'green', 'gradient', 'gold'
  final double radius;
  final VoidCallback? onTap;
  final String? initials;

  const AvatarWithFrame({
    super.key,
    this.base64,
    this.frameStyle = 'none',
    this.radius = 24,
    this.onTap,
    this.initials,
  });

  bool get _hasImage => base64 != null && base64!.isNotEmpty;

  ImageProvider? _imageProvider() {
    if (!_hasImage) return null;
    try {
      return MemoryImage(base64Decode(base64!));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = _buildFramed();
    return onTap != null ? GestureDetector(onTap: onTap, child: w) : w;
  }

  Widget _buildFramed() {
    final avatar = _buildAvatar();
    switch (frameStyle) {
      case 'green':
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: avatar,
        );
      case 'gradient':
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: avatar,
        );
      case 'gold':
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
          ),
          child: avatar,
        );
      default:
        return avatar;
    }
  }

  Widget _buildAvatar() {
    final img = _imageProvider();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.accentBg,
      backgroundImage: img,
      child: img == null
          ? (initials != null && initials!.isNotEmpty
              ? Text(
                  initials!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.55,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Icon(Icons.person_rounded,
                  size: radius * 0.9, color: AppColors.primaryMed))
          : null,
    );
  }
}
