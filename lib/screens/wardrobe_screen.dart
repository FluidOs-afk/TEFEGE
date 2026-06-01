import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/wardrobe_item.dart';
import '../providers/auth_provider.dart';
import '../services/wardrobe_service.dart';
import '../utils/image_utils.dart';

const _kCategories = ['Todos','Tops','Pantalones','Vestidos','Abrigos','Zapatos','Accesorios'];

IconData _catIcon(String cat) => switch (cat) {
  'Tops' => Icons.dry_cleaning_outlined,
  'Pantalones' => Icons.straighten_outlined,
  'Vestidos' => Icons.woman_outlined,
  'Abrigos' => Icons.checkroom_outlined,
  'Zapatos' => Icons.local_mall_outlined,
  'Accesorios' => Icons.diamond_outlined,
  _ => Icons.apps_rounded,
};

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});
  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  String _selectedCat = 'Todos';

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Mi Armario',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, uid),
        icon: const Icon(Icons.add_rounded),
        label: Text('Añadir', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.bgCard, height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: _kCategories.length,
              itemBuilder: (_, i) {
                final cat = _kCategories[i];
                final sel = _selectedCat == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCat = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.bgPage,
                      borderRadius: BorderRadius.circular(20),
                      border: sel ? null : Border.all(color: AppColors.border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_catIcon(cat), size: 13, color: sel ? Colors.white : AppColors.textHint),
                      const SizedBox(width: 5),
                      Text(cat, style: GoogleFonts.dmSans(fontSize: 12,
                          color: sel ? Colors.white : AppColors.textSec,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                    ]),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<WardrobeItem>>(
              stream: uid.isNotEmpty ? WardrobeService.instance.streamItems(uid) : const Stream.empty(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final all = snap.data ?? [];
                final items = _selectedCat == 'Todos' ? all : all.where((i) => i.category == _selectedCat).toList();
                if (all.isEmpty) return _EmptyState(onAdd: () => _showAddSheet(context, uid));
                if (items.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_catIcon(_selectedCat), size: 48, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text('No hay prendas en "$_selectedCat"',
                        style: GoogleFonts.dmSans(color: AppColors.textSec, fontWeight: FontWeight.w600)),
                  ]));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.78),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _ItemCard(
                    item: items[i],
                    onLongPress: () => _confirmDelete(context, uid, items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            Text('Añadir prenda', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _SourceOption(
                icon: Icons.camera_alt_outlined, label: 'Hacer foto', sub: 'Cámara', color: AppColors.primary,
                onTap: () { Navigator.pop(context); _pickAndAdd(context, uid, ImageSource.camera); },
              )),
              const SizedBox(width: 10),
              Expanded(child: _SourceOption(
                icon: Icons.photo_library_outlined, label: 'Desde galería', sub: 'Galería', color: const Color(0xFF2F80ED),
                onTap: () { Navigator.pop(context); _pickAndAdd(context, uid, ImageSource.gallery); },
              )),
            ]),
            if (!kIsWeb) ...[
              const SizedBox(height: 10),
              _SourceOption(
                icon: Icons.qr_code_scanner_rounded, label: 'Escanear código de barras',
                sub: 'Importar nombre y marca automáticamente', color: const Color(0xFF7B2FBE), wide: true,
                onTap: () { Navigator.pop(context); _scanBarcode(context, uid); },
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Future<void> _pickAndAdd(BuildContext context, String uid, ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1200);
    if (file == null || !context.mounted) return;
    _showItemForm(context, uid, imageFile: file);
  }

  Future<void> _scanBarcode(BuildContext context, String uid) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _BarcodeScannerPage()),
    );
    if (code == null || !context.mounted) return;
    _showItemForm(context, uid, prefillCode: code);
  }

  void _showItemForm(BuildContext context, String uid, {XFile? imageFile, String? prefillCode}) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ItemFormSheet(uid: uid, imageFile: imageFile, prefillCode: prefillCode),
    );
  }

  void _confirmDelete(BuildContext context, String uid, WardrobeItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar prenda', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar "${item.name}"? Esta acción no se puede deshacer.',
            style: GoogleFonts.dmSans(color: AppColors.textSec)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar', style: GoogleFonts.dmSans(color: AppColors.textSec))),
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); WardrobeService.instance.deleteItem(uid, item.id); },
            child: Text('Eliminar', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onLongPress;
  const _ItemCard({required this.item, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: item.imageBase64.isNotEmpty
                  ? SizedBox(width: double.infinity,
                      child: ImageUtils.imageFromBase64(item.imageBase64, placeholder: _placeholder()))
                  : _placeholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              if (item.brand.isNotEmpty)
                Text(item.brand, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
              const SizedBox(height: 5),
              Row(children: [
                if (item.color.isNotEmpty) _tag(item.color),
                if (item.color.isNotEmpty && item.category.isNotEmpty) const SizedBox(width: 4),
                if (item.category.isNotEmpty) _tag(item.category),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: double.infinity, color: AppColors.accentBg,
    child: Center(child: Icon(_catIcon(item.category), size: 48, color: AppColors.primaryMed)),
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w600)),
  );
}

class _ItemFormSheet extends StatefulWidget {
  final String uid;
  final XFile? imageFile;
  final String? prefillCode;
  const _ItemFormSheet({required this.uid, this.imageFile, this.prefillCode});
  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _marcaCtrl;
  final TextEditingController _colorCtrl = TextEditingController();
  String _categoria = 'Tops';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: '');
    _marcaCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _marcaCtrl.dispose(); _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El nombre es obligatorio', style: GoogleFonts.dmSans())));
      return;
    }
    setState(() => _saving = true);
    try {
      final item = WardrobeItem(
        id: '', name: nombre, brand: _marcaCtrl.text.trim(),
        category: _categoria, color: _colorCtrl.text.trim(),
        barcodeValue: widget.prefillCode ?? '',
        createdAt: DateTime.now(),
      );
      await WardrobeService.instance.addItem(widget.uid, item, widget.imageFile);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar. Inténtalo de nuevo.', style: GoogleFonts.dmSans())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetCard(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20, right: 20, top: 16),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            Text(widget.prefillCode != null ? 'Confirmar prenda escaneada' : 'Nueva prenda',
                style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700)),
            if (widget.prefillCode != null) ...[
              const SizedBox(height: 6),
              Text('Código escaneado: ${widget.prefillCode}',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint)),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 16),
            if (widget.imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(height: 140, width: double.infinity,
                    child: ImageUtils.imageWidgetFromXFile(widget.imageFile!)),
              ),
              const SizedBox(height: 16),
            ],
            TextField(controller: _nombreCtrl, textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: 'Nombre *',
                    prefixIcon: const Icon(Icons.label_outline, size: 20),
                    hintText: 'Camiseta básica',
                    labelStyle: GoogleFonts.dmSans(color: AppColors.textSec))),
            const SizedBox(height: 12),
            TextField(controller: _marcaCtrl, textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: 'Marca',
                    prefixIcon: const Icon(Icons.store_outlined, size: 20),
                    hintText: 'Zara, H&M...',
                    labelStyle: GoogleFonts.dmSans(color: AppColors.textSec))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: InputDecoration(labelText: 'Categoría',
                  prefixIcon: const Icon(Icons.category_outlined, size: 20),
                  labelStyle: GoogleFonts.dmSans(color: AppColors.textSec)),
              items: _kCategories.where((c) => c != 'Todos')
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.dmSans()))).toList(),
              onChanged: (v) { if (v != null) setState(() => _categoria = v); },
            ),
            const SizedBox(height: 12),
            TextField(controller: _colorCtrl, textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: 'Color',
                    prefixIcon: const Icon(Icons.palette_outlined, size: 20),
                    hintText: 'Blanco, Negro...',
                    labelStyle: GoogleFonts.dmSans(color: AppColors.textSec))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Guardar prenda', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BarcodeScannerPage extends StatefulWidget {
  const _BarcodeScannerPage();
  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text('Escanear código de barras',
          style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700)),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Stack(children: [
      MobileScanner(
        onDetect: (capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.firstOrNull;
          if (barcode?.rawValue != null) {
            _scanned = true;
            Navigator.of(context).pop(barcode!.rawValue);
          }
        },
      ),
      Center(child: Container(width: 260, height: 160,
          decoration: BoxDecoration(border: Border.all(color: AppColors.primaryMed, width: 2.5),
              borderRadius: BorderRadius.circular(16)))),
      Positioned(bottom: 40, left: 0, right: 0,
          child: Center(child: Text('Apunta al código de barras',
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)))),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 88, height: 88,
          decoration: const BoxDecoration(color: AppColors.accentBg, shape: BoxShape.circle),
          child: const Icon(Icons.checkroom_outlined, size: 44, color: AppColors.primaryMed)),
      const SizedBox(height: 16),
      Text('Tu armario está vacío',
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Añade tu primera prenda',
          style: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 13)),
      const SizedBox(height: 18),
      ElevatedButton.icon(onPressed: onAdd,
          icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Añadir prenda')),
    ]),
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 36, height: 4,
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))));
}

class _BottomSheetCard extends StatelessWidget {
  final Widget child;
  const _BottomSheetCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: child,
  );
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  final bool wide;
  const _SourceOption({required this.icon, required this.label, required this.sub,
      required this.color, required this.onTap, this.wide = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: wide
          ? Row(children: [
              Icon(icon, color: color, size: 26), const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: GoogleFonts.dmSans(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(sub, style: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 11)),
              ]),
            ])
          : Column(children: [
              Icon(icon, color: color, size: 28), const SizedBox(height: 6),
              Text(label, style: GoogleFonts.dmSans(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
              Text(sub, style: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 10)),
            ]),
    ),
  );
}
