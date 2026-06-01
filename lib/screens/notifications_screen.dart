import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors;
import '../providers/auth_provider.dart';
import '../services/messages_service.dart';
import '../services/notifications_service.dart';
import '../widgets/avatar_with_frame.dart';
import 'chat_screen.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      NotificationsService.instance.markAllAsRead(uid);
    }
  }

  Future<void> _handleTap(BuildContext context, Map<String, dynamic> data) async {
    final type = data['type'] as String? ?? '';
    final fromUid = data['fromUid'] as String? ?? '';

    switch (type) {
      case 'like':
      case 'comment':
        final postId = data['postId'] as String?;
        if (postId != null && postId.isNotEmpty) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PostDetailScreen(postId: postId)));
        }
      case 'follow':
      case 'follow_accept':
        if (fromUid.isNotEmpty) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProfileScreen(userId: fromUid)));
        }
      case 'message':
        final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';
        if (fromUid.isNotEmpty && currentUid.isNotEmpty) {
          final convId = await MessagesService.instance.getOrCreateConversation(currentUid, fromUid);
          final fromUsername = data['fromUsername'] as String? ?? '';
          final fromAvatar = data['fromAvatarBase64'] as String?;
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(
                convId: convId,
                otherUid: fromUid,
                otherName: fromUsername,
                otherUsername: fromUsername,
                otherAvatarBase64: fromAvatar,
              ),
            ));
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Notificaciones', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          TextButton(
            onPressed: () => NotificationsService.instance.markAllAsRead(uid),
            child: Text('Todo leído',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: uid.isNotEmpty
            ? NotificationsService.instance.streamNotifications(uid)
            : const Stream.empty(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text('No tienes notificaciones aún',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              ]),
            );
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, i) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final isRead = data['read'] as bool? ?? false;
              final text = NotificationsService.instance.getNotificationText(data);
              final avatarBase64 = data['fromAvatarBase64'] as String?;
              final ts = data['createdAt'] as Timestamp?;
              final timeStr = _timeAgo(ts);

              return GestureDetector(
                onTap: () => _handleTap(context, data),
                child: Container(
                  color: isRead ? Colors.white : AppColors.accentBg,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AvatarWithFrame(
                      base64: avatarBase64 != null && avatarBase64.isNotEmpty ? avatarBase64 : null,
                      frameStyle: 'none',
                      radius: 22,
                      initials: (data['fromUsername'] as String? ?? '?').isNotEmpty
                          ? (data['fromUsername'] as String)[0].toUpperCase()
                          : '?',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(text,
                            style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppColors.textPrimary,
                              fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                              height: 1.4,
                            )),
                        if (timeStr.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(timeStr, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint)),
                        ],
                      ]),
                    ),
                    if (!isRead)
                      Container(
                        width: 8, height: 8, margin: const EdgeInsets.only(top: 4, left: 8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final d = DateTime.now().difference(ts.toDate());
    if (d.inMinutes < 1) return 'Ahora';
    if (d.inMinutes < 60) return 'Hace ${d.inMinutes}min';
    if (d.inHours < 24) return 'Hace ${d.inHours}h';
    if (d.inDays < 7) return 'Hace ${d.inDays}d';
    return 'Hace ${(d.inDays / 7).floor()}sem';
  }
}
