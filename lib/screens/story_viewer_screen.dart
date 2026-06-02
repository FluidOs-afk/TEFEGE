import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/story_model.dart';
import '../services/stories_service.dart';
import '../widgets/avatar_with_frame.dart';

class StoryViewerScreen extends StatefulWidget {
  /// Lista completa de historias activas (una por usuario), en orden del feed.
  final List<StoryModel> stories;

  /// Índice en [stories] desde el que se empieza a visualizar.
  final int startIndex;

  final String currentUid;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.startIndex,
    required this.currentUid,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _idx;
  late AnimationController _progressCtrl;

  StoryModel get _story => widget.stories[_idx];

  @override
  void initState() {
    super.initState();
    _idx = widget.startIndex.clamp(0, widget.stories.length - 1);
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener(_onStatus);
    _startCurrent();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) _advance();
  }

  void _startCurrent() {
    _progressCtrl.reset();
    // Marca como vista en el momento en que el usuario la ve
    if (!_story.isViewedBy(widget.currentUid)) {
      StoriesService.instance.markAsViewed(_story.id, widget.currentUid);
    }
    _progressCtrl.forward();
  }

  void _advance() {
    if (_idx < widget.stories.length - 1) {
      setState(() => _idx++);
      _startCurrent();
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _goBack() {
    if (_idx > 0) {
      setState(() => _idx--);
      _startCurrent();
    } else {
      // Ya en la primera: reinicia la barra
      _progressCtrl.reset();
      _progressCtrl.forward();
    }
  }

  void _pause() => _progressCtrl.stop();

  void _resume() {
    if (!_progressCtrl.isAnimating) _progressCtrl.forward();
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Ahora';
    if (d.inMinutes < 60) return 'Hace ${d.inMinutes}min';
    if (d.inHours < 24) return 'Hace ${d.inHours}h';
    return 'Hace ${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final story = _story;

    return GestureDetector(
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! > 200) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Imagen de la historia ──────────────────────────────────────
              story.imageBase64.isNotEmpty
                  ? Image.memory(
                      base64Decode(story.imageBase64),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      gaplessPlayback: true,
                    )
                  : Container(color: Colors.black54),

              // ── Zonas de tap + long press ──────────────────────────────────
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _goBack,
                        onLongPressStart: (_) => _pause(),
                        onLongPressEnd: (_) => _resume(),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _advance,
                        onLongPressStart: (_) => _pause(),
                        onLongPressEnd: (_) => _resume(),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Indicadores de segmento ────────────────────────────────────
              Positioned(
                top: 8, left: 12, right: 52,
                child: Row(
                  children: List.generate(widget.stories.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: i < _idx
                              ? _segmentFull()
                              : i == _idx
                                  ? AnimatedBuilder(
                                      animation: _progressCtrl,
                                      builder: (_, _) =>
                                          _segmentAnimated(_progressCtrl.value),
                                    )
                                  : _segmentEmpty(),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // ── Información del usuario ────────────────────────────────────
              Positioned(
                top: 22, left: 12, right: 56,
                child: Row(children: [
                  AvatarWithFrame(
                    base64: story.avatarBase64,
                    frameStyle: story.frameStyle ?? 'none',
                    radius: 20,
                    initials: story.username.isNotEmpty
                        ? story.username[0].toUpperCase()
                        : '?',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          story.username,
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              shadows: [const Shadow(blurRadius: 4)]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _timeAgo(story.createdAt),
                          style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontSize: 11,
                              shadows: [const Shadow(blurRadius: 4)]),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),

              // ── Botón cerrar ───────────────────────────────────────────────
              Positioned(
                top: 18, right: 4,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers de segmentos ─────────────────────────────────────────────────────
  Widget _segmentFull() => LinearProgressIndicator(
        value: 1.0,
        backgroundColor: Colors.white38,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 3,
      );

  Widget _segmentEmpty() => LinearProgressIndicator(
        value: 0.0,
        backgroundColor: Colors.white38,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 3,
      );

  Widget _segmentAnimated(double value) => LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.white38,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 3,
      );
}
