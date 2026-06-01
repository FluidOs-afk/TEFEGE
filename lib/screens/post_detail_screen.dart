import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../widgets/share_sheet.dart';
import '../models/post_model.dart';
import '../models/user_post.dart';
import '../providers/auth_provider.dart';
import '../services/posts_service.dart';
import '../utils/image_utils.dart';
import 'profile_screen.dart';

String _timeAgo(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return 'Ahora';
  if (d.inMinutes < 60) return 'Hace ${d.inMinutes}min';
  if (d.inHours < 24) return 'Hace ${d.inHours}h';
  if (d.inDays < 7) return 'Hace ${d.inDays}d';
  return 'Hace ${(d.inDays / 7).floor()}sem';
}

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

// ─── IMPORTANTE: No usar StreamBuilder que envuelva el Scaffold completo.
// Cada vez que Firestore emite (like, comentario), un StreamBuilder externo crea
// un Scaffold nuevo desde cero → flash blanco.
// Solución: StreamSubscription en initState + estado local _post.
// El Scaffold es estable; solo se reconstruyen los widgets internos que cambian.
class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartAnim;
  final _commentCtrl = TextEditingController();
  bool _likeLoading = false;
  bool _sendingComment = false;

  // Estado local del post — actualizado por la suscripción
  PostModel? _post;
  bool _notFound = false;
  StreamSubscription<DocumentSnapshot>? _postSub;

  // Stream de comentarios — separado para no afectar al Scaffold
  Stream<List<CommentModel>>? _commentsStream;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _heartAnim = Tween<double>(begin: 1.0, end: 1.5)
        .chain(CurveTween(curve: Curves.elasticOut)).animate(_heartCtrl);

    // Suscripción estable: solo actualiza _post en estado local
    _postSub = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .snapshots()
        .listen((doc) {
      if (!mounted) return;
      setState(() {
        if (!doc.exists) {
          _notFound = true;
          _post = null;
        } else {
          _post = PostModel.fromFirestore(doc);
          // Crear el stream de comentarios solo una vez
          _commentsStream ??= PostsService.instance.streamComments(widget.postId);
        }
      });
    });
  }

  @override
  void dispose() {
    _postSub?.cancel();
    _heartCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLike(String currentUid) async {
    if (_likeLoading || _post == null) return;
    setState(() => _likeLoading = true);
    _heartCtrl.forward(from: 0);
    await PostsService.instance.toggleLike(_post!.id, currentUid);
    if (mounted) setState(() => _likeLoading = false);
  }

  Future<void> _sendComment(String currentUid, String username, String avatarBase64) async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _sendingComment || _post == null) return;
    setState(() => _sendingComment = true);
    _commentCtrl.clear();
    FocusScope.of(context).unfocus();
    await PostsService.instance.addComment(
      _post!.id,
      CommentModel(
        id: '', userId: currentUid, username: username,
        avatarBase64: avatarBase64, text: text, createdAt: DateTime.now(),
      ),
    );
    if (mounted) setState(() => _sendingComment = false);
  }

  @override
  Widget build(BuildContext context) {
    // Loading inicial (solo hasta que llega el primer snapshot)
    if (_post == null && !_notFound) {
      return Scaffold(
        backgroundColor: AppColors.bgCard,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_notFound || _post == null) {
      return Scaffold(
        backgroundColor: AppColors.bgCard,
        appBar: AppBar(),
        body: const Center(child: Text('Publicación no encontrada')),
      );
    }

    final post = _post!;
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.currentUser?.uid ?? '';
    final username = auth.currentUser?.username ?? '';
    final avatarBase64 = auth.currentUser?.avatarBase64 ?? '';
    final isLiked = post.isLikedBy(currentUid);

    // ─── Este Scaffold se construye UNA sola vez y persiste.
    // Las actualizaciones de _post solo reconstruyen los widgets internos afectados.
    return Scaffold(
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        title: Text(post.title,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.near_me_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => ShareSheet(postId: post.id, postTitle: post.title),
            ),
          ),
          if (post.userId == currentUid)
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _showOptions(context, post),
            ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del post
                GestureDetector(
                  onDoubleTap: () => _handleLike(currentUid),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(fit: StackFit.expand, children: [
                      post.imageBase64.isNotEmpty
                          ? ImageUtils.imageFromBase64(post.imageBase64)
                          : Container(color: AppColors.accentBg,
                              child: const Icon(Icons.checkroom_outlined, size: 64, color: AppColors.primaryMed)),
                      Center(
                        child: ScaleTransition(
                          scale: _heartAnim,
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _heartCtrl,
                              builder: (_, _) => _heartCtrl.value > 0
                                  ? Icon(Icons.favorite_rounded,
                                      color: Colors.white.withValues(alpha: 1 - _heartCtrl.value), size: 90)
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                // Autor
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProfileScreen(userId: post.userId))),
                    child: Row(children: [
                      _AvatarSmall(base64: post.userAvatarBase64, name: post.username),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(post.username,
                            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                        Text(_timeAgo(post.createdAt),
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
                      ]),
                    ]),
                  ),
                ),

                // Acciones like / comentario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => _handleLike(currentUid),
                      icon: Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? const Color(0xFFEF5350) : AppColors.textPrimary, size: 26),
                    ),
                    IconButton(
                      onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 26, color: AppColors.textPrimary),
                    ),
                  ]),
                ),

                // Info del post
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${post.likes} me gusta',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                    if (post.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      RichText(text: TextSpan(children: [
                        TextSpan(text: '${post.username}  ',
                            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                        TextSpan(text: post.description,
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSec, height: 1.45)),
                      ])),
                    ],
                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(spacing: 6, children: post.tags.map((t) => Text('#$t',
                          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))).toList()),
                    ],
                  ]),
                ),

                const Divider(height: 1),

                // Comentarios — su propio StreamBuilder, no afecta al Scaffold
                StreamBuilder<List<CommentModel>>(
                  stream: _commentsStream,
                  builder: (context, cSnap) {
                    final comments = cSnap.data ?? [];
                    if (comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                        child: Text('Sin comentarios. Sé el primero.',
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint)),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                      child: Column(children: comments.map((c) => _CommentRow(comment: c)).toList()),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Input de comentario
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(children: [
              _AvatarSmall(base64: avatarBase64, name: username),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  style: GoogleFonts.dmSans(fontSize: 13),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Añade un comentario...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                  onSubmitted: (_) => _sendComment(currentUid, username, avatarBase64),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendComment(currentUid, username, avatarBase64),
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: _sendingComment
                      ? const Padding(padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void _showOptions(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 6),
          ListTile(
            leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18)),
            title: Text('Eliminar publicación',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, post);
            },
          ),
          const SizedBox(height: 8),
        ])),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar publicación', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar "${post.title}"? Esta acción no se puede deshacer.',
            style: GoogleFonts.dmSans(color: AppColors.textSec)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar', style: GoogleFonts.dmSans(color: AppColors.textSec))),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              PostsService.instance.deletePost(post.id);
              Navigator.of(context).pop();
            },
            child: Text('Eliminar', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final CommentModel comment;
  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _AvatarSmall(base64: comment.avatarBase64, name: comment.username),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(text: TextSpan(children: [
          TextSpan(text: '${comment.username}  ',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
          TextSpan(text: comment.text,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSec, height: 1.4)),
        ])),
        const SizedBox(height: 2),
        Text(_timeAgo(comment.createdAt),
            style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textHint)),
      ])),
    ]),
  );
}

class _AvatarSmall extends StatelessWidget {
  final String base64;
  final String name;
  const _AvatarSmall({required this.base64, required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 34, height: 34,
        child: base64.isNotEmpty
            ? ImageUtils.imageFromBase64(base64, placeholder: _fallback())
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
    width: 34, height: 34,
    decoration: const BoxDecoration(shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])),
    child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
  );
}
