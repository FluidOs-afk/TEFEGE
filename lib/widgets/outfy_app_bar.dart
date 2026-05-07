import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;

class OutfyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBrandTitle;

  const OutfyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBrandTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgCard,
      elevation: 0,
      scrolledUnderElevation: 0.4,
      centerTitle: true,
      title: showBrandTitle
          ? ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryMed],
              ).createShader(bounds),
              child: Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            )
          : Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
