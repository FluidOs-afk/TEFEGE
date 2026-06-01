import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../providers/auth_provider.dart';
import '../services/messages_service.dart';
import '../widgets/avatar_with_frame.dart';
import 'chat_screen.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final d = DateTime.now().difference(ts.toDate());
    if (d.inMinutes < 1) return 'Ahora';
    if (d.inMinutes < 60) return '${d.inMinutes}min';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Mensajes', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: MessagesService.instance.streamConversations(currentUid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.mail_outline_rounded, size: 56, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No tienes mensajes',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Busca un usuario para empezar a chatear',
                      style: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 13),
                      textAlign: TextAlign.center),
                ]),
              ),
            );
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, i) => const Divider(height: 1, indent: 72, color: AppColors.border),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final convId = docs[i].id;
              final participants = List<String>.from(data['participants'] as List? ?? []);
              final otherUid = participants.firstWhere((u) => u != currentUid, orElse: () => '');
              final lastMessage = data['lastMessage'] as String? ?? '';
              final lastTime = data['lastMessageTime'] as Timestamp?;
              final unread = data['unreadCount_$currentUid'] as int? ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
                builder: (context, userSnap) {
                  final userData = userSnap.data?.data() as Map<String, dynamic>?;
                  final name = userData?['nombre'] as String? ?? otherUid;
                  final username = userData?['username'] as String? ?? '';
                  final avatarBase64 = userData?['avatarBase64'] as String?;
                  final frameStyle = userData?['frameStyle'] as String? ?? 'none';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        convId: convId,
                        otherUid: otherUid,
                        otherName: name,
                        otherUsername: username,
                        otherAvatarBase64: avatarBase64,
                        otherFrameStyle: frameStyle,
                      ),
                    )),
                    leading: AvatarWithFrame(
                      base64: avatarBase64,
                      frameStyle: frameStyle,
                      radius: 26,
                      initials: name.isNotEmpty ? name[0].toUpperCase() : '?',
                    ),
                    title: Text(name,
                        style: GoogleFonts.dmSans(
                          fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 14, color: AppColors.textPrimary,
                        )),
                    subtitle: Text(
                      lastMessage.isEmpty ? 'Sin mensajes aún' : lastMessage,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: unread > 0 ? AppColors.textPrimary : AppColors.textHint,
                        fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_timeAgo(lastTime),
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
                        if (unread > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: Text('$unread',
                                style: GoogleFonts.dmSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
