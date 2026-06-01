import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors, AppColorsExt;
import '../screens/messages_list_screen.dart';

class ShareSheet extends StatelessWidget {
  final String postId;
  final String postTitle;

  const ShareSheet({super.key, required this.postId, required this.postTitle});

  String get _link => 'outfy://post/$postId';

  Future<void> _launchExternal(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enlace copiado. Pégalo en la app correspondiente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colBgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: context.colBorder, borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Text('Compartir',
                    style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: context.colText)),
                const Spacer(),
                Flexible(
                  child: Text(postTitle,
                      style: GoogleFonts.dmSans(fontSize: 12, color: context.colTextHint),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _ShareOption(
                  icon: Icons.mail_outline_rounded,
                  label: 'Mensaje\nprivado',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MessagesListScreen()));
                  },
                ),
                _ShareOption(
                  icon: Icons.copy_rounded,
                  label: 'Copiar\nenlace',
                  color: const Color(0xFF6B7280),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: _link));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enlace copiado al portapapeles')));
                    }
                  },
                ),
                _ShareOption(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _launchExternal(
                      context,
                      'https://wa.me/?text=${Uri.encodeComponent('$postTitle\n$_link')}'),
                ),
                _ShareOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () => _launchExternal(context, 'instagram://app'),
                ),
                _ShareOption(
                  icon: Icons.telegram_rounded,
                  label: 'Telegram',
                  color: const Color(0xFF0088CC),
                  onTap: () => _launchExternal(
                      context,
                      'https://t.me/share/url?url=${Uri.encodeComponent(_link)}&text=${Uri.encodeComponent(postTitle)}'),
                ),
                _ShareOption(
                  icon: Icons.more_horiz_rounded,
                  label: 'Más\nopciones',
                  color: const Color(0xFF9CA3AF),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: '$postTitle\n$_link'));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contenido copiado. Pégalo donde quieras.')));
                    }
                  },
                ),
              ]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w600, color: context.colTextSec),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}
