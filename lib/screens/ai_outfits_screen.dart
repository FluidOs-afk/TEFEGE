import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/ai_outfit.dart';
import '../models/wardrobe_item.dart';
import '../providers/auth_provider.dart';
import '../services/ai_outfits_service.dart' show AiOutfitsService, BackendException, WeatherInfo;
import '../services/wardrobe_service.dart';
import 'wardrobe_screen.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────
class AiOutfitsScreen extends StatelessWidget {
  const AiOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 150,
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
                                    fontWeight: FontWeight.w800)),
                          ]),
                          const SizedBox(height: 6),
                          Text(
                              'Combinaciones personalizadas con tu armario',
                              style: GoogleFonts.dmSans(
                                  color: Colors.white70, fontSize: 13)),
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
                titlePadding:
                    const EdgeInsets.only(left: 16, bottom: 48),
              ),
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle:
                    GoogleFonts.dmSans(fontSize: 13),
                tabs: const [
                  Tab(text: 'Generar'),
                  Tab(text: 'Historial'),
                ],
              ),
              iconTheme:
                  const IconThemeData(color: Colors.white),
            ),
          ],
          body: const TabBarView(
            children: [
              _GenerateTab(),
              _HistoryTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab: Generar ─────────────────────────────────────────────────────────────
class _GenerateTab extends StatefulWidget {
  const _GenerateTab();
  @override
  State<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<_GenerateTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  WeatherInfo? _weather;
  bool _weatherLoading = false;
  bool _locationDenied = false;

  String? _selectedOccasion;
  bool _generating = false;
  String? _result;
  List<WardrobeItem> _wardrobeItems = [];
  bool _saving = false;
  bool _saved = false;

  static const _occasions = [
    'Casual', 'Trabajo', 'Deporte', 'Evento', 'Noche',
  ];

  @override
  void initState() {
    super.initState();
    _loadWeatherAndWardrobe();
  }

  Future<void> _loadWeatherAndWardrobe() async {
    final uid =
        context.read<AuthProvider>().currentUser?.uid ?? '';
    // Cargar armario
    if (uid.isNotEmpty) {
      final items = await WardrobeService.instance.getItems(uid);
      if (mounted) setState(() => _wardrobeItems = items);
    }
    // Cargar clima
    setState(() => _weatherLoading = true);
    try {
      final weather = await AiOutfitsService.instance.getWeather();
      if (mounted) setState(() => _weather = weather);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _locationDenied = e.toString().contains('LocationDenied') ||
                e is Exception);
      }
    } finally {
      if (mounted) setState(() => _weatherLoading = false);
    }
  }

  Future<void> _generate() async {
    if (_selectedOccasion == null || _generating) return;
    setState(() {
      _generating = true;
      _result = null;
      _saved = false;
    });
    try {
      final weatherCtx = _weather != null
          ? '${_weather!.temperatura.toStringAsFixed(0)}°C, ${_weather!.descripcion}'
          : 'Temperatura desconocida';
      final suggestion = await AiOutfitsService.instance
          .generateOutfit(_selectedOccasion!, weatherCtx, _wardrobeItems);
      if (mounted) setState(() => _result = suggestion);
    } on BackendException catch (e) {
      if (!mounted) return;
      final mensaje = switch (e.code) {
        'unauthenticated'    => 'Debes iniciar sesión para generar outfits.',
        'invalid-argument'   => e.message,
        'resource-exhausted' => 'Has alcanzado el límite de 20 outfits por día.',
        'internal'           => 'Error del servidor. Inténtalo más tarde.',
        _                    => 'Error inesperado. Inténtalo más tarde.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje, style: GoogleFonts.dmSans())),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
              style: GoogleFonts.dmSans()),
        ));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _saveOutfit() async {
    if (_result == null || _saving) return;
    final uid =
        context.read<AuthProvider>().currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    setState(() => _saving = true);
    try {
      final outfit = AiOutfit(
        id: '',
        occasion: _selectedOccasion!,
        weatherContext: _weather != null
            ? '${_weather!.temperatura.toStringAsFixed(0)}°C, ${_weather!.descripcion}'
            : '',
        suggestion: _result!,
        wardrobeUsed: _wardrobeItems.map((i) => i.id).toList(),
        createdAt: DateTime.now(),
      );
      await AiOutfitsService.instance.saveOutfit(uid, outfit);
      if (mounted) {
        setState(() => _saved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Outfit guardado en tu historial',
                  style: GoogleFonts.dmSans())),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar',
                  style: GoogleFonts.dmSans())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Estado vacío: sin prendas
    if (_wardrobeItems.isEmpty && !_generating) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.checkroom_outlined,
                  size: 56, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text('Añade prendas a tu armario primero',
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                  'La IA necesita conocer tu armario para generar outfits',
                  style: GoogleFonts.dmSans(
                      color: AppColors.textHint, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const WardrobeScreen()),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ir a Mi Armario'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Clima ──────────────────────────────────────────────────
          _WeatherCard(
            weather: _weather,
            loading: _weatherLoading,
            denied: _locationDenied,
            onRetry: _loadWeatherAndWardrobe,
          ),
          const SizedBox(height: 16),

          // ── Ocasión ────────────────────────────────────────────────
          Text('Ocasión',
              style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _occasions.map((occ) {
              final sel = _selectedOccasion == occ;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedOccasion = occ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: sel
                        ? const LinearGradient(colors: [
                            AppColors.primary,
                            AppColors.primaryMed
                          ])
                        : null,
                    color: sel ? null : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel
                            ? AppColors.primary
                            : AppColors.border,
                        width: sel ? 0 : 1),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : null,
                  ),
                  child: Text(occ,
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: sel
                              ? Colors.white
                              : AppColors.textSec)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Botón generar ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_selectedOccasion == null || _generating)
                  ? null
                  : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                  _generating
                      ? 'Generando outfit...'
                      : _selectedOccasion == null
                          ? 'Selecciona una ocasión'
                          : 'Generar outfit',
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),

          // ── Resultado ──────────────────────────────────────────────
          if (_result != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.smart_toy_outlined,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('Outfit generado por IA',
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: _result!,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.5),
                      h3: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary),
                      listBullet: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.textSec),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Prendas usadas
            if (_wardrobeItems.isNotEmpty) ...[
              Text('Prendas de tu armario',
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textSec)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: _wardrobeItems
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.accentBg,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(item.name,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (_saved || _saving) ? null : _saveOutfit,
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary))
                    : Icon(
                        _saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 18),
                label: Text(
                    _saved
                        ? 'Guardado en historial'
                        : 'Guardar outfit',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab: Historial ───────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final uid =
        context.watch<AuthProvider>().currentUser?.uid ?? '';

    return StreamBuilder<List<AiOutfit>>(
      stream: uid.isNotEmpty
          ? AiOutfitsService.instance.streamSavedOutfits(uid)
          : const Stream.empty(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary));
        }
        final outfits = snap.data ?? [];
        if (outfits.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_outlined,
                      size: 52, color: AppColors.textHint),
                  const SizedBox(height: 14),
                  Text('Aún no has guardado ningún outfit',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                      'Genera un outfit y pulsa "Guardar" para verlo aquí',
                      style: GoogleFonts.dmSans(
                          color: AppColors.textHint, fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: outfits.length,
          itemBuilder: (_, i) =>
              _HistoryCard(outfit: outfits[i]),
        );
      },
    );
  }
}

// ─── History card (expandible) ────────────────────────────────────────────────
class _HistoryCard extends StatefulWidget {
  final AiOutfit outfit;
  const _HistoryCard({required this.outfit});
  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final outfit = widget.outfit;
    final dateStr =
        '${outfit.createdAt.day}/${outfit.createdAt.month}/${outfit.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                // Ocasión chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryMed]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(outfit.occasion,
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (outfit.weatherContext.isNotEmpty)
                        Text(outfit.weatherContext,
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.textSec)),
                      Text(dateStr,
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textHint)),
                    ],
                  ),
                ),
                Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.textHint),
              ]),
            ),
          ),

          // Preview (siempre visible)
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                outfit.suggestion.length > 120
                    ? '${outfit.suggestion.substring(0, 120)}…'
                    : outfit.suggestion,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSec,
                    height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Contenido completo (expandible)
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: MarkdownBody(
                data: outfit.suggestion,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5),
                  h3: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                  listBullet: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.textSec),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Weather card ─────────────────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final WeatherInfo? weather;
  final bool loading;
  final bool denied;
  final VoidCallback onRetry;

  const _WeatherCard({
    required this.weather,
    required this.loading,
    required this.denied,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)),
          const SizedBox(width: 12),
          Text('Obteniendo el clima...',
              style: GoogleFonts.dmSans(
                  color: AppColors.textSec, fontSize: 13)),
        ]),
      );
    }

    if (denied || weather == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accentBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.location_off_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                'Activa la ubicación para recomendaciones según el tiempo',
                style: GoogleFonts.dmSans(
                    color: AppColors.textSec, fontSize: 12)),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('Reintentar',
                style: GoogleFonts.dmSans(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ]),
      );
    }

    final icon = _weatherIcon(weather!.descripcion);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4229), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              '${weather!.temperatura.toStringAsFixed(0)}°C · ${weather!.descripcion}',
              style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          Text('Clima actual en tu ubicación',
              style: GoogleFonts.dmSans(
                  color: Colors.white70, fontSize: 11)),
        ]),
      ]),
    );
  }

  IconData _weatherIcon(String desc) => switch (desc) {
        'Despejado' => Icons.wb_sunny_outlined,
        'Parcialmente nublado' => Icons.cloud_outlined,
        'Niebla' => Icons.foggy,
        'Lluvia' => Icons.water_drop_outlined,
        'Nieve' => Icons.ac_unit_outlined,
        'Chubascos' => Icons.umbrella_outlined,
        _ => Icons.thunderstorm_outlined,
      };
}
