import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors, AppColorsExt;
import '../models/report_model.dart';
import '../providers/auth_provider.dart';
import '../services/messages_service.dart';
import '../utils/content_filter.dart';
import '../widgets/avatar_with_frame.dart';
import '../widgets/report_sheet.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String convId;
  final String otherUid;
  final String otherName;
  final String otherUsername;
  final String? otherAvatarBase64;
  final String otherFrameStyle;

  const ChatScreen({
    super.key,
    required this.convId,
    required this.otherUid,
    required this.otherName,
    required this.otherUsername,
    this.otherAvatarBase64,
    this.otherFrameStyle = 'none',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    MessagesService.instance.markAsRead(widget.convId, uid);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    if (ContentFilter.containsProfanity(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tu mensaje contiene lenguaje inapropiado. Modifícalo antes de enviarlo.',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';
    setState(() => _sending = true);
    _textCtrl.clear();
    try {
      await MessagesService.instance.sendMessage(
        widget.convId, currentUid, text, widget.otherUid,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el mensaje')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _timeLabel(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.otherUid))),
          child: Row(children: [
            AvatarWithFrame(
              base64: widget.otherAvatarBase64,
              frameStyle: widget.otherFrameStyle,
              radius: 18,
              initials: widget.otherName.isNotEmpty
                  ? widget.otherName[0].toUpperCase()
                  : '?',
            ),
            const SizedBox(width: 10),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.otherName,
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: context.colText)),
                  if (widget.otherUsername.isNotEmpty)
                    Text('@${widget.otherUsername}',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: context.colTextSec)),
                ]),
          ]),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: MessagesService.instance.streamMessages(widget.convId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text('Empieza la conversación',
                        style: GoogleFonts.dmSans(
                            color: context.colTextHint, fontSize: 13)),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUid;
                    final text = data['text'] as String? ?? '';
                    final ts = data['createdAt'] as Timestamp?;
                    return _MessageBubble(
                      key: ValueKey(doc.id),
                      messageId: doc.id,
                      text: text,
                      isMe: isMe,
                      time: _timeLabel(ts),
                      onReport: !isMe
                          ? () => showReportSheet(
                                context,
                                reporterId: currentUid,
                                targetId: doc.id,
                                targetType: ReportTargetType.message,
                                targetContent: text,
                              )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _textCtrl,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String messageId;
  final String text;
  final bool isMe;
  final String time;
  final VoidCallback? onReport;

  const _MessageBubble({
    super.key,
    required this.messageId,
    required this.text,
    required this.isMe,
    required this.time,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: onReport,
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : context.colBgCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMe
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    border: isMe ? null : Border.all(color: context.colBorder),
                  ),
                  child: Text(text,
                      style: GoogleFonts.dmSans(
                        color: isMe ? Colors.white : context.colText,
                        fontSize: 14,
                        height: 1.4,
                      )),
                ),
              ),
              if (time.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(time,
                      style: GoogleFonts.dmSans(
                          fontSize: 10, color: context.colTextHint)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colBgCard,
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Escribe un mensaje…',
              hintStyle: GoogleFonts.dmSans(color: context.colTextHint),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: context.colBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: context.colBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              fillColor: context.colBgPage,
              filled: true,
            ),
            onSubmitted: (_) => onSend(),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onSend,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: sending ? AppColors.primaryMed : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: sending
                ? const Center(
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
