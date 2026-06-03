import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../models/forum_thread.dart';
import '../models/forum_reply.dart';
import '../providers/auth_provider.dart';
import '../services/forum_service.dart';
import '../utils/content_filter.dart';
import '../utils/image_utils.dart';

const _kCategories = ['Todos','Tendencias','Sostenibilidad','Compras','Estilo','OOTD'];

class _CatMeta {
  final IconData icon;
  final Color color;
  const _CatMeta(this.icon, this.color);
}

const _catMeta = {
  'Tendencias': _CatMeta(Icons.trending_up_rounded, Color(0xFFD84315)),
  'Sostenibilidad': _CatMeta(Icons.eco_outlined, Color(0xFF2E7D32)),
  'Compras': _CatMeta(Icons.shopping_bag_outlined, Color(0xFF6A1B9A)),
  'Estilo': _CatMeta(Icons.style_outlined, AppColors.primary),
  'OOTD': _CatMeta(Icons.photo_camera_outlined, Color(0xFF00838F)),
  'Todos': _CatMeta(Icons.apps_rounded, AppColors.primary),
};

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});
  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  String _selectedCat = 'Todos';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.currentUser?.uid ?? '';
    final currentUsername = auth.currentUser?.username ?? '';
    final currentAvatarBase64 = auth.currentUser?.avatarBase64 ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Foro', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openComposer(context,
            currentUid: currentUid, currentUsername: currentUsername, currentAvatarBase64: currentAvatarBase64),
        icon: const Icon(Icons.edit_outlined),
        label: Text('Nuevo hilo', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        Container(
          color: AppColors.bgCard, height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: _kCategories.length,
            itemBuilder: (_, i) {
              final cat = _kCategories[i];
              final meta = _catMeta[cat]!;
              final sel = _selectedCat == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCat = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel ? meta.color : AppColors.bgPage,
                    borderRadius: BorderRadius.circular(20),
                    border: sel ? null : Border.all(color: AppColors.border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(meta.icon, size: 13, color: sel ? Colors.white : AppColors.textHint),
                    const SizedBox(width: 5),
                    Text(cat, style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: sel ? Colors.white : AppColors.textSec,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => setState(() => _selectedCat = _selectedCat),
            child: StreamBuilder<List<ForumThread>>(
              stream: ForumService.instance.streamThreads(category: _selectedCat),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final threads = snap.data ?? [];
                if (threads.isEmpty) {
                  return _EmptyForumState(text: _selectedCat == 'Todos'
                      ? 'Aún no hay hilos. ¡Sé el primero!'
                      : 'Aún no hay hilos en "$_selectedCat"');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: threads.length,
                  itemBuilder: (_, i) => _ThreadCard(
                    thread: threads[i],
                    currentUid: currentUid,
                    onTap: () => _openThread(context,
                        thread: threads[i], currentUid: currentUid,
                        currentUsername: currentUsername, currentAvatarBase64: currentAvatarBase64),
                    onLike: () => ForumService.instance.toggleLike(threads[i].id, currentUid),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }

  void _openThread(BuildContext context, {
    required ForumThread thread, required String currentUid,
    required String currentUsername, required String currentAvatarBase64,
  }) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ThreadDetailScreen(
        thread: thread, currentUid: currentUid,
        currentUsername: currentUsername, currentAvatarBase64: currentAvatarBase64,
      ),
    ));
  }

  void _openComposer(BuildContext context, {
    required String currentUid, required String currentUsername, required String currentAvatarBase64,
    String? preselectedCat,
  }) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ThreadComposer(
        currentUid: currentUid, currentUsername: currentUsername,
        currentAvatarBase64: currentAvatarBase64,
        preselectedCat: preselectedCat ?? _selectedCat,
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final ForumThread thread;
  final String currentUid;
  final VoidCallback onTap;
  final VoidCallback onLike;
  const _ThreadCard({required this.thread, required this.currentUid, required this.onTap, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final meta = _catMeta[thread.category] ?? _catMeta['Todos']!;
    final isLiked = thread.isLikedBy(currentUid);
    return _ForumPanel(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _CatPill(category: thread.category, meta: meta),
          const Spacer(),
          Text(_relativeTime(thread.createdAt),
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
        ]),
        const SizedBox(height: 9),
        Text(thread.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary, height: 1.25)),
        const SizedBox(height: 6),
        Text(thread.content, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSec, height: 1.35)),
        const SizedBox(height: 10),
        Row(children: [
          _AuthorRow(avatarBase64: thread.avatarBase64, username: thread.username),
          const Spacer(),
          GestureDetector(
            onTap: onLike,
            child: Row(children: [
              Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 16, color: isLiked ? AppColors.primary : AppColors.textHint),
              const SizedBox(width: 3),
              Text('${thread.likes}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.mode_comment_outlined, size: 14, color: AppColors.textHint),
          const SizedBox(width: 3),
          _ReplyCount(threadId: thread.id),
        ]),
      ]),
    );
  }
}

class _ReplyCount extends StatelessWidget {
  final String threadId;
  const _ReplyCount({required this.threadId});
  @override
  Widget build(BuildContext context) => StreamBuilder<List<ForumReply>>(
    stream: ForumService.instance.streamReplies(threadId),
    builder: (_, snap) => Text('${snap.data?.length ?? 0}',
        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.w700)),
  );
}

class _ThreadDetailScreen extends StatefulWidget {
  final ForumThread thread;
  final String currentUid, currentUsername, currentAvatarBase64;
  const _ThreadDetailScreen({required this.thread, required this.currentUid,
      required this.currentUsername, required this.currentAvatarBase64});
  @override
  State<_ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<_ThreadDetailScreen> {
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() { _replyCtrl.dispose(); super.dispose(); }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    if (ContentFilter.containsProfanity(text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tu respuesta contiene lenguaje inapropiado.', style: GoogleFonts.dmSans()),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    setState(() => _sending = true);
    _replyCtrl.clear();
    FocusScope.of(context).unfocus();
    await ForumService.instance.addReply(
      widget.thread.id,
      ForumReply(id: '', userId: widget.currentUid, username: widget.currentUsername,
          avatarBase64: widget.currentAvatarBase64, content: text, createdAt: DateTime.now()),
    );
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _deleteThread() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar hilo', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar "${widget.thread.title}"? Esta acción no se puede deshacer.',
            style: GoogleFonts.dmSans(color: AppColors.textSec)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancelar', style: GoogleFonts.dmSans(color: AppColors.textSec))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Eliminar', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ForumService.instance.deleteThread(widget.thread.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;
    final meta = _catMeta[thread.category] ?? _catMeta['Todos']!;
    final isOwn = thread.userId == widget.currentUid;
    final isLiked = thread.isLikedBy(widget.currentUid);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(thread.title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        actions: [
          if (isOwn)
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: _deleteThread),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<ForumReply>>(
            stream: ForumService.instance.streamReplies(thread.id),
            builder: (context, snap) {
              final replies = snap.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  _ForumPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      _CatPill(category: thread.category, meta: meta),
                      const Spacer(),
                      Text(_relativeTime(thread.createdAt),
                          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
                    ]),
                    const SizedBox(height: 12),
                    Text(thread.title,
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary, height: 1.15)),
                    const SizedBox(height: 10),
                    Text(thread.content,
                        style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary, height: 1.45)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _AuthorRow(avatarBase64: thread.avatarBase64, username: thread.username),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => ForumService.instance.toggleLike(thread.id, widget.currentUid),
                        child: Row(children: [
                          Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18, color: isLiked ? AppColors.primary : AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('${thread.likes}',
                              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ]),
                  ])),
                  if (snap.connectionState == ConnectionState.waiting)
                    const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: AppColors.primary)))
                  else if (replies.isEmpty)
                    const _EmptyForumState(text: 'Sé el primero en responder')
                  else
                    ...replies.map((r) => _ReplyBubble(
                          reply: r, currentUid: widget.currentUid,
                          onDelete: r.userId == widget.currentUid
                              ? () => ForumService.instance.deleteReply(thread.id, r.id)
                              : null,
                        )),
                ],
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 12, right: 12, top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12),
          decoration: const BoxDecoration(color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.border))),
          child: SafeArea(top: false,
            child: Row(children: [
              Expanded(child: TextField(
                controller: _replyCtrl, maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendReply(),
                decoration: const InputDecoration(hintText: 'Escribe una respuesta...', isDense: true),
              )),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sending ? null : _sendReply,
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                icon: _sending
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final ForumReply reply;
  final String currentUid;
  final VoidCallback? onDelete;
  const _ReplyBubble({required this.reply, required this.currentUid, this.onDelete});

  @override
  Widget build(BuildContext context) => _ForumPanel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _AuthorRow(avatarBase64: reply.avatarBase64, username: reply.username),
        const Spacer(),
        Text(_relativeTime(reply.createdAt),
            style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textHint)),
        if (onDelete != null) ...[
          const SizedBox(width: 4),
          GestureDetector(onTap: onDelete,
              child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red)),
        ],
      ]),
      const SizedBox(height: 8),
      Text(reply.content, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
    ]),
  );
}

class _ThreadComposer extends StatefulWidget {
  final String currentUid, currentUsername, currentAvatarBase64, preselectedCat;
  const _ThreadComposer({required this.currentUid, required this.currentUsername,
      required this.currentAvatarBase64, required this.preselectedCat});
  @override
  State<_ThreadComposer> createState() => _ThreadComposerState();
}

class _ThreadComposerState extends State<_ThreadComposer> {
  late final TextEditingController _titleCtrl = TextEditingController();
  late final TextEditingController _contentCtrl = TextEditingController();
  late String _selectedCat;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _selectedCat = widget.preselectedCat == 'Todos' ? 'Tendencias' : widget.preselectedCat;
  }

  @override
  void dispose() { _titleCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.length < 5) { _snack('El título necesita al menos 5 caracteres'); return; }
    if (content.length < 10) { _snack('El contenido necesita al menos 10 caracteres'); return; }
    if (ContentFilter.containsProfanity(title) || ContentFilter.containsProfanity(content)) {
      _snack('El hilo contiene lenguaje inapropiado.');
      return;
    }
    setState(() => _publishing = true);
    try {
      await ForumService.instance.createThread(ForumThread(
        id: '', userId: widget.currentUid, username: widget.currentUsername,
        avatarBase64: widget.currentAvatarBase64,
        title: title, category: _selectedCat, content: content, createdAt: DateTime.now(),
      ));
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hilo publicado', style: GoogleFonts.dmSans())));
      }
    } catch (_) {
      if (mounted) _snack('Error al publicar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.dmSans())));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      child: SafeArea(top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 18),
              Text('Nuevo hilo', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              Text('Categoría', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSec)),
              const SizedBox(height: 8),
              SizedBox(height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kCategories.where((c) => c != 'Todos').length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cats = _kCategories.where((c) => c != 'Todos').toList();
                    final cat = cats[i];
                    final meta = _catMeta[cat]!;
                    final sel = _selectedCat == cat;
                    return ChoiceChip(
                      selected: sel,
                      avatar: Icon(meta.icon, size: 15, color: sel ? Colors.white : meta.color),
                      label: Text(cat),
                      onSelected: (_) => setState(() => _selectedCat = cat),
                      selectedColor: meta.color,
                      labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : meta.color),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              TextField(controller: _titleCtrl, maxLength: 90,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Título', hintText: 'Resume la conversación en una frase', counterText: '')),
              const SizedBox(height: 12),
              TextField(controller: _contentCtrl, minLines: 4, maxLines: 8, maxLength: 800,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Contenido', hintText: 'Explica el contexto, pregunta o idea...', alignLabelWithHint: true)),
              const SizedBox(height: 12),
              _GuidelinesBox(),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _publishing ? null : _submit,
                  icon: _publishing
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded),
                  label: const Text('Publicar hilo'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────
class _AuthorRow extends StatelessWidget {
  final String avatarBase64, username;
  const _AuthorRow({required this.avatarBase64, required this.username});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    ClipOval(child: SizedBox(width: 22, height: 22,
        child: avatarBase64.isNotEmpty
            ? ImageUtils.imageFromBase64(avatarBase64, placeholder: _fallback())
            : _fallback())),
    const SizedBox(width: 6),
    Text('@$username', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSec, fontWeight: FontWeight.w700)),
  ]);

  Widget _fallback() => Container(
    width: 22, height: 22,
    decoration: const BoxDecoration(shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])),
    child: Center(child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9))),
  );
}

class _CatPill extends StatelessWidget {
  final String category;
  final _CatMeta meta;
  const _CatPill({required this.category, required this.meta});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(category, style: GoogleFonts.dmSans(fontSize: 10, color: meta.color, fontWeight: FontWeight.w800)),
  );
}

class _ForumPanel extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _ForumPanel({required this.child, this.onTap});
  @override
  Widget build(BuildContext context) {
    final panel = Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)), child: child);
    if (onTap == null) return panel;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: panel);
  }
}

class _EmptyForumState extends StatelessWidget {
  final String text;
  const _EmptyForumState({required this.text});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.forum_outlined, size: 44, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSec, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _GuidelinesBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(child: Text('Publica contenido propio, evita datos personales y mantén un tono respetuoso.',
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSec, height: 1.35))),
    ]),
  );
}

String _relativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';
  if (diff.inDays < 7) return '${diff.inDays} d';
  return '${date.day}/${date.month}/${date.year}';
}
