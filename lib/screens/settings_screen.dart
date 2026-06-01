import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show AppColors, AppColorsExt;
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/profile_service.dart';
import '../services/wardrobe_service.dart';
import '../widgets/avatar_with_frame.dart';
import 'edit_profile_screen.dart';
import 'legal_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _pushEnabled = prefs.getBool('push_enabled') ?? true);
  }

  Future<void> _setPush(bool v) async {
    setState(() => _pushEnabled = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_enabled', v);
  }

  Future<void> _sendPasswordReset() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de recuperación enviado a $email', style: GoogleFonts.dmSans())),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el email', style: GoogleFonts.dmSans())),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar sesión', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('¿Seguro que quieres cerrar sesión?',
            style: GoogleFonts.dmSans(color: context.colTextSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: GoogleFonts.dmSans(color: context.colTextSec)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const LoginScreen(),
                  transitionsBuilder: (_, anim, _, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
                (_) => false,
              );
            },
            child: Text('Cerrar sesión',
                style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar cuenta',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Esta acción es irreversible',
                    style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 12),
            Text(
              'Se eliminarán todas tus publicaciones, prendas del armario, outfits guardados y tu perfil de forma permanente.',
              style: GoogleFonts.dmSans(color: context.colTextSec, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: GoogleFonts.dmSans(color: context.colTextSec)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.of(ctx).pop(); _deleteAccount(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('Eliminar todo', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    setState(() => _deletingAccount = true);
    try {
      final db = FirebaseFirestore.instance;
      final postsSnap = await db.collection('posts').where('userId', isEqualTo: uid).get();
      for (final doc in postsSnap.docs) { await doc.reference.delete(); }
      final items = await WardrobeService.instance.getItems(uid);
      for (final item in items) { await WardrobeService.instance.deleteItem(uid, item.id); }
      await db.collection('users').doc(uid).delete();
      await FirebaseAuth.instance.currentUser?.delete();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar la cuenta. Es posible que necesites volver a iniciar sesión.',
            style: GoogleFonts.dmSans()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final themeProvider = context.watch<ThemeProvider>();

    if (_deletingAccount) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Eliminando cuenta...', style: GoogleFonts.dmSans(color: context.colTextSec, fontSize: 14)),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildProfileCard(context, user),
          const SizedBox(height: 24),

          // ── Cuenta ───────────────────────────────────────────────
          _sectionLabel(context, 'Cuenta'),
          _settingsCard(context, [
            _navTile(context,
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primary,
              title: 'Editar perfil',
              subtitle: 'Nombre, bio y usuario',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            _divider(context),
            _navTile(context,
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF26A69A),
              title: 'Cambiar contraseña',
              subtitle: 'Recibirás un email de recuperación',
              onTap: _sendPasswordReset,
            ),
          ]),
          const SizedBox(height: 16),

          // ── Apariencia ────────────────────────────────────────────
          _sectionLabel(context, 'Apariencia'),
          _settingsCard(context, [
            _toggleTile(context,
              icon: themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              iconColor: themeProvider.isDark ? const Color(0xFF7C3AED) : const Color(0xFFFFB300),
              title: 'Modo oscuro',
              subtitle: themeProvider.isDark ? 'Tema oscuro activado' : 'Tema claro activado',
              value: themeProvider.isDark,
              onChanged: (v) => themeProvider.setDark(v),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Privacidad ────────────────────────────────────────────
          _sectionLabel(context, 'Privacidad'),
          _settingsCard(context, [
            _toggleTile(context,
              icon: Icons.lock_person_outlined,
              iconColor: AppColors.primary,
              title: 'Cuenta privada',
              subtitle: 'Solo tus seguidores ven tu contenido',
              value: user?.isPrivate ?? false,
              onChanged: (bool v) async {
                if (user == null) return;
                final authProv = context.read<AuthProvider>();
                await ProfileService.instance.updateUser(user.uid, {'isPrivate': v});
                if (!mounted) return;
                await authProv.refreshCurrentUser();
              },
            ),
          ]),
          const SizedBox(height: 16),

          // ── Notificaciones ────────────────────────────────────────
          _sectionLabel(context, 'Notificaciones'),
          _settingsCard(context, [
            _toggleTile(context,
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFFFCA28),
              title: 'Notificaciones push',
              subtitle: 'Likes, comentarios y nuevos seguidores',
              value: _pushEnabled,
              onChanged: _setPush,
            ),
          ]),
          const SizedBox(height: 16),

          // ── Información ───────────────────────────────────────────
          _sectionLabel(context, 'Información'),
          _settingsCard(context, [
            _infoTile(context,
              icon: Icons.info_outline_rounded,
              iconColor: context.colTextHint,
              title: 'Versión de la app',
              trailing: Text('1.0.0',
                  style: GoogleFonts.dmSans(color: context.colTextHint, fontSize: 13)),
            ),
            _divider(context),
            _navTile(context,
              icon: Icons.description_outlined,
              iconColor: context.colTextSec,
              title: 'Términos de uso',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LegalScreen(
                  title: 'Términos de uso',
                  assetPath: 'assets/docs/terminos-de-uso.md',
                ),
              )),
            ),
            _divider(context),
            _navTile(context,
              icon: Icons.privacy_tip_outlined,
              iconColor: context.colTextSec,
              title: 'Política de privacidad',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LegalScreen(
                  title: 'Política de privacidad',
                  assetPath: 'assets/docs/politica-de-privacidad.md',
                ),
              )),
            ),
          ]),
          const SizedBox(height: 32),

          // ── Cerrar sesión ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFE53935)),
              label: Text('Cerrar sesión',
                  style: GoogleFonts.dmSans(color: const Color(0xFFE53935), fontWeight: FontWeight.w600, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE53935)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: _confirmDeleteAccount,
              child: Text('Eliminar cuenta',
                  style: GoogleFonts.dmSans(color: Colors.red.shade400, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: context.colBgCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarWithFrame(
                  base64: user?.avatarBase64.isNotEmpty == true ? user!.avatarBase64 : null,
                  frameStyle: user?.frameStyle ?? 'none',
                  radius: 29,
                  initials: user?.initials ?? '?',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?.nombre ?? '',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15, color: context.colText)),
                    const SizedBox(height: 2),
                    Text('@${user?.username ?? ''}',
                        style: GoogleFonts.dmSans(color: context.colTextSec, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: context.colAccentBg, borderRadius: BorderRadius.circular(8)),
                      child: Text('Editar perfil',
                          style: GoogleFonts.dmSans(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: context.colTextHint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 8),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.dmSans(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: context.colTextHint, letterSpacing: 0.8)),
      );

  Widget _settingsCard(BuildContext context, List<Widget> children) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(color: context.colBgCard, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      );

  Widget _divider(BuildContext context) =>
      Divider(height: 1, indent: 54, endIndent: 0, color: context.colBorder);

  Widget _iconBox(BuildContext context, IconData icon, Color color) => Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 18, color: color),
      );

  Widget _toggleTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          _iconBox(context, icon, iconColor),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14, color: context.colText)),
            Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11.5, color: context.colTextHint)),
          ])),
          Switch.adaptive(value: value, onChanged: onChanged,
              activeThumbColor: Colors.white, activeTrackColor: AppColors.primary),
        ]),
      );

  Widget _navTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            _iconBox(context, icon, iconColor),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14, color: context.colText)),
              if (subtitle != null)
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11.5, color: context.colTextHint)),
            ])),
            Icon(Icons.chevron_right_rounded, color: context.colTextHint, size: 18),
          ]),
        ),
      );

  Widget _infoTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(children: [
          _iconBox(context, icon, iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(title,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14, color: context.colText))),
          trailing,
        ]),
      );
}
