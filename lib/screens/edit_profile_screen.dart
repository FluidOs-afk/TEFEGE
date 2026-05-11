import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;

  late UserProfile _original;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _original = ProfileService.instance.profile;
    _usernameCtrl = TextEditingController(text: _original.username);
    _displayNameCtrl = TextEditingController(text: _original.displayName);
    _bioCtrl = TextEditingController(text: _original.bio);
    _locationCtrl = TextEditingController(text: _original.location);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  bool get _usernameChanged =>
      _usernameCtrl.text.trim() != _original.username;

  Future<void> _save() async {
    final username = _usernameCtrl.text.trim();
    final displayName = _displayNameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    if (displayName.isEmpty) {
      _showError('El nombre no puede estar vacío.');
      return;
    }
    if (username.isEmpty) {
      _showError('El nombre de usuario no puede estar vacío.');
      return;
    }
    if (_usernameChanged && !_original.canChangeUsername) {
      _showError(
          'Solo puedes cambiar tu nombre de usuario una vez por semana.');
      return;
    }

    setState(() => _saving = true);

    final updated = _original.copyWith(
      username: username,
      displayName: displayName,
      bio: bio,
      location: location,
      lastUsernameChange:
          _usernameChanged ? DateTime.now() : _original.lastUsernameChange,
    );

    await ProfileService.instance.save(updated);
    if (mounted) Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Editar perfil',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: Text('Guardar',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 15)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Avatar ────────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  _buildAvatar(),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Nombre de usuario ─────────────────────────────────────
            _buildSectionLabel('Nombre de usuario'),
            const SizedBox(height: 6),
            _UsernameField(
              controller: _usernameCtrl,
              profile: _original,
            ),
            const SizedBox(height: 20),

            // ─── Nombre visible ────────────────────────────────────────
            _buildSectionLabel('Nombre'),
            const SizedBox(height: 6),
            TextField(
              controller: _displayNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Tu nombre completo',
                prefixIcon:
                    Icon(Icons.person_outline_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Biografía ─────────────────────────────────────────────
            _buildSectionLabel('Biografía'),
            const SizedBox(height: 6),
            TextField(
              controller: _bioCtrl,
              maxLines: 4,
              maxLength: 160,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Cuéntanos sobre ti y tu estilo...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),

            // ─── Ubicación ─────────────────────────────────────────────
            _buildSectionLabel('Ubicación'),
            const SizedBox(height: 6),
            TextField(
              controller: _locationCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ciudad, País',
                prefixIcon:
                    Icon(Icons.location_on_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 32),

            // ─── Botón guardar ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ListenableBuilder(
      listenable: _displayNameCtrl,
      builder: (context, child) {
        final initials = _computeInitials(_displayNameCtrl.text);
        return Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSec,
            letterSpacing: 0.5));
  }

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ─── Username field con lógica de cooldown ─────────────────────────────────────
class _UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final UserProfile profile;

  const _UsernameField({
    required this.controller,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !profile.canChangeUsername;
    final days = profile.daysUntilUsernameChange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: !locked,
          decoration: InputDecoration(
            hintText: 'tu.usuario',
            prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
            suffixIcon: locked
                ? Tooltip(
                    message: 'Disponible en $days día${days == 1 ? '' : 's'}',
                    child: const Icon(Icons.lock_outline_rounded,
                        size: 18, color: AppColors.textHint),
                  )
                : null,
            fillColor: locked ? const Color(0xFFF0F4F2) : null,
          ),
        ),
        if (locked) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                'Podrás cambiarlo en $days día${days == 1 ? '' : 's'}',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
