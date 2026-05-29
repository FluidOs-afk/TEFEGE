import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show AppColors;
import '../models/user_model.dart';
import '../utils/image_utils.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../services/wardrobe_service.dart';
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
    if (mounted) {
      setState(() => _pushEnabled = prefs.getBool('push_enabled') ?? true);
    }
  }

  Future<void> _setPush(bool v) async {
    setState(() => _pushEnabled = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_enabled', v);
  }

  // ── Cambiar contraseña: enviar email de reset ────────────────────────────
  Future<void> _sendPasswordReset() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email de recuperación enviado a $email',
              style: GoogleFonts.dmSans()),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el email',
              style: GoogleFonts.dmSans()),
        ),
      );
    }
  }

  // ── Cerrar sesión ────────────────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar sesión',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('¿Seguro que quieres cerrar sesión?',
            style: GoogleFonts.dmSans(color: AppColors.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar',
                style: GoogleFonts.dmSans(color: AppColors.textSec)),
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
                style: GoogleFonts.dmSans(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Eliminar cuenta ──────────────────────────────────────────────────────
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar cuenta',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Esta acción es irreversible',
                        style: GoogleFonts.dmSans(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Se eliminarán todas tus publicaciones, prendas del armario, outfits guardados y tu perfil de forma permanente.',
              style: GoogleFonts.dmSans(
                  color: AppColors.textSec, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar',
                style: GoogleFonts.dmSans(color: AppColors.textSec)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: Text('Eliminar todo',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
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

      // 1. Borrar posts del usuario en Firestore
      final postsSnap = await db
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in postsSnap.docs) {
        await doc.reference.delete();
      }

      // 2. Borrar prendas del armario en Firestore
      final items = await WardrobeService.instance.getItems(uid);
      for (final item in items) {
        await WardrobeService.instance.deleteItem(uid, item.id);
      }

      // 3. Borrar documento de usuario en Firestore
      await db.collection('users').doc(uid).delete();

      // 4. Borrar cuenta de Firebase Auth
      await FirebaseAuth.instance.currentUser?.delete();

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
    } catch (e) {
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error al eliminar la cuenta. Es posible que necesites volver a iniciar sesión.',
              style: GoogleFonts.dmSans()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (_deletingAccount) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Eliminando cuenta...',
                  style: GoogleFonts.dmSans(
                      color: AppColors.textSec, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Ajustes',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ── Tarjeta de perfil ─────────────────────────────────────
          _buildProfileCard(context, user),
          const SizedBox(height: 24),

          // ── Cuenta ───────────────────────────────────────────────
          _sectionLabel('Cuenta'),
          _settingsCard([
            _navTile(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF5C6BC0),
              title: 'Editar perfil',
              subtitle: 'Nombre, bio y usuario',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen())),
            ),
            _divider(),
            _navTile(
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF26A69A),
              title: 'Cambiar contraseña',
              subtitle: 'Recibirás un email de recuperación',
              onTap: _sendPasswordReset,
            ),
          ]),
          const SizedBox(height: 16),

          // ── Privacidad ────────────────────────────────────────────
          _sectionLabel('Privacidad'),
          _settingsCard([
            _toggleTile(
              icon: Icons.lock_person_outlined,
              iconColor: AppColors.primary,
              title: 'Cuenta privada',
              subtitle: 'Solo tus seguidores ven tu contenido',
              value: user?.isPrivate ?? false,
              onChanged: (bool v) async {
                if (user == null) return;
                final authProv = context.read<AuthProvider>();
                await ProfileService.instance
                    .updateUser(user.uid, {'isPrivate': v});
                if (!mounted) return;
                await authProv.refreshCurrentUser();
              },
            ),
          ]),
          const SizedBox(height: 16),

          // ── Notificaciones ────────────────────────────────────────
          _sectionLabel('Notificaciones'),
          _settingsCard([
            _toggleTile(
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
          _sectionLabel('Información'),
          _settingsCard([
            _infoTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.textHint,
              title: 'Versión de la app',
              trailing: Text('1.0.0',
                  style: GoogleFonts.dmSans(
                      color: AppColors.textHint, fontSize: 13)),
            ),
            _divider(),
            _navTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.textSec,
              title: 'Términos de uso',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LegalScreen(
                  title: 'Términos de uso',
                  assetPath: 'assets/docs/terminos-de-uso.md',
                ),
              )),
            ),
            _divider(),
            _navTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.textSec,
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
              icon: const Icon(Icons.logout_rounded,
                  color: Color(0xFFE53935)),
              label: Text('Cerrar sesión',
                  style: GoogleFonts.dmSans(
                      color: const Color(0xFFE53935),
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE53935)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Eliminar cuenta ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: _confirmDeleteAccount,
              child: Text('Eliminar cuenta',
                  style: GoogleFonts.dmSans(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Tarjeta de perfil ────────────────────────────────────────────────────
  Widget _buildProfileCard(BuildContext context, UserModel? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(user),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nombre ?? '',
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user?.username ?? ''}',
                        style: GoogleFonts.dmSans(
                            color: AppColors.textSec, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Editar perfil',
                            style: GoogleFonts.dmSans(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel? user) {
    const size = 58.0;
    if (user?.avatarBase64.isNotEmpty == true) {
      return ClipOval(
        child: SizedBox(
          width: size, height: size,
          child: ImageUtils.imageFromBase64(
            user!.avatarBase64,
            placeholder: _avatarFallback(user, size),
          ),
        ),
      );
    }
    return _avatarFallback(user, size);
  }

  Widget _avatarFallback(UserModel? user, double size) => Container(
        width: size, height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight]),
        ),
        child: Center(
          child: Text(
            user?.initials ?? '?',
            style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
        ),
      );

  // ── UI helpers ───────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 8),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textHint,
              letterSpacing: 0.8),
        ),
      );

  Widget _settingsCard(List<Widget> children) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      );

  Widget _divider() => const Divider(
      height: 1, indent: 54, endIndent: 0, color: AppColors.border);

  Widget _iconBox(IconData icon, Color color) => Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 18, color: color),
      );

  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _iconBox(icon, iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.dmSans(
                          fontSize: 11.5, color: AppColors.textHint)),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      );

  Widget _navTile({
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
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              _iconBox(icon, iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    if (subtitle != null)
                      Text(subtitle,
                          style: GoogleFonts.dmSans(
                              fontSize: 11.5,
                              color: AppColors.textHint)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 18),
            ],
          ),
        ),
      );

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _iconBox(icon, iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary)),
            ),
            trailing,
          ],
        ),
      );
}
