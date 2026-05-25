import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;

class LegalScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.4,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.textSec, size: 20),
            tooltip: 'Compartir',
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'No se pudo cargar el documento',
                    style: GoogleFonts.dmSans(
                        color: AppColors.textSec, fontSize: 15),
                  ),
                ],
              ),
            );
          }
          return Markdown(
            data: snapshot.data!,
            selectable: true,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
            styleSheet: _buildStyleSheet(context),
          );
        },
      ),
    );
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    final base = GoogleFonts.dmSans();
    return MarkdownStyleSheet(
      h1: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      h2: GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      h3: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.4,
      ),
      p: GoogleFonts.dmSans(
        fontSize: 13.5,
        color: AppColors.textSec,
        height: 1.65,
      ),
      strong: GoogleFonts.dmSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      em: base.copyWith(
        fontSize: 13.5,
        fontStyle: FontStyle.italic,
        color: AppColors.textSec,
      ),
      a: GoogleFonts.dmSans(
        fontSize: 13.5,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      ),
      listBullet: GoogleFonts.dmSans(
        fontSize: 13.5,
        color: AppColors.textSec,
      ),
      blockquote: GoogleFonts.dmSans(
        fontSize: 13,
        color: AppColors.textSec,
        fontStyle: FontStyle.italic,
      ),
      code: GoogleFonts.robotoMono(
        fontSize: 12,
        backgroundColor: AppColors.bgPage,
        color: AppColors.primary,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 6),
      h2Padding: const EdgeInsets.only(top: 20, bottom: 4),
      h3Padding: const EdgeInsets.only(top: 12, bottom: 2),
      pPadding: const EdgeInsets.only(bottom: 6),
      tableHead: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      tableBody: GoogleFonts.dmSans(
        fontSize: 12,
        color: AppColors.textSec,
      ),
      tableHeadAlign: TextAlign.left,
      tableBorder: TableBorder.all(
        color: AppColors.border,
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    );
  }
}
