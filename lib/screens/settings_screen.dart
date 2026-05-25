import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../services/settings_service.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'legal_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfile _profile;
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _profile = ProfileService.instance.profile;
    _settings = SettingsService.instance.settings;
    ProfileService.instance.addListener(_onProfileChanged);
    SettingsService.instance.addListener(_onSettingsChanged);
    SettingsService.instance.load();
  }

  void _onProfileChanged() {
    if (mounted) setState(() => _profile = ProfileService.instance.profile);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() => _settings = SettingsService.instance.settings);
  }

  @override
  void dispose() {
    ProfileService.instance.removeListener(_onProfileChanged);
    SettingsService.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _openEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Ajustes',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ─── Perfil ────────────────────────────────────────────────────
          _buildProfileCard(),
          const SizedBox(height: 24),

          // ─── Cuenta ────────────────────────────────────────────────────
          _sectionLabel('Cuenta'),
          _settingsCard([
            _navTile(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF5C6BC0),
              title: 'Editar perfil',
              subtitle: 'Nombre, bio, ubicación y usuario',
              onTap: _openEditProfile,
            ),
            _divider(),
            _navTile(
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF26A69A),
              title: 'Cambiar contraseña',
              subtitle: 'Actualiza tu contraseña de acceso',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen()),
              ),
            ),
            _divider(),
            _navTile(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFFEF5350),
              title: 'Correo electrónico',
              subtitle: 'Próximamente disponible',
              onTap: () => _showComingSoon('Correo electrónico'),
              disabled: true,
            ),
          ]),
          const SizedBox(height: 16),

          // ─── Privacidad ────────────────────────────────────────────────
          _sectionLabel('Privacidad'),
          _settingsCard([
            _toggleTile(
              icon: Icons.lock_person_outlined,
              iconColor: AppColors.primary,
              title: 'Cuenta privada',
              subtitle: 'Solo tus seguidores ven tu contenido',
              value: _settings.privateAccount,
              onChanged: (v) => SettingsService.instance.setPrivateAccount(v),
            ),
            _divider(),
            _toggleTile(
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFFFF7043),
              title: 'Mostrar ubicación',
              subtitle: 'Muestra tu ciudad en el perfil',
              value: _settings.showLocation,
              onChanged: (v) => SettingsService.instance.setShowLocation(v),
            ),
            _divider(),
            _toggleTile(
              icon: Icons.circle_outlined,
              iconColor: const Color(0xFF66BB6A),
              title: 'Estado en línea',
              subtitle: 'Los demás ven cuándo estás activo',
              value: _settings.showOnlineStatus,
              onChanged: (v) =>
                  SettingsService.instance.setShowOnlineStatus(v),
            ),
          ]),
          const SizedBox(height: 16),

          // ─── Notificaciones ────────────────────────────────────────────
          _sectionLabel('Notificaciones'),
          _settingsCard([
            _toggleTile(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFFFCA28),
              title: 'Notificaciones push',
              subtitle: 'Likes, comentarios y nuevos seguidores',
              value: _settings.pushNotifications,
              onChanged: (v) =>
                  SettingsService.instance.setPushNotifications(v),
            ),
          ]),
          const SizedBox(height: 16),

          // ─── Información ───────────────────────────────────────────────
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
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalScreen(
                    title: 'Términos de uso',
                    assetPath: 'assets/docs/terminos-de-uso.md',
                  ),
                ),
              ),
            ),
            _divider(),
            _navTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.textSec,
              title: 'Política de privacidad',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalScreen(
                    title: 'Política de privacidad',
                    assetPath: 'assets/docs/politica-de-privacidad.md',
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),

          // ─── Cerrar sesión ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFE53935)),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Profile card ─────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _openEditProfile,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _profile.initials,
                      style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile.displayName,
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${_profile.username}',
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

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
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
  }

  Widget _settingsCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _divider() => const Divider(
        height: 1,
        indent: 54,
        endIndent: 0,
        color: AppColors.border,
      );

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
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
  }

  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _iconBox(icon, disabled ? AppColors.textHint : iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: disabled
                              ? AppColors.textHint
                              : AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: GoogleFonts.dmSans(
                            fontSize: 11.5, color: AppColors.textHint)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: disabled ? AppColors.border : AppColors.textHint,
                size: 18),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente',
            style: GoogleFonts.dmSans(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
