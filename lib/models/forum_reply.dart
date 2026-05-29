import 'package:cloud_firestore/cloud_firestore.dart';

class ForumReply {
  final String id;
  final String userId;
  final String username;
  final String avatarBase64;
  final String content;
  final DateTime createdAt;

  const ForumReply({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarBase64 = '',
    required this.content,
    required this.createdAt,
  });

  factory ForumReply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumReply(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarBase64: data['avatarBase64'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'username': username,
        'avatarBase64': avatarBase64,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
