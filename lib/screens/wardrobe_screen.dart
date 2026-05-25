import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart' show AppColors;
import '../widgets/fashion_icon.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});
  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCatIndex = 0;
  String _selectedColor = 'Todos';
  String _selectedStyle = 'Todos';
  final ImagePicker _picker = ImagePicker();
  String _searchQuery = '';

  final List<_Cat> _cats = [
    _Cat('Todo', Icons.apps_rounded),
    _Cat('Tops', Icons.dry_cleaning_outlined),
    _Cat('Pantalones', Icons.straighten_outlined),
    _Cat('Vestidos', Icons.woman_outlined),
    _Cat('Zapatos', Icons.local_mall_outlined),
    _Cat('Accesorios', Icons.diamond_outlined),
    _Cat('Abrigos', Icons.checkroom_outlined),
  ];

  final List<_Garment> _garments = [
    _Garment(name: 'Blazer Oversize', brand: 'Zara', color: 'Beige', style: 'Casual',
        bg: Color(0xFFF5F0EB), cat: 'Abrigos', fav: true),
    _Garment(name: 'Vaqueros Slouchy', brand: 'Mango', color: 'Azul', style: 'Casual',
        bg: Color(0xFFE3F2FD), cat: 'Pantalones', fav: false),
    _Garment(name: 'Vestido Satinado', brand: 'H&M', color: 'Rosa', style: 'Elegante',
        bg: Color(0xFFE8F5EE), cat: 'Vestidos', fav: true),
    _Garment(name: 'Sneakers Blancas', brand: 'Nike', color: 'Blanco', style: 'Sport',
        bg: Color(0xFFF3F4F6), cat: 'Zapatos', fav: false),
    _Garment(name: 'Camiseta Básica', brand: 'Uniqlo', color: 'Blanco', style: 'Casual',
        bg: Color(0xFFFFF8F0), cat: 'Tops', fav: false),
    _Garment(name: 'Bolso de Piel', brand: 'Massimo Dutti', color: 'Marrón', style: 'Elegante',
        bg: Color(0xFFFBEEE4), cat: 'Accesorios', fav: true),
    _Garment(name: 'Mini Falda', brand: 'Pull&Bear', color: 'Negro', style: 'Casual',
        bg: Color(0xFFF5F5F5), cat: 'Pantalones', fav: false),
    _Garment(name: 'Tacones Negros', brand: 'Stradivarius', color: 'Negro', style: 'Elegante',
        bg: Color(0xFFEEEEEE), cat: 'Zapatos', fav: true),
    _Garment(name: 'Abrigo de Lana', brand: 'Zara', color: 'Beige', style: 'Elegante',
        bg: Color(0xFFF9F3EC), cat: 'Abrigos', fav: false),
    _Garment(name: 'Collar Dorado', brand: 'Mango', color: 'Dorado', style: 'Elegante',
        bg: Color(0xFFFFF8E1), cat: 'Accesorios', fav: false),
  ];

  final List<_Outfit> _outfits = [
    _Outfit(title: 'Look Casual Viernes',
        items: ['Blazer Beige', 'Vaqueros Slouchy', 'Sneakers'],
        bg: Color(0xFFE8F5EE), isAi: false),
    _Outfit(title: 'Primavera Pastel',
        items: ['Vestido Rosa', 'Tacones Nude', 'Bolso Blanco'],
        bg: Color(0xFFF3E5F5), isAi: true),
    _Outfit(title: 'Noche Elegante',
        items: ['Vestido Satinado', 'Tacones Negros', 'Bolso Piel'],
        bg: Color(0xFFEEEEEE), isAi: true),
  ];

  List<_Garment> get _filtered => _garments.where((g) {
        final catOk =
            _selectedCatIndex == 0 || g.cat == _cats[_selectedCatIndex].name;
        final colorOk = _selectedColor == 'Todos' || g.color == _selectedColor;
        final styleOk = _selectedStyle == 'Todos' || g.style == _selectedStyle;
        final q = _searchQuery.toLowerCase();
        final searchOk = q.isEmpty ||
            g.name.toLowerCase().contains(q) ||
            g.brand.toLowerCase().contains(q) ||
            g.color.toLowerCase().contains(q);
        return catOk && colorOk && styleOk && searchOk;
      }).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Mi Armario',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: AppColors.textPrimary)),
        actions: [
          IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => _showSearch(context)),
          IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => _showFilters(context)),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Prendas'), Tab(text: 'Mis Outfits')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGarments(), _buildOutfits()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal2(context),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text('Añadir',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ─── Garments tab ────────────────────────────────────────────────────────────
  Widget _buildGarments() {
    return Column(
      children: [
        // Stats bar
        Container(
          color: AppColors.bgCard,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCol('${_garments.length}', 'Prendas'),
              Container(width: 1, height: 32, color: AppColors.border),
              _StatCol('${_outfits.length}', 'Outfits'),
              Container(width: 1, height: 32, color: AppColors.border),
              _StatCol(
                  '${_garments.where((g) => g.fav).length}', 'Favoritos'),
            ],
          ),
        ),
        // Category chips
        Container(
          color: AppColors.bgCard,
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final sel = _selectedCatIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCatIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary
                        : AppColors.bgPage,
                    borderRadius: BorderRadius.circular(20),
                    border: sel
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_cats[i].icon,
                          size: 13,
                          color: sel
                              ? Colors.white
                              : AppColors.textHint),
                      const SizedBox(width: 5),
                      Text(_cats[i].name,
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSec,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 2),
        // Grid
        Expanded(
          child: _filtered.isEmpty
              ? _EmptyWardrobe(onAdd: () => _showAddModal2(context))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _GarmentCard(
                    garment: _filtered[i],
                    onFav: () => setState(() {
                      final idx = _garments
                          .indexWhere((g) => g.name == _filtered[i].name);
                      if (idx != -1) {
                        _garments[idx] = _garments[idx].toggleFav();
                      }
                    }),
                    onTap: () =>
                        _showGarmentDetail(context, _filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  // ─── Outfits tab ─────────────────────────────────────────────────────────────
  Widget _buildOutfits() {
    return _outfits.isEmpty
        ? Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: AppColors.accentBg, shape: BoxShape.circle),
                child: const Icon(Icons.checkroom_outlined,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text('Sin outfits aún',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: () => _showCreateOutfitDialog(context),
                  child: const Text('Crear outfit')),
            ]),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _outfits.length,
            itemBuilder: (_, i) => _OutfitCard(
              outfit: _outfits[i],
              onShare: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                      content: Text(
                          '"${_outfits[i].title}" compartido'))),
              onDelete: () =>
                  setState(() => _outfits.removeAt(i)),
            ),
          );
  }

  // ─── Sheets ───────────────────────────────────────────────────────────────────
  void _showAddModal2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Text('Anadir prenda',
                  style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: _AddOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Hacer foto',
                    sub: 'Analizar prenda',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _pickGarmentImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AddOption(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Escanear QR',
                    sub: 'Importar tienda',
                    color: const Color(0xFF7B2FBE),
                    onTap: () {
                      Navigator.pop(context);
                      _scanQrCode();
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              _AddOption(
                icon: Icons.photo_library_outlined,
                label: 'Subir de galeria',
                sub: 'Importar foto de una prenda',
                color: const Color(0xFF2F80ED),
                wide: true,
                onTap: () {
                  Navigator.pop(context);
                  _pickGarmentImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              _AddOption(
                icon: Icons.store_outlined,
                label: 'Buscar en tiendas',
                sub: 'Zara, H&M, Mango, Nike y mas',
                color: const Color(0xFF0097A7),
                wide: true,
                onTap: () {
                  Navigator.pop(context);
                  _showStoreSearch(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickGarmentImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 86, maxWidth: 1400);
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      _garments.insert(
        0,
        _Garment(
          name: source == ImageSource.camera ? 'Prenda fotografiada' : 'Prenda de galeria',
          brand: 'Mi armario',
          color: 'Blanco',
          style: 'Casual',
          bg: const Color(0xFFE8F5EE),
          cat: 'Tops',
          fav: false,
          imageBytes: bytes,
        ),
      );
      _selectedCatIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prenda anadida al armario')),
    );
  }

  Future<void> _scanQrCode() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 900);
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      _garments.insert(
        0,
        _Garment(
          name: 'Prenda importada QR',
          brand: 'Tienda escaneada',
          color: 'Negro',
          style: 'Casual',
          bg: const Color(0xFFF3E5F5),
          cat: 'Accesorios',
          fav: false,
          imageBytes: bytes,
        ),
      );
      _selectedCatIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Codigo QR escaneado y prenda importada')),
    );
  }

  void _showGarmentDetail(BuildContext context, _Garment g) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.88,
          expand: false,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: ctrl,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SheetHandle(),
                    const SizedBox(height: 18),
                    // Hero image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [g.bg, g.bg.withOpacity(0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              right: 10, bottom: 10,
                              child: FashionIcon(
                                  category: categoryFromString(g.cat),
                                  color:
                                      Colors.white.withOpacity(0.12),
                                  size: 110,
                                  strokeWidth: 2.0),
                            ),
                            Container(
                              width: 76, height: 76,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle),
                              padding: const EdgeInsets.all(16),
                              child: FashionIcon(
                                  category: categoryFromString(g.cat),
                                  color: AppColors.primary,
                                  size: 44,
                                  strokeWidth: 2.2),
                            ),
                            if (g.imageBytes != null)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(g.imageBytes!, fit: BoxFit.cover),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(g.name,
                        style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(g.brand,
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppColors.textHint)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _DetailChip(g.color),
                        _DetailChip(g.style),
                        _DetailChip(g.cat),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditGarment(context, g);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Editar'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCreateOutfitWithGarment(context, g);
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Usar en outfit'),
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 20,
              right: 20,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Text('Añadir prenda',
                  style: GoogleFonts.dmSans(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _AddOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Hacer foto',
                  sub: 'IA analiza la prenda',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Abriendo cámara...')));
                  },
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _AddOption(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Escanear código',
                  sub: 'Desde tienda',
                  color: const Color(0xFF7B2FBE),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Abriendo escáner...')));
                  },
                )),
              ]),
              const SizedBox(height: 10),
              _AddOption(
                icon: Icons.store_outlined,
                label: 'Buscar en tiendas',
                sub: 'Zara · H&M · Mango · Nike y más',
                color: const Color(0xFF0097A7),
                wide: true,
                onTap: () {
                  Navigator.pop(context);
                  _showStoreSearch(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoreSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Buscar en tiendas',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const TextField(
              decoration: InputDecoration(
                  hintText: 'Buscar prenda...',
                  prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              children: ['Zara', 'H&M', 'Mango', 'Nike', 'Pull&Bear']
                  .map((s) => Chip(
                      label: Text(s),
                      backgroundColor: AppColors.accentBg,
                      side: BorderSide.none,
                      labelStyle: GoogleFonts.dmSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)))
                  .toList()),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Buscar')),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    final ctrl = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Buscar en mi armario',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: 'Nombre, marca, color...',
                prefixIcon: Icon(Icons.search))),
        actions: [
          TextButton(
              onPressed: () {
                setState(() => _searchQuery = '');
                Navigator.pop(context);
              },
              child: const Text('Limpiar')),
          ElevatedButton(
              onPressed: () {
                setState(() => _searchQuery = ctrl.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Buscar')),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(
        child: StatefulBuilder(
          builder: (ctx, setLocal) => SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 16),
                Text('Filtros',
                    style: GoogleFonts.dmSans(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text('Color',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSec)),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      'Todos',
                      'Blanco',
                      'Negro',
                      'Beige',
                      'Rosa',
                      'Azul',
                      'Marrón',
                      'Dorado'
                    ]
                        .map((c) => FilterChip(
                            label: Text(c),
                            selected: _selectedColor == c,
                            selectedColor:
                                AppColors.primary.withOpacity(0.15),
                            checkmarkColor: AppColors.primary,
                            onSelected: (_) {
                              setState(() => _selectedColor = c);
                              setLocal(() {});
                            }))
                        .toList()),
                const SizedBox(height: 16),
                Text('Estilo',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSec)),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ['Todos', 'Casual', 'Elegante', 'Sport', 'Vintage']
                        .map((s) => FilterChip(
                            label: Text(s),
                            selected: _selectedStyle == s,
                            selectedColor:
                                AppColors.primary.withOpacity(0.15),
                            checkmarkColor: AppColors.primary,
                            onSelected: (_) {
                              setState(() => _selectedStyle = s);
                              setLocal(() {});
                            }))
                        .toList()),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(
                      child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedColor = 'Todos';
                        _selectedStyle = 'Todos';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aplicar'),
                  )),
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Edit Garment ─────────────────────────────────────────────────────────
  void _showEditGarment(BuildContext context, _Garment g) {
    final nameCtrl = TextEditingController(text: g.name);
    final brandCtrl = TextEditingController(text: g.brand);
    String selColor = g.color;
    String selStyle = g.style;
    String selCat = g.cat;
    const colors = ['Blanco','Negro','Beige','Rosa','Azul','Marrón','Dorado'];
    const styles = ['Casual','Elegante','Sport','Vintage'];
    const cats = ['Tops','Pantalones','Vestidos','Zapatos','Accesorios','Abrigos'];
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(child: StatefulBuilder(builder: (ctx, setLocal) =>
        SingleChildScrollView(padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 20, right: 20, top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _SheetHandle(), const SizedBox(height: 14),
            Text('Editar prenda', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Text('Color', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.textSec)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: colors.map((c) => ChoiceChip(
              label: Text(c), selected: selColor == c,
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              onSelected: (_) => setLocal(() => selColor = c),
            )).toList()),
            const SizedBox(height: 12),
            Text('Estilo', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.textSec)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: styles.map((s) => ChoiceChip(
              label: Text(s), selected: selStyle == s,
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              onSelected: (_) => setLocal(() => selStyle = s),
            )).toList()),
            const SizedBox(height: 12),
            Text('Categoría', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.textSec)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: cats.map((c) => ChoiceChip(
              label: Text(c), selected: selCat == c,
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              onSelected: (_) => setLocal(() => selCat = c),
            )).toList()),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar'))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  final idx = _garments.indexWhere((x) => x.name == g.name);
                  if (idx != -1) {
                    setState(() {
                      _garments[idx] = _Garment(
                        name: nameCtrl.text.trim().isEmpty ? g.name : nameCtrl.text.trim(),
                        brand: brandCtrl.text.trim().isEmpty ? g.brand : brandCtrl.text.trim(),
                        color: selColor, style: selStyle, bg: g.bg, cat: selCat, fav: g.fav,
                      );
                    });
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prenda actualizada ✓')));
                },
                child: const Text('Guardar'),
              )),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      )),
    );
  }

  // ─── Create / Build Outfit ────────────────────────────────────────────────
  void _showCreateOutfitDialog(BuildContext context) => _openOutfitBuilder(context, null);
  void _showCreateOutfitWithGarment(BuildContext context, _Garment g) => _openOutfitBuilder(context, g);

  void _openOutfitBuilder(BuildContext context, _Garment? pre) {
    final titleCtrl = TextEditingController();
    final Set<String> selected = pre != null ? {pre.name} : {};
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(child: StatefulBuilder(builder: (ctx, setLocal) =>
        Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: SizedBox(height: MediaQuery.of(ctx).size.height * 0.78,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.fromLTRB(20,16,20,0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _SheetHandle(), const SizedBox(height: 14),
                Text(pre != null ? 'Outfit con "${pre.name}"' : 'Crear outfit',
                    style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Nombre del outfit', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Text('Selecciona prendas (${selected.length})',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.textSec)),
                const SizedBox(height: 4),
              ])),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _garments.length,
                itemBuilder: (_, i) {
                  final item = _garments[i];
                  final isSel = selected.contains(item.name);
                  return CheckboxListTile(
                    value: isSel,
                    onChanged: (_) => setLocal(() => isSel ? selected.remove(item.name) : selected.add(item.name)),
                    title: Text(item.name, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                    subtitle: Text('${item.brand} · ${item.cat}', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint)),
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              )),
              Padding(padding: const EdgeInsets.fromLTRB(20,10,20,0),
                child: SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: selected.isEmpty ? null : () {
                    final title = titleCtrl.text.trim().isEmpty ? 'Mi Outfit' : titleCtrl.text.trim();
                    setState(() => _outfits.add(_Outfit(
                      title: title, items: selected.toList(),
                      bg: pre?.bg ?? const Color(0xFFE8F5EE), isAi: false,
                    )));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Outfit "$title" creado ✓')));
                  },
                  child: const Text('Crear outfit'),
                )),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      )),
    );
  }
}

// ─── Models ────────────────────────────────────────────────────────────────────
class _Cat {
  final String name;
  final IconData icon;
  const _Cat(this.name, this.icon);
}

class _Garment {
  final String name, brand, color, style, cat;
  final Color bg;
  final bool fav;
  final Uint8List? imageBytes;
  const _Garment(
      {required this.name,
      required this.brand,
      required this.color,
      required this.style,
      required this.bg,
      required this.cat,
      required this.fav,
      this.imageBytes});
  _Garment toggleFav() => _Garment(
      name: name,
      brand: brand,
      color: color,
      style: style,
      bg: bg,
      cat: cat,
      fav: !fav,
      imageBytes: imageBytes);
}

class _Outfit {
  final String title;
  final List<String> items;
  final Color bg;
  final bool isAi;
  const _Outfit(
      {required this.title,
      required this.items,
      required this.bg,
      required this.isAi});
}

// ─── Widgets ───────────────────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2))),
      );
}

class _Sheet extends StatelessWidget {
  final Widget child;
  const _Sheet({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: child,
      );
}

class _StatCol extends StatelessWidget {
  final String value, label;
  const _StatCol(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11, color: AppColors.textHint)),
      ]);
}

class _GarmentCard extends StatelessWidget {
  final _Garment garment;
  final VoidCallback onFav;
  final VoidCallback onTap;
  const _GarmentCard(
      {required this.garment, required this.onFav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Expanded(
            child: Stack(children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [garment.bg, garment.bg.withOpacity(0.55)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                ),
                child: Stack(alignment: Alignment.center, children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: FashionIcon(
                      category: categoryFromString(garment.cat),
                      color: Colors.white.withOpacity(0.16),
                      size: 90,
                      strokeWidth: 2.0,
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    padding: const EdgeInsets.all(13),
                    child: FashionIcon(
                      category: categoryFromString(garment.cat),
                      color: AppColors.primary,
                      size: 38,
                      strokeWidth: 2.2,
                    ),
                  ),
                  if (garment.imageBytes != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: Image.memory(garment.imageBytes!, fit: BoxFit.cover),
                      ),
                    ),
                ]),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onFav,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4)
                        ]),
                    child: Icon(
                        garment.fav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 15,
                        color: garment.fav
                            ? AppColors.primary
                            : AppColors.textHint),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(garment.name,
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(garment.brand,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.textHint)),
              const SizedBox(height: 5),
              Row(children: [
                _MiniTag(garment.color),
                const SizedBox(width: 4),
                _MiniTag(garment.style),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String text;
  const _MiniTag(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: AppColors.accentBg,
            borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: GoogleFonts.dmSans(
                fontSize: 9,
                color: AppColors.primary,
                fontWeight: FontWeight.w600)),
      );
}

class _DetailChip extends StatelessWidget {
  final String text;
  const _DetailChip(this.text);
  @override
  Widget build(BuildContext context) => Chip(
        label: Text(text,
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppColors.primary)),
        backgroundColor: AppColors.accentBg,
        side: BorderSide.none,
        padding: EdgeInsets.zero,
      );
}

class _OutfitCard extends StatelessWidget {
  final _Outfit outfit;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  const _OutfitCard(
      {required this.outfit, required this.onShare, required this.onDelete});

  static const _outfitCats = [
    FashionCategory.tops,
    FashionCategory.pants,
    FashionCategory.shoes,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [outfit.bg, outfit.bg.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(children: [
            Positioned(
              right: -18,
              bottom: -18,
              child: Icon(Icons.checkroom_outlined,
                  size: 120,
                  color: Colors.white.withOpacity(0.08)),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8),
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.07),
                                  blurRadius: 6)
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: FashionIcon(
                            category: _outfitCats[i],
                            color: AppColors.primary,
                            size: 30,
                            strokeWidth: 2.0,
                          ),
                        )),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(outfit.title,
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis)),
              if (outfit.isAi)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        AppColors.primary,
                        Color(0xFF7B2FBE)
                      ]),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 10, color: Colors.white),
                        SizedBox(width: 3),
                        Text('IA',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ]),
                ),
            ]),
            const SizedBox(height: 8),
            Wrap(
                spacing: 6,
                runSpacing: 4,
                children: outfit.items
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppColors.bgPage,
                              borderRadius:
                                  BorderRadius.circular(8)),
                          child: Text(item,
                              style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.textSec)),
                        ))
                    .toList()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 15),
                label: const Text('Publicar'),
                style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8)),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 15),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8)),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyWardrobe extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyWardrobe({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
                color: AppColors.accentBg, shape: BoxShape.circle),
            child: const Icon(Icons.checkroom_outlined,
                size: 44, color: AppColors.primaryMed),
          ),
          const SizedBox(height: 16),
          Text('No hay prendas aquí',
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Prueba con otro filtro o añade prendas',
              style: GoogleFonts.dmSans(
                  color: AppColors.textHint, fontSize: 13)),
          const SizedBox(height: 18),
          ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Añadir prenda')),
        ]),
      );
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  final bool wide;
  const _AddOption(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.color,
      required this.onTap,
      this.wide = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: wide ? double.infinity : null,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2))),
        child: wide
            ? Row(children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(label,
                      style: GoogleFonts.dmSans(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  Text(sub,
                      style: GoogleFonts.dmSans(
                          color: AppColors.textHint, fontSize: 11)),
                ]),
              ])
            : Column(children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(label,
                    style: GoogleFonts.dmSans(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(sub,
                    style: GoogleFonts.dmSans(
                        color: AppColors.textHint, fontSize: 10),
                    textAlign: TextAlign.center),
              ]),
      ),
    );
  }
}
