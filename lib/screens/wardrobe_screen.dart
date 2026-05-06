import 'package:flutter/material.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});
  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCatIndex = 0;
  String _selectedColor = 'Todos';
  String _selectedStyle = 'Todos';

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
    _Garment(name: 'Blazer Oversize', brand: 'Zara', color: 'Beige', style: 'Casual', emoji: '🧥', bg: Color(0xFFF5F0EB), cat: 'Tops', fav: true),
    _Garment(name: 'Vaqueros Slouchy', brand: 'Mango', color: 'Azul', style: 'Casual', emoji: '👖', bg: Color(0xFFE3F2FD), cat: 'Pantalones', fav: false),
    _Garment(name: 'Vestido Satinado', brand: 'H&M', color: 'Rosa', style: 'Elegante', emoji: '👗', bg: Color(0xFFFCE4EC), cat: 'Vestidos', fav: true),
    _Garment(name: 'Sneakers Blancas', brand: 'Nike', color: 'Blanco', style: 'Sport', emoji: '👟', bg: Color(0xFFF3F4F6), cat: 'Zapatos', fav: false),
    _Garment(name: 'Camiseta Básica', brand: 'Uniqlo', color: 'Blanco', style: 'Casual', emoji: '👕', bg: Color(0xFFFFF8F0), cat: 'Tops', fav: false),
    _Garment(name: 'Bolso Piel', brand: 'Massimo Dutti', color: 'Marrón', style: 'Elegante', emoji: '👜', bg: Color(0xFFFBEEE4), cat: 'Accesorios', fav: true),
    _Garment(name: 'Mini Falda', brand: 'Pull&Bear', color: 'Negro', style: 'Casual', emoji: '🩳', bg: Color(0xFFF5F5F5), cat: 'Pantalones', fav: false),
    _Garment(name: 'Tacones Negros', brand: 'Stradivarius', color: 'Negro', style: 'Elegante', emoji: '👠', bg: Color(0xFFEEEEEE), cat: 'Zapatos', fav: true),
    _Garment(name: 'Abrigo Lana', brand: 'Zara', color: 'Beige', style: 'Elegante', emoji: '🧣', bg: Color(0xFFF9F3EC), cat: 'Abrigos', fav: false),
    _Garment(name: 'Collar Dorado', brand: 'Mango', color: 'Dorado', style: 'Elegante', emoji: '📿', bg: Color(0xFFFFF8E1), cat: 'Accesorios', fav: false),
  ];

  final List<_Outfit> _outfits = [
    _Outfit(title: 'Look Casual Viernes', items: ['Blazer Beige', 'Vaqueros Slouchy', 'Sneakers'], emoji: '✨', bg: Color(0xFFFCE4EC), isAi: false),
    _Outfit(title: 'Primavera Pastel', items: ['Vestido Rosa', 'Tacones Nude', 'Bolso Blanco'], emoji: '🌸', bg: Color(0xFFF3E5F5), isAi: true),
    _Outfit(title: 'Noche Elegante', items: ['Vestido Satinado', 'Tacones Negros', 'Bolso Piel'], emoji: '🌙', bg: Color(0xFFEEEEEE), isAi: true),
  ];

  List<_Garment> get _filtered => _garments.where((g) {
    final catOk = _selectedCatIndex == 0 || g.cat == _cats[_selectedCatIndex].name;
    final colorOk = _selectedColor == 'Todos' || g.color == _selectedColor;
    final styleOk = _selectedStyle == 'Todos' || g.style == _selectedStyle;
    return catOk && colorOk && styleOk;
  }).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Mi Armario'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => _showSearch(context)),
          IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () => _showFilters(context)),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE8537A),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFFE8537A),
          indicatorWeight: 2,
          tabs: const [Tab(text: 'Prendas'), Tab(text: 'Mis Outfits')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGarments(), _buildOutfits()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal(context),
        backgroundColor: const Color(0xFFE8537A),
        icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
        label: const Text('Añadir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildGarments() {
    return Column(
      children: [
        // Stats bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCol('${_garments.length}', 'Prendas'),
              Container(width: 1, height: 32, color: Colors.grey[200]),
              _StatCol('${_outfits.length}', 'Outfits'),
              Container(width: 1, height: 32, color: Colors.grey[200]),
              _StatCol('${_garments.where((g) => g.fav).length}', 'Favoritos'),
            ],
          ),
        ),
        // Category chips
        Container(
          color: Colors.white,
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final sel = _selectedCatIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCatIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFE8537A) : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_cats[i].icon, size: 14, color: sel ? Colors.white : const Color(0xFF666666)),
                      const SizedBox(width: 5),
                      Text(_cats[i].name, style: TextStyle(fontSize: 12,
                          color: sel ? Colors.white : const Color(0xFF666666),
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        // Grid
        Expanded(
          child: _filtered.isEmpty
              ? _EmptyWardrobe(onAdd: () => _showAddModal(context))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.78),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _GarmentCard(
                    garment: _filtered[i],
                    onFav: () => setState(() {
                      final idx = _garments.indexWhere((g) => g.name == _filtered[i].name);
                      if (idx != -1) _garments[idx] = _garments[idx].toggleFav();
                    }),
                    onTap: () => _showGarmentDetail(context, _filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOutfits() {
    return _outfits.isEmpty
        ? Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('👗', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              const Text('Sin outfits aún', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () {}, child: const Text('Crear outfit')),
            ]),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _outfits.length,
            itemBuilder: (_, i) => _OutfitCard(
              outfit: _outfits[i],
              onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('📤 "${_outfits[i].title}" compartido!'),
                      backgroundColor: const Color(0xFFE8537A))),
              onDelete: () => setState(() => _outfits.removeAt(i)),
            ),
          );
  }

  void _showGarmentDetail(BuildContext context, _Garment g) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55, minChildSize: 0.4, maxChildSize: 0.85, expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Center(child: Container(height: 140, width: double.infinity,
                decoration: BoxDecoration(color: g.bg, borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text(g.emoji, style: const TextStyle(fontSize: 72))))),
              const SizedBox(height: 16),
              Text(g.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(g.brand, style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 12),
              Row(children: [
                _DetailChip(g.color), const SizedBox(width: 8),
                _DetailChip(g.style), const SizedBox(width: 8),
                _DetailChip(g.cat),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE8537A),
                      side: const BorderSide(color: Color(0xFFE8537A))),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () { Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añadida al outfit'))); },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Usar en outfit'),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 20, right: 20, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Añadir prenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _AddOption(icon: Icons.camera_alt_outlined, label: 'Hacer foto',
                sub: 'IA analiza la prenda', color: const Color(0xFFE8537A),
                onTap: () { Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('📸 Abriendo cámara...'), backgroundColor: Color(0xFFE8537A))); })),
            const SizedBox(width: 10),
            Expanded(child: _AddOption(icon: Icons.qr_code_scanner_rounded, label: 'Escanear código',
                sub: 'Desde tienda', color: const Color(0xFF9C27B0),
                onTap: () { Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📷 Abriendo escáner...'))); })),
          ]),
          const SizedBox(height: 10),
          _AddOption(icon: Icons.store_outlined, label: 'Buscar en tiendas',
              sub: 'Zara · H&M · Mango · Nike y más', color: const Color(0xFF00BCD4), wide: true,
              onTap: () { Navigator.pop(context); _showStoreSearch(context); }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showStoreSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Buscar en tiendas'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const TextField(decoration: InputDecoration(hintText: 'Buscar prenda...', prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: ['Zara', 'H&M', 'Mango', 'Nike', 'Pull&Bear']
              .map((s) => Chip(label: Text(s), backgroundColor: const Color(0xFFFCE4EC),
                  side: BorderSide.none, labelStyle: const TextStyle(color: Color(0xFFE8537A))))
              .toList()),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Buscar')),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Buscar en mi armario'),
        content: TextField(autofocus: true,
            decoration: const InputDecoration(hintText: 'Nombre, marca, color...',
                prefixIcon: Icon(Icons.search))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Buscar')),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: ['Todos', 'Blanco', 'Negro', 'Beige', 'Rosa', 'Azul', 'Marrón', 'Dorado']
                .map((c) => FilterChip(label: Text(c), selected: _selectedColor == c,
                    selectedColor: const Color(0xFFE8537A).withOpacity(0.18),
                    checkmarkColor: const Color(0xFFE8537A),
                    onSelected: (_) { setState(() => _selectedColor = c); setLocal(() {}); }))
                .toList()),
            const SizedBox(height: 14),
            const Text('Estilo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: ['Todos', 'Casual', 'Elegante', 'Sport', 'Vintage']
                .map((s) => FilterChip(label: Text(s), selected: _selectedStyle == s,
                    selectedColor: const Color(0xFFE8537A).withOpacity(0.18),
                    checkmarkColor: const Color(0xFFE8537A),
                    onSelected: (_) { setState(() => _selectedStyle = s); setLocal(() {}); }))
                .toList()),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () { setState(() { _selectedColor = 'Todos'; _selectedStyle = 'Todos'; }); Navigator.pop(context); },
                child: const Text('Limpiar'),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Aplicar'))),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─── Models ────────────────────────────────────────────────────────────────────
class _Cat { final String name; final IconData icon; const _Cat(this.name, this.icon); }

class _Garment {
  final String name, brand, color, style, emoji, cat;
  final Color bg;
  final bool fav;
  const _Garment({required this.name, required this.brand, required this.color, required this.style,
      required this.emoji, required this.bg, required this.cat, required this.fav});
  _Garment toggleFav() => _Garment(name: name, brand: brand, color: color, style: style,
      emoji: emoji, bg: bg, cat: cat, fav: !fav);
}

class _Outfit {
  final String title, emoji;
  final List<String> items;
  final Color bg;
  final bool isAi;
  const _Outfit({required this.title, required this.items, required this.emoji, required this.bg, required this.isAi});
}

// ─── Widgets ───────────────────────────────────────────────────────────────────
class _StatCol extends StatelessWidget {
  final String value, label;
  const _StatCol(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE8537A))),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
  ]);
}

class _GarmentCard extends StatelessWidget {
  final _Garment garment;
  final VoidCallback onFav;
  final VoidCallback onTap;
  const _GarmentCard({required this.garment, required this.onFav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Container(width: double.infinity,
                decoration: BoxDecoration(color: garment.bg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                child: Center(child: Text(garment.emoji, style: const TextStyle(fontSize: 52)))),
              Positioned(top: 8, right: 8,
                child: GestureDetector(
                  onTap: onFav,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon(garment.fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16, color: garment.fav ? const Color(0xFFE8537A) : Colors.grey),
                  ),
                )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(garment.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2D2D2D)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(garment.brand, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
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
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: const TextStyle(fontSize: 9, color: Color(0xFFE8537A), fontWeight: FontWeight.w600)),
  );
}

class _DetailChip extends StatelessWidget {
  final String text;
  const _DetailChip(this.text);
  @override
  Widget build(BuildContext context) => Chip(
    label: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFFE8537A))),
    backgroundColor: const Color(0xFFFCE4EC), side: BorderSide.none, padding: EdgeInsets.zero,
  );
}

class _OutfitCard extends StatelessWidget {
  final _Outfit outfit;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  const _OutfitCard({required this.outfit, required this.onShare, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 120,
          decoration: BoxDecoration(color: outfit.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Center(child: Text(outfit.emoji, style: const TextStyle(fontSize: 56)))),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(outfit.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
              if (outfit.isAi) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE8537A), Color(0xFF9C27B0)]),
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                  SizedBox(width: 3),
                  Text('IA', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 4, children: outfit.items.map((item) =>
                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                    child: Text(item, style: const TextStyle(fontSize: 11, color: Color(0xFF555555))))).toList()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 15),
                label: const Text('Publicar'),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE8537A),
                    side: const BorderSide(color: Color(0xFFE8537A)),
                    padding: const EdgeInsets.symmetric(vertical: 8)),
              )),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 15),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8)),
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
      const Text('👗', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 14),
      const Text('No hay prendas aquí', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
      const SizedBox(height: 6),
      const Text('Prueba con otro filtro o añade prendas', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
      const SizedBox(height: 18),
      ElevatedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Añadir prenda')),
    ]),
  );
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  final bool wide;
  const _AddOption({required this.icon, required this.label, required this.sub,
      required this.color, required this.onTap, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: wide ? double.infinity : null,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2))),
        child: wide
            ? Row(children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(sub, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)),
                ]),
              ])
            : Column(children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(sub, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 10), textAlign: TextAlign.center),
              ]),
      ),
    );
  }
}
