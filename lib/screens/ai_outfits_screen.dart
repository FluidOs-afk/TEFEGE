import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../widgets/fashion_icon.dart';

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
  final _seasonIcons = [
    Icons.local_florist_outlined,
    Icons.wb_sunny_outlined,
    Icons.forest_outlined,
    Icons.ac_unit_outlined,
  ];

  final List<_AiOutfit> _suggestions = [
    _AiOutfit(
        title: 'Look Primavera Casual',
        score: 97,
        occasion: 'Casual',
        items: ['Blazer Beige', 'Camiseta Blanca', 'Vaqueros Slouchy', 'Sneakers'],
        categories: [
          FashionCategory.coat,
          FashionCategory.tops,
          FashionCategory.pants,
          FashionCategory.shoes
        ],
        reason: 'Combinación perfecta para 18°C y cielos despejados. Tonos neutros que armonizan a la perfección.',
        gradient: [Color(0xFF1B6B44), Color(0xFF3CB87A)],
        saved: false),
    _AiOutfit(
        title: 'Trabajo Moderno',
        score: 94,
        occasion: 'Trabajo',
        items: ['Blazer Oversize', 'Mini Falda', 'Tacones Negros', 'Bolso Piel'],
        categories: [
          FashionCategory.coat,
          FashionCategory.dress,
          FashionCategory.shoes,
          FashionCategory.accessory
        ],
        reason: 'Outfit profesional con un toque moderno. Ideal para reuniones y presentaciones.',
        gradient: [Color(0xFF4A1275), Color(0xFF9C27B0)],
        saved: false),
    _AiOutfit(
        title: 'Noche Elegante',
        score: 91,
        occasion: 'Noche',
        items: ['Vestido Satinado', 'Tacones Negros', 'Collar Dorado'],
        categories: [
          FashionCategory.dress,
          FashionCategory.shoes,
          FashionCategory.accessory,
          FashionCategory.tops
        ],
        reason: 'Sofisticado para salidas nocturnas. El satinado aporta luminosidad bajo la luz artificial.',
        gradient: [Color(0xFF1C2541), Color(0xFF3A506B)],
        saved: true),
  ];

  void _generate() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nuevos outfits generados')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          // ─── Hero AppBar ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F4229), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text('IA Outfits',
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3)),
                        ]),
                        const SizedBox(height: 6),
                        Text('Combinaciones personalizadas con tu armario',
                            style: GoogleFonts.dmSans(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.wb_sunny_outlined,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text('Madrid · 18°C · Soleado',
                                style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('IA Outfits',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ]),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          // ─── Filters card ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3))
                  ]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Personaliza tu look',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 14),
                Text('Ocasión',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _occasions.length,
                    itemBuilder: (_, i) {
                      final sel = _occasion == _occasions[i];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _occasion = _occasions[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: sel
                                ? const LinearGradient(colors: [
                                    AppColors.primary,
                                    AppColors.primaryMed
                                  ])
                                : null,
                            color: sel ? null : AppColors.bgPage,
                            borderRadius: BorderRadius.circular(18),
                            border: sel
                                ? null
                                : Border.all(color: AppColors.border),
                          ),
                          child: Text(_occasions[i],
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textSec,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Text('Temporada',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                    children: List.generate(_seasons.length, (i) {
                  final sel = _season == _seasons[i];
                  return Expanded(
                      child: GestureDetector(
                    onTap: () =>
                        setState(() => _season = _seasons[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                          right: i < _seasons.length - 1 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.accentBg
                            : AppColors.bgPage,
                        borderRadius: BorderRadius.circular(12),
                        border: sel
                            ? Border.all(
                                color: AppColors.primary, width: 1.5)
                            : Border.all(color: AppColors.border),
                      ),
                      child: Column(children: [
                        Icon(_seasonIcons[i],
                            size: 18,
                            color: sel
                                ? AppColors.primary
                                : AppColors.textHint),
                        const SizedBox(height: 3),
                        Text(_seasons[i],
                            style: GoogleFonts.dmSans(
                                fontSize: 9,
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.textSec,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w400)),
                      ]),
                    ),
                  ));
                })),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generate,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome_rounded,
                            size: 18),
                    label: Text(
                        _isGenerating
                            ? 'Analizando armario...'
                            : 'Generar outfits',
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ]),
            ),
          ),

          // ─── Section title ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text('Sugerencias para ti',
                  style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
          ),

          // ─── Cards ───────────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _AiCard(
                outfit: _suggestions[i],
                onSave: () => setState(
                    () => _suggestions[i] = _suggestions[i].toggleSaved()),
                onPublish: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '"${_suggestions[i].title}" publicado'))),
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
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 18),
                Text(outfit.title,
                    style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 5),
                  Text('${outfit.score}% compatibilidad con tu armario',
                      style: GoogleFonts.dmSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ]),
                const SizedBox(height: 14),
                Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                color: AppColors.accentBg,
                                shape: BoxShape.circle),
                            child: const Icon(
                                Icons.smart_toy_outlined,
                                size: 17,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(outfit.reason,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: AppColors.textSec,
                                      height: 1.5))),
                        ])),
                const SizedBox(height: 16),
                Text('Prendas del outfit',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                ...List.generate(
                    outfit.items.length,
                    (i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                              color: AppColors.bgPage,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.border)),
                          child: Row(children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                  color: AppColors.accentBg,
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(9),
                              child: FashionIcon(
                                category: outfit.categories[
                                    i < outfit.categories.length
                                        ? i
                                        : 0],
                                color: AppColors.primary,
                                size: 24,
                                strokeWidth: 1.8,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(outfit.items[i],
                                    style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary))),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textHint, size: 18),
                          ]),
                        )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _AiOutfit {
  final String title, occasion, reason;
  final int score;
  final List<String> items;
  final List<FashionCategory> categories;
  final List<Color> gradient;
  final bool saved;
  const _AiOutfit(
      {required this.title,
      required this.score,
      required this.occasion,
      required this.items,
      required this.categories,
      required this.reason,
      required this.gradient,
      required this.saved});
  _AiOutfit toggleSaved() => _AiOutfit(
      title: title,
      score: score,
      occasion: occasion,
      items: items,
      categories: categories,
      reason: reason,
      gradient: gradient,
      saved: !saved);
}

// ─── Card ─────────────────────────────────────────────────────────────────────
class _AiCard extends StatelessWidget {
  final _AiOutfit outfit;
  final VoidCallback onSave, onPublish, onDetail;
  const _AiCard(
      {required this.outfit,
      required this.onSave,
      required this.onPublish,
      required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetail,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: outfit.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20))),
            child: Row(children: [
              // 2×2 icon grid
              SizedBox(
                width: 76,
                height: 76,
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  padding: EdgeInsets.zero,
                  children: outfit.categories
                      .take(4)
                      .map((cat) => Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(7),
                            child: FashionIcon(
                              category: cat,
                              color: Colors.white.withOpacity(0.95),
                              size: 22,
                              strokeWidth: 1.8,
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${outfit.score}% match',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(outfit.title,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white)),
                const SizedBox(height: 5),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(outfit.occasion,
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500))),
              ])),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: outfit.items
                      .map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.accentBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.primaryLight
                                        .withOpacity(0.5))),
                            child: Text(item,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ))
                      .toList()),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.bgPage,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    const Icon(Icons.smart_toy_outlined,
                        size: 16, color: AppColors.primaryMed),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(outfit.reason,
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppColors.textSec,
                                height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)),
                  ])),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  onPressed: onSave,
                  icon: Icon(
                      outfit.saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 15),
                  label: Text(outfit.saved ? 'Guardado' : 'Guardar',
                      style: GoogleFonts.dmSans(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: ElevatedButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.send_rounded,
                      size: 15, color: Colors.white),
                  label: Text('Publicar',
                      style: GoogleFonts.dmSans(
                          color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
