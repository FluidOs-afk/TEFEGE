import 'package:flutter/material.dart';

class AiOutfitsScreen extends StatefulWidget {
  const AiOutfitsScreen({super.key});
  @override
  State<AiOutfitsScreen> createState() => _AiOutfitsScreenState();
}

class _AiOutfitsScreenState extends State<AiOutfitsScreen> {
  bool _isGenerating = false;
  String _occasion = 'Casual';
  String _season = 'Primavera';

  final _occasions = ['Casual', 'Trabajo', 'Noche', 'Deporte', 'Evento', 'Viaje'];
  final _seasons = ['Primavera', 'Verano', 'Otoño', 'Invierno'];
  final _seasonIcons = ['🌸', '☀️', '🍂', '❄️'];

  final List<_AiOutfit> _suggestions = [
    _AiOutfit(title: 'Look Primavera Casual', score: 97, occasion: 'Casual',
        items: ['Blazer Beige', 'Camiseta Blanca', 'Vaqueros Slouchy', 'Sneakers'],
        emojis: ['🧥', '👕', '👖', '👟'],
        reason: 'Combinación perfecta para 18°C y cielos despejados. Tonos neutros que armonizan a la perfección.',
        gradient: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)], saved: false),
    _AiOutfit(title: 'Trabajo Moderno', score: 94, occasion: 'Trabajo',
        items: ['Blazer Oversize', 'Mini Falda', 'Tacones Negros', 'Bolso Piel'],
        emojis: ['🧥', '🩳', '👠', '👜'],
        reason: 'Outfit profesional con un toque moderno. Ideal para reuniones y presentaciones.',
        gradient: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)], saved: false),
    _AiOutfit(title: 'Noche Elegante', score: 91, occasion: 'Noche',
        items: ['Vestido Satinado', 'Tacones Negros', 'Collar Dorado'],
        emojis: ['👗', '👠', '📿'],
        reason: 'Sofisticado para salidas nocturnas. El satinado aporta luminosidad bajo la luz artificial.',
        gradient: [Color(0xFFEEEEEE), Color(0xFFBDBDBD)], saved: true),
  ];

  void _generate() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ ¡Nuevos outfits generados!'),
            backgroundColor: Color(0xFFE8537A), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          // Hero AppBar
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFE8537A),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8537A), Color(0xFFFF8FAB)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Text('✨', style: TextStyle(fontSize: 26)),
                        SizedBox(width: 8),
                        Text('IA Outfits', style: TextStyle(color: Colors.white, fontSize: 24,
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ]),
                      const SizedBox(height: 6),
                      const Text('Combinaciones personalizadas con tu armario',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('☀️', style: TextStyle(fontSize: 13)),
                          SizedBox(width: 6),
                          Text('Madrid · 18°C · Soleado',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
              title: const Text('✨ IA Outfits',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          // Filters card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Personaliza', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                const Text('Ocasión', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _occasions.length,
                    itemBuilder: (_, i) {
                      final sel = _occasion == _occasions[i];
                      return GestureDetector(
                        onTap: () => setState(() => _occasion = _occasions[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: sel ? const LinearGradient(colors: [Color(0xFFE8537A), Color(0xFFFF8FAB)]) : null,
                            color: sel ? null : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(_occasions[i], style: TextStyle(fontSize: 12,
                              color: sel ? Colors.white : const Color(0xFF666666),
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Temporada', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 8),
                Row(children: List.generate(_seasons.length, (i) {
                  final sel = _season == _seasons[i];
                  return Expanded(child: GestureDetector(
                    onTap: () => setState(() => _season = _seasons[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: i < _seasons.length - 1 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFE8537A).withOpacity(0.1) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: sel ? Border.all(color: const Color(0xFFE8537A), width: 1.5) : null,
                      ),
                      child: Column(children: [
                        Text(_seasonIcons[i], style: const TextStyle(fontSize: 18)),
                        Text(_seasons[i], style: TextStyle(fontSize: 9,
                            color: sel ? const Color(0xFFE8537A) : const Color(0xFF666666),
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                      ]),
                    ),
                  ));
                })),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generate,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: const Color(0xFFE8537A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: _isGenerating
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    label: Text(_isGenerating ? 'Analizando armario...' : 'Generar outfits',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ]),
            ),
          ),

          // Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text('Sugerencias para ti',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
            ),
          ),

          // Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _AiCard(
                outfit: _suggestions[i],
                onSave: () => setState(() => _suggestions[i] = _suggestions[i].toggleSaved()),
                onPublish: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('✨ "${_suggestions[i].title}" publicado!'),
                    backgroundColor: const Color(0xFFE8537A), behavior: SnackBarBehavior.floating)),
                onDetail: () => _showDetail(context, _suggestions[i]),
              ),
              childCount: _suggestions.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, _AiOutfit outfit) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.88, expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(outfit.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFE8537A), size: 16),
              const SizedBox(width: 4),
              Text('${outfit.score}% de compatibilidad con tu armario',
                  style: const TextStyle(color: Color(0xFFE8537A), fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('🤖', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(outfit.reason,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5))),
                ])),
            const SizedBox(height: 14),
            const Text('Prendas del outfit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...List.generate(outfit.items.length, (i) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(outfit.emojis[i], style: const TextStyle(fontSize: 24)),
              title: Text(outfit.items[i], style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
            )),
          ]),
        ),
      ),
    );
  }
}

class _AiOutfit {
  final String title, occasion, reason;
  final int score;
  final List<String> items, emojis;
  final List<Color> gradient;
  final bool saved;
  const _AiOutfit({required this.title, required this.score, required this.occasion,
      required this.items, required this.emojis, required this.reason,
      required this.gradient, required this.saved});
  _AiOutfit toggleSaved() => _AiOutfit(title: title, score: score, occasion: occasion,
      items: items, emojis: emojis, reason: reason, gradient: gradient, saved: !saved);
}

class _AiCard extends StatelessWidget {
  final _AiOutfit outfit;
  final VoidCallback onSave, onPublish, onDetail;
  const _AiCard({required this.outfit, required this.onSave, required this.onPublish, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetail,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: outfit.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(children: [
              // Emoji grid
              SizedBox(width: 72, height: 72,
                child: GridView.count(crossAxisCount: 2, physics: const NeverScrollableScrollPhysics(),
                    children: outfit.emojis.take(4).map((e) =>
                        Center(child: Text(e, style: const TextStyle(fontSize: 24)))).toList())),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome, size: 11, color: Color(0xFFE8537A)),
                    const SizedBox(width: 3),
                    Text('${outfit.score}% match',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE8537A))),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(outfit.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D2D2D))),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                    child: Text(outfit.occasion, style: const TextStyle(fontSize: 11, color: Color(0xFF666666)))),
              ])),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 6, runSpacing: 5,
                  children: outfit.items.map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF0F3), borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFD6E0))),
                    child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFFE8537A), fontWeight: FontWeight.w500)),
                  )).toList()),
              const SizedBox(height: 10),
              Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Text('🤖', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(outfit.reason,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF666666), height: 1.4),
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ])),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: onSave,
                  icon: Icon(outfit.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 15, color: const Color(0xFFE8537A)),
                  label: Text(outfit.saved ? 'Guardado' : 'Guardar',
                      style: const TextStyle(color: Color(0xFFE8537A), fontSize: 13)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE8537A)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.send_rounded, size: 15, color: Colors.white),
                  label: const Text('Publicar', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8537A),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                )),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
