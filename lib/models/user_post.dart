import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String username;
  final String avatarBase64;
  final String text;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarBase64 = '',
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
  });

  bool isLikedBy(String uid) => likedBy.contains(uid);

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarBase64: data['avatarBase64'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'username': username,
        'avatarBase64': avatarBase64,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': likes,
        'likedBy': likedBy,
      };
}
