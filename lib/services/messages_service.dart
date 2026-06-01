import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'notifications_service.dart';

class MessagesService {
  static final MessagesService instance = MessagesService._();
  MessagesService._();

  final _db = FirebaseFirestore.instance;

  // conversationId = uids ordenados alfabéticamente unidos con '_'
  static String conversationId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  Future<String> getOrCreateConversation(String uid1, String uid2) async {
    final ids = [uid1, uid2]..sort();
    final convId = ids.join('_');
    final ref = _db.collection('conversations').doc(convId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participants': ids,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': '',
        'unreadCount_${ids[0]}': 0,
        'unreadCount_${ids[1]}': 0,
      });
    }
    return convId;
  }

  Stream<QuerySnapshot> streamConversations(String uid) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamMessages(String convId) {
    return _db
        .collection('conversations')
        .doc(convId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(
      String convId, String senderId, String text, String otherUid) async {
    final batch = _db.batch();
    final msgRef = _db
        .collection('conversations')
        .doc(convId)
        .collection('messages')
        .doc();
    batch.set(msgRef, {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
    batch.update(_db.collection('conversations').doc(convId), {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
      'unreadCount_$otherUid': FieldValue.increment(1),
    });
    await batch.commit();

    // Notificación in-app al destinatario
    final senderDoc = await _db.collection('users').doc(senderId).get();
    final sender = UserModel.fromFirestore(senderDoc);
    NotificationsService.instance.createNotification(
      toUid: otherUid,
      fromUid: senderId,
      fromUsername: sender.username,
      fromAvatarBase64: sender.avatarBase64,
      type: 'message',
      text: text,
    );
  }

  Future<void> markAsRead(String convId, String uid) async {
    await _db
        .collection('conversations')
        .doc(convId)
        .update({'unreadCount_$uid': 0});
  }

  // Total de mensajes no leídos en todas las conversaciones del usuario
  Stream<int> streamTotalUnread(String uid) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        total += (data['unreadCount_$uid'] as int? ?? 0);
      }
      return total;
    });
  }
}
