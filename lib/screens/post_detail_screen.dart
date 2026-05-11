import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../models/user_post.dart';
import '../services/posts_service.dart';
import '../widgets/fashion_icon.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final VoidCallback? onDeleted;
  const PostDetailScreen({super.key, required this.postId, this.onDeleted});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartAnim;
  final _commentCtrl = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _heartAnim = Tween<double>(begin: 1.0, end: 1.5)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_heartCtrl);
    PostsService.instance.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    PostsService.instance.removeListener(_onChanged);
    _heartCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  UserPost? get _post {
    try {
      return PostsService.instance.posts
          .firstWhere((p) => p.id == widget.postId);
    } catch (_) {
      return null;
    }
  }

  void _handleLike() {
    PostsService.instance.toggleLike(widget.postId);
    _heartCtrl.forward(from: 0);
  }

  void _sendComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    PostsService.instance.addComment(
      widget.postId,
      PostComment(user: 'sergio.outfy', text: text, timeAgo: 'Ahora'),
    );
    _commentCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  void _confirmDelete(UserPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar publicación',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text(
            '¿Eliminar "${post.title}"? Esta acción no se puede deshacer.',
            style: GoogleFonts.dmSans(color: AppColors.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar',
                  style: GoogleFonts.dmSans(color: AppColors.textSec))),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              PostsService.instance.remove(post.id);
              widget.onDeleted?.call();
              Navigator.of(context).pop();
            },
            child: Text('Eliminar',
                style: GoogleFonts.dmSans(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    if (post == null) {
      return const Scaffold(
        body: Center(child: Text('Publicación eliminada')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        title: Text(post.title,
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showOptions(post),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Foto ──────────────────────────────────────────────
                  _buildPhoto(post),

                  // ── Acciones ──────────────────────────────────────────
                  _buildActions(post),

                  // ── Likes ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                    child: Text('${_fmt(post.likes)} me gusta',
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary)),
                  ),

                  // ── Descripción ───────────────────────────────────────
                  if (post.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'sergio.outfy  ',
                              style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary)),
                          TextSpan(
                              text: post.description,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppColors.textSec,
                                  height: 1.45)),
                        ]),
                      ),
                    ),

                  // ── Tags ──────────────────────────────────────────────
                  if (post.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        children: post.tags
                            .map((t) => Text('#$t',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)))
                            .toList(),
                      ),
                    ),

                  // ── Prendas del armario ───────────────────────────────
                  if (post.wardrobeItems.isNotEmpty) _buildWardrobeRow(post),

                  // ── Comentarios ───────────────────────────────────────
                  _buildComments(post),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Input comentario ─────────────────────────────────────────
          _buildCommentInput(),
        ],
      ),
    );
  }

  // ── Photo area ─────────────────────────────────────────────────────────────
  Widget _buildPhoto(UserPost post) {
    final hasRealPhoto = post.imagePath != null &&
        File(post.imagePath!).existsSync();

    return GestureDetector(
      onDoubleTap: _handleLike,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto real o gradiente de fondo
            if (hasRealPhoto)
              Image.file(
                File(post.imagePath!),
                fit: BoxFit.cover,
              )
            else ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: post.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                right: -24,
                bottom: -24,
                child: FashionIcon(
                  category: post.category,
                  color: Colors.white.withValues(alpha: 0.07),
                  size: 260,
                  strokeWidth: 3,
                ),
              ),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5),
                  ),
                  padding: const EdgeInsets.all(22),
                  child: FashionIcon(
                    category: post.category,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 66,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
            // Heart like animation
            Center(
              child: ScaleTransition(
                scale: _heartAnim,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _heartCtrl,
                    builder: (context, child) => _heartCtrl.value > 0
                        ? Icon(Icons.favorite_rounded,
                            color: Colors.white
                                .withValues(alpha: 1 - _heartCtrl.value),
                            size: 90)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action row ─────────────────────────────────────────────────────────────
  Widget _buildActions(UserPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          _iconBtn(
            post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            post.isLiked ? const Color(0xFFEF5350) : AppColors.textPrimary,
            _handleLike,
          ),
          _iconBtn(Icons.chat_bubble_outline_rounded, AppColors.textPrimary,
              () => FocusScope.of(context).requestFocus(FocusNode())),
          _iconBtn(Icons.near_me_outlined, AppColors.textPrimary, () {}),
          const Spacer(),
          _iconBtn(
            _saved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            _saved ? AppColors.primary : AppColors.textPrimary,
            () => setState(() => _saved = !_saved),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }

  // ── Wardrobe items row ─────────────────────────────────────────────────────
  Widget _buildWardrobeRow(UserPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          child: Row(
            children: [
              const Icon(Icons.checkroom_rounded,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 5),
              Text('Prendas de este look',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            itemCount: post.wardrobeItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _wardrobeChip(post.wardrobeItems[i]),
          ),
        ),
        const SizedBox(height: 10),
        const Divider(height: 1),
      ],
    );
  }

  Widget _wardrobeChip(PostWardrobeItem item) {
    return Container(
      width: 76,
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FashionIcon(
            category: item.category,
            color: AppColors.textSec,
            size: 26,
            strokeWidth: 1.8,
          ),
          const SizedBox(height: 5),
          Text(item.name,
              style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
          Text(item.brand,
              style: GoogleFonts.dmSans(
                  fontSize: 8, color: AppColors.textHint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ── Comments ───────────────────────────────────────────────────────────────
  Widget _buildComments(UserPost post) {
    if (post.comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: Text('Sin comentarios. Sé el primero.',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppColors.textHint)),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: post.comments
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentBg),
                        child: Center(
                          child: Text(c.user[0].toUpperCase(),
                              style: GoogleFonts.dmSans(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '${c.user}  ',
                                    style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.textPrimary)),
                                TextSpan(
                                    text: c.text,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: AppColors.textSec,
                                        height: 1.4)),
                              ]),
                            ),
                            const SizedBox(height: 2),
                            Text(c.timeAgo,
                                style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: AppColors.textHint)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Comment input ──────────────────────────────────────────────────────────
  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
          left: 14,
          right: 14,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight])),
            child: Center(
              child: Text('S',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              style: GoogleFonts.dmSans(fontSize: 13),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Añade un comentario...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
              ),
              onSubmitted: (_) => _sendComment(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ── Options sheet ──────────────────────────────────────────────────────────
  void _showOptions(UserPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 18),
                ),
                title: Text('Eliminar publicación',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600, color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(post);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
