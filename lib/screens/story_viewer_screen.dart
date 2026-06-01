import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/story_model.dart';
import '../services/stories_service.dart';
import '../widgets/avatar_with_frame.dart';

class StoryViewerScreen extends StatefulWidget {
  final StoryModel story;
  final String currentUid;

  const StoryViewerScreen({super.key, required this.story, required this.currentUid});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  Timer? _timer;
  double _progress = 0;
  static const _duration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0;
    const steps = 100;
    _timer = Timer.periodic(
      Duration(milliseconds: _duration.inMilliseconds ~/ steps),
      (t) {
        if (!mounted) return;
        setState(() => _progress = (_progress + 1 / steps).clamp(0.0, 1.0));
        if (_progress >= 1.0) _finish();
      },
    );
  }

  Future<void> _finish() async {
    _timer?.cancel();
    await StoriesService.instance.markAsViewed(widget.story.id, widget.currentUid);
    if (mounted) Navigator.of(context).pop();
  }

  String _timeAgo() {
    final d = DateTime.now().difference(widget.story.createdAt);
    if (d.inMinutes < 1) return 'Ahora';
    if (d.inMinutes < 60) return 'Hace ${d.inMinutes}min';
    if (d.inHours < 24) return 'Hace ${d.inHours}h';
    return 'Hace ${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de la historia
              widget.story.imageBase64.isNotEmpty
                  ? Image.memory(
                      base64Decode(widget.story.imageBase64),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(color: Colors.black12),

              // Barra de progreso
              Positioned(
                top: 8, left: 12, right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3,
                  ),
                ),
              ),

              // Avatar, nombre y tiempo
              Positioned(
                top: 20, left: 12, right: 48,
                child: Row(children: [
                  AvatarWithFrame(
                    base64: widget.story.avatarBase64,
                    frameStyle: widget.story.frameStyle ?? 'none',
                    radius: 20,
                    initials: widget.story.username.isNotEmpty
                        ? widget.story.username[0].toUpperCase()
                        : '?',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.story.username,
                          style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(_timeAgo(),
                          style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
                    ]),
                  ),
                ]),
              ),

              // Botón cerrar
              Positioned(
                top: 18, right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
