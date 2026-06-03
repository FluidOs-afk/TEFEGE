import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/post_model.dart';
import '../models/wardrobe_item.dart';
import '../providers/auth_provider.dart';
import '../services/posts_service.dart';
import '../services/wardrobe_service.dart';
import '../utils/content_filter.dart';
import '../utils/image_utils.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  XFile? _imageFile;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final List<String> _tags = [];
  String _category = 'Casual';
  final Set<String> _selectedItemIds = {};
  List<WardrobeItem> _wardrobeItems = [];
  bool _publishing = false;

  static const _categories = ['Casual','Trabajo','Deporte','Evento','Noche','Vintage','Otro'];

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWardrobe() async {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final items = await WardrobeService.instance.getItems(uid);
    if (mounted) setState(() => _wardrobeItems = items);
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1080);
    if (file != null) setState(() => _imageFile = file);
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() { _tags.add(tag); _tagCtrl.clear(); });
    }
  }

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) { _snack('El título es obligatorio'); return; }
    if (_imageFile == null) { _snack('Selecciona una imagen para la publicación'); return; }
    if (ContentFilter.containsProfanity(title)) { _snack('El título contiene lenguaje inapropiado.'); return; }

    final description = _descCtrl.text.trim();
    if (ContentFilter.containsProfanity(description)) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Contenido inapropiado',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
          content: Text(
            'La descripción contiene lenguaje inapropiado. Por favor, modifícala antes de publicar.',
            style: GoogleFonts.dmSans(color: AppColors.textSec),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Editar',
                  style: GoogleFonts.dmSans(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _publishing = true);
    try {
      final post = PostModel(
        id: '', userId: user.uid, username: user.username,
        userAvatarBase64: user.avatarBase64,
        title: title, description: _descCtrl.text.trim(),
        tags: List.from(_tags), category: _category,
        wardrobeItems: _selectedItemIds.toList(),
        createdAt: DateTime.now(),
      );
      await PostsService.instance.createPost(post, _imageFile!);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) _snack('Error al publicar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.dmSans())));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Nueva publicación', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        actions: [
          _publishing
              ? const Padding(padding: EdgeInsets.only(right: 16),
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
              : TextButton(
                  onPressed: _publish,
                  child: Text('Publicar', style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 15))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: _buildImagePicker()),
          const SizedBox(height: 24),

          _label('Título *'),
          const SizedBox(height: 6),
          TextField(controller: _titleCtrl, textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Look casual de primavera',
                  prefixIcon: Icon(Icons.title_rounded, size: 20))),
          const SizedBox(height: 20),

          _label('Descripción'),
          const SizedBox(height: 6),
          TextField(controller: _descCtrl, maxLines: 3, maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Describe tu look, inspiración...')),
          const SizedBox(height: 8),

          _label('Categoría'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: _categories.map((cat) {
            final sel = _category == cat;
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                ),
                child: Text(cat, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textSec)),
              ),
            );
          }).toList()),
          const SizedBox(height: 20),

          _label('Etiquetas'),
          const SizedBox(height: 8),
          if (_tags.isNotEmpty) ...[
            Wrap(spacing: 6, runSpacing: 4, children: _tags.map((t) => Chip(
              label: Text('#$t', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary)),
              backgroundColor: AppColors.accentBg, side: BorderSide.none,
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => setState(() => _tags.remove(t)),
            )).toList()),
            const SizedBox(height: 8),
          ],
          Row(children: [
            Expanded(child: TextField(controller: _tagCtrl,
                decoration: const InputDecoration(hintText: 'casual, verano...',
                    prefixIcon: Icon(Icons.tag_rounded, size: 20)),
                onSubmitted: (_) => _addTag())),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _addTag,
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 20),

          if (_wardrobeItems.isNotEmpty) ...[
            _label('Prendas de este look (opcional)'),
            const SizedBox(height: 4),
            Text('Toca para seleccionar las prendas que llevas',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6, children: _wardrobeItems.map((item) {
              final sel = _selectedItemIds.contains(item.id);
              return GestureDetector(
                onTap: () => setState(() => sel ? _selectedItemIds.remove(item.id) : _selectedItemIds.add(item.id)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 1.5 : 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (sel) const Padding(padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_rounded, size: 14, color: Colors.white)),
                    Text(item.name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textPrimary)),
                  ]),
                ),
              );
            }).toList()),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _publishing ? null : _publish,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Publicar'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_imageFile != null) {
      return GestureDetector(
        onTap: _showPhotoOptions,
        child: Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(20),
              child: SizedBox(width: 220, height: 220,
                  child: ImageUtils.imageWidgetFromXFile(_imageFile!))),
          Positioned(bottom: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)]),
              child: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
            ),
          ),
        ]),
      );
    }
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        width: 180, height: 180,
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 2)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_photo_alternate_outlined, size: 44, color: AppColors.textHint),
          const SizedBox(height: 10),
          Text('Añadir foto', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textHint)),
        ]),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 8),
          ListTile(leading: _optionIcon(Icons.photo_library_outlined),
              title: Text('Elegir de la galería', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
          ListTile(leading: _optionIcon(Icons.camera_alt_outlined),
              title: Text('Hacer una foto', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
          if (_imageFile != null)
            ListTile(
              leading: _optionIcon(Icons.delete_outline_rounded, color: Colors.red),
              title: Text('Eliminar foto', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () { Navigator.pop(context); setState(() => _imageFile = null); },
            ),
          const SizedBox(height: 8),
        ])),
      ),
    );
  }

  Widget _optionIcon(IconData icon, {Color color = AppColors.primary}) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: color, size: 20),
  );

  Widget _label(String text) => Text(text,
      style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSec, letterSpacing: 0.5));
}
