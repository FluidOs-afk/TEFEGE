import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart' show AppColors;
import '../models/user_post.dart';
import '../services/posts_service.dart';
import '../services/profile_service.dart';
import '../widgets/fashion_icon.dart';

// Datos de prendas (mismos que el armario)
class _GarmentOption {
  final String name;
  final String brand;
  final Color bgColor;
  final FashionCategory category;
  const _GarmentOption({
    required this.name,
    required this.brand,
    required this.bgColor,
    required this.category,
  });
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const _garments = [
    _GarmentOption(
      name: 'Blazer Oversize',
      brand: 'Zara',
      bgColor: Color(0xFFF5F0EB),
      category: FashionCategory.coat,
    ),
    _GarmentOption(
      name: 'Vaqueros Slouchy',
      brand: 'Mango',
      bgColor: Color(0xFFE3F2FD),
      category: FashionCategory.pants,
    ),
    _GarmentOption(
      name: 'Vestido Satinado',
      brand: 'H&M',
      bgColor: Color(0xFFE8F5EE),
      category: FashionCategory.dress,
    ),
    _GarmentOption(
      name: 'Sneakers Blancas',
      brand: 'Nike',
      bgColor: Color(0xFFF3F4F6),
      category: FashionCategory.shoes,
    ),
    _GarmentOption(
      name: 'Camiseta Básica',
      brand: 'Uniqlo',
      bgColor: Color(0xFFFFF8F0),
      category: FashionCategory.tops,
    ),
    _GarmentOption(
      name: 'Bolso de Piel',
      brand: 'Massimo Dutti',
      bgColor: Color(0xFFFBEEE4),
      category: FashionCategory.accessory,
    ),
    _GarmentOption(
      name: 'Mini Falda',
      brand: 'Pull&Bear',
      bgColor: Color(0xFFF5F5F5),
      category: FashionCategory.pants,
    ),
    _GarmentOption(
      name: 'Tacones Negros',
      brand: 'Stradivarius',
      bgColor: Color(0xFFEEEEEE),
      category: FashionCategory.shoes,
    ),
    _GarmentOption(
      name: 'Abrigo de Lana',
      brand: 'Zara',
      bgColor: Color(0xFFF9F3EC),
      category: FashionCategory.coat,
    ),
    _GarmentOption(
      name: 'Collar Dorado',
      brand: 'Mango',
      bgColor: Color(0xFFFFF8E1),
      category: FashionCategory.accessory,
    ),
  ];

  static const _gradients = {
    FashionCategory.tops: [Color(0xFF1B6B44), Color(0xFF3CB87A)],
    FashionCategory.pants: [Color(0xFF1A3A6C), Color(0xFF2196F3)],
    FashionCategory.dress: [Color(0xFF4A1275), Color(0xFF9C27B0)],
    FashionCategory.shoes: [Color(0xFF5D3A2A), Color(0xFF8D6E63)],
    FashionCategory.accessory: [Color(0xFF7B1FA2), Color(0xFFE91E63)],
    FashionCategory.coat: [Color(0xFF37474F), Color(0xFF78909C)],
  };

  FashionCategory? _category;
  XFile? _imageFile;
  final _picker = ImagePicker();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final Set<int> _selectedGarments = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (file != null) setState(() => _imageFile = file);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Elegir de la galería',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Hacer una foto',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Eliminar foto',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _imageFile = null);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _publish() {
    if (_imageFile == null && _category == null) {
      _snack('Añade una foto o selecciona una categoría');
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _snack('El título es obligatorio');
      return;
    }

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final wardrobeItems = _selectedGarments.map((i) {
      final g = _garments[i];
      return PostWardrobeItem(
        name: g.name,
        brand: g.brand,
        bgColor: g.bgColor,
        category: g.category,
      );
    }).toList();

    final effectiveCategory = _category ?? FashionCategory.tops;
    PostsService.instance.add(
      UserPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: ProfileService.instance.profile.userId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        tags: tags,
        category: effectiveCategory,
        gradient: List<Color>.from(_gradients[effectiveCategory]!),
        wardrobeItems: wardrobeItems,
        createdAt: DateTime.now(),
        imagePath: _imageFile?.path,
        likes: 0,
      ),
    );

    Navigator.of(context).pop();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(
          'Nueva publicación',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _publish,
            child: Text(
              'Publicar',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Preview / selector de foto ────────────────────────────
            Center(child: _buildPhotoPreview()),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _showPhotoOptions,
                icon: Icon(
                  _imageFile != null
                      ? Icons.edit_outlined
                      : Icons.add_photo_alternate_outlined,
                  size: 18,
                ),
                label: Text(
                  _imageFile != null ? 'Cambiar foto' : 'Añadir foto',
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // ── Categoría (para el gradiente de fondo) ────────────────
            _label(
              _imageFile != null
                  ? 'Categoría (icono de fondo)'
                  : 'Categoría de la foto *',
            ),
            const SizedBox(height: 10),
            _categoryPicker(),
            const SizedBox(height: 24),

            // ── Título ─────────────────────────────────────────────────
            _label('Título *'),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Ej: Look casual de primavera',
                prefixIcon: Icon(Icons.title_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // ── Descripción ────────────────────────────────────────────
            _label('Descripción'),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Describe tu look, inspiración...',
              ),
            ),
            const SizedBox(height: 8),

            // ── Prendas del armario ────────────────────────────────────
            _label('Prendas de este look'),
            const SizedBox(height: 4),
            Text(
              'Selecciona las prendas que llevas en esta publicación',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 10),
            _garmentPicker(),
            const SizedBox(height: 20),

            // ── Etiquetas ──────────────────────────────────────────────
            _label('Etiquetas'),
            const SizedBox(height: 6),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                hintText: 'casual, verano, street (separadas por comas)',
                prefixIcon: Icon(Icons.tag_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Publicar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textSec,
      letterSpacing: 0.5,
    ),
  );

  // ── Photo preview ──────────────────────────────────────────────────────────
  Widget _buildPhotoPreview() {
    // Foto real seleccionada
    if (_imageFile != null) {
      return GestureDetector(
        onTap: _showPhotoOptions,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.file(
                File(_imageFile!.path),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              if (_titleCtrl.text.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Text(
                      _titleCtrl.text,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Sin foto: placeholder o gradiente según categoría
    if (_category == null) {
      return GestureDetector(
        onTap: _showPhotoOptions,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para añadir foto',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final grad = _gradients[_category!]!;
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: List<Color>.from(grad),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(grad[0], grad[1], 0.5)!.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: FashionIcon(
                category: _category!,
                color: Colors.white.withValues(alpha: 0.1),
                size: 80,
                strokeWidth: 1.5,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FashionIcon(
                    category: _category!,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 44,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+ Añadir foto',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_titleCtrl.text.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    _titleCtrl.text,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Category picker ────────────────────────────────────────────────────────
  static const _catLabels = {
    FashionCategory.tops: 'Tops',
    FashionCategory.pants: 'Pantalones',
    FashionCategory.dress: 'Vestidos',
    FashionCategory.shoes: 'Zapatos',
    FashionCategory.accessory: 'Accesorios',
    FashionCategory.coat: 'Abrigos',
  };

  Widget _categoryPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FashionCategory.values.map((cat) {
        final sel = _category == cat;
        final grad = _gradients[cat]!;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: sel
                  ? LinearGradient(colors: List<Color>.from(grad))
                  : null,
              color: sel ? null : AppColors.bgCard,
              border: Border.all(
                color: sel ? Colors.transparent : AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: Color.lerp(
                          grad[0],
                          grad[1],
                          0.5,
                        )!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FashionIcon(
                  category: cat,
                  color: sel ? Colors.white : AppColors.textSec,
                  size: 16,
                  strokeWidth: 1.8,
                ),
                const SizedBox(width: 5),
                Text(
                  _catLabels[cat]!,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textSec,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Garment picker ─────────────────────────────────────────────────────────
  Widget _garmentPicker() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.68,
      ),
      itemCount: _garments.length,
      itemBuilder: (_, i) {
        final g = _garments[i];
        final sel = _selectedGarments.contains(i);
        return GestureDetector(
          onTap: () => setState(() {
            if (sel) {
              _selectedGarments.remove(i);
            } else {
              _selectedGarments.add(i);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: g.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? AppColors.primary : AppColors.border,
                width: sel ? 2 : 1,
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 2),
                      child: FashionIcon(
                        category: g.category,
                        color: sel ? AppColors.primary : AppColors.textSec,
                        size: 28,
                        strokeWidth: 1.8,
                      ),
                    ),
                    if (sel)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  g.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  g.brand,
                  style: GoogleFonts.dmSans(
                    fontSize: 8,
                    color: AppColors.textHint,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
