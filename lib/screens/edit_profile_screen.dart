import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../utils/image_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;

  bool _isPrivate = false;
  bool _saving = false;
  XFile? _newAvatarFile;
  String _currentAvatarBase64 = '';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nombreCtrl = TextEditingController(text: user?.nombre ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _isPrivate = user?.isPrivate ?? false;
    _currentAvatarBase64 = user?.avatarBase64 ?? '';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Cambiar foto',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _sourceOption(ctx, Icons.camera_alt_outlined, 'Cámara', ImageSource.camera)),
                const SizedBox(width: 12),
                Expanded(child: _sourceOption(ctx, Icons.photo_library_outlined, 'Galería', ImageSource.gallery)),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 800);
    if (file != null && mounted) {
      setState(() => _newAvatarFile = file);
    }
  }

  Widget _sourceOption(BuildContext ctx, IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () => Navigator.of(ctx).pop(source),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    final nombre = _nombreCtrl.text.trim();
    final username = _usernameCtrl.text.trim().toLowerCase();
    final bio = _bioCtrl.text.trim();

    if (nombre.isEmpty) { _showError('El nombre no puede estar vacío.'); return; }
    if (username.isEmpty || username.contains(' ')) {
      _showError('El usuario no puede estar vacío ni tener espacios.'); return;
    }

    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUser!.uid;

    try {
      if (_newAvatarFile != null) {
        await ProfileService.instance.saveAvatarBase64(uid, _newAvatarFile!);
      }
      await ProfileService.instance.updateUser(uid, {
        'nombre': nombre,
        'username': username,
        'bio': bio,
        'isPrivate': _isPrivate,
      });
      await auth.refreshCurrentUser();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) _showError('Error al guardar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.dmSans())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Editar perfil', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          _saving
              ? const Padding(padding: EdgeInsets.only(right: 16),
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
              : TextButton(
                  onPressed: _save,
                  child: Text('Guardar',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 15))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(children: [
                  _buildAvatar(),
                  Positioned(right: 0, bottom: 0,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt_outlined, size: 15, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            _label('Nombre completo'),
            const SizedBox(height: 6),
            TextField(controller: _nombreCtrl, textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Tu nombre completo',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20))),
            const SizedBox(height: 20),

            _label('Nombre de usuario'),
            const SizedBox(height: 6),
            TextField(controller: _usernameCtrl,
                decoration: const InputDecoration(hintText: 'tu.usuario',
                    prefixIcon: Icon(Icons.alternate_email_rounded, size: 20))),
            const SizedBox(height: 20),

            _label('Biografía'),
            const SizedBox(height: 6),
            TextField(controller: _bioCtrl, maxLines: 4, maxLength: 160,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Cuéntanos sobre ti y tu estilo...',
                    alignLabelWithHint: true)),
            const SizedBox(height: 8),

            _label('Privacidad'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: SwitchListTile(
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryLight,
                title: Text('Perfil privado',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                subtitle: Text(
                    _isPrivate ? 'Solo tus seguidores ven tus posts' : 'Cualquier usuario puede ver tu perfil',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint)),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(width: double.infinity,
              child: ElevatedButton(onPressed: _saving ? null : _save, child: const Text('Guardar cambios'))),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const size = 96.0;
    if (_newAvatarFile != null) {
      return ClipOval(child: SizedBox(width: size, height: size,
          child: ImageUtils.imageWidgetFromXFile(_newAvatarFile!)));
    }
    if (_currentAvatarBase64.isNotEmpty) {
      return ClipOval(child: SizedBox(width: size, height: size,
          child: ImageUtils.imageFromBase64(_currentAvatarBase64)));
    }
    return _initials(size);
  }

  Widget _initials(double size) {
    final text = _nombreCtrl.text;
    final parts = text.trim().split(' ');
    final ini = parts.length >= 2 && parts[1].isNotEmpty
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : text.isNotEmpty ? text[0].toUpperCase() : '?';
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle,
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])),
      child: Center(child: Text(ini,
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800))),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSec, letterSpacing: 0.5));
}
