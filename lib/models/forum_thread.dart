import 'package:cloud_firestore/cloud_firestore.dart';

class ForumThread {
  final String id;
  final String userId;
  final String username;
  final String avatarBase64;
  final String title;
  final String category;
  final String content;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;

  const ForumThread({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarBase64 = '',
    required this.title,
    required this.category,
    required this.content,
    this.likes = 0,
    this.likedBy = const [],
    required this.createdAt,
  });

  bool isLikedBy(String uid) => likedBy.contains(uid);

  factory ForumThread.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumThread(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarBase64: data['avatarBase64'] as String? ?? '',
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? '',
      content: data['content'] as String? ?? '',
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'username': username,
        'avatarBase64': avatarBase64,
        'title': title,
        'category': category,
        'content': content,
        'likes': likes,
        'likedBy': likedBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  ForumThread copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarBase64,
    String? title,
    String? category,
    String? content,
    int? likes,
    List<String>? likedBy,
    DateTime? createdAt,
  }) =>
      ForumThread(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        avatarBase64: avatarBase64 ?? this.avatarBase64,
        title: title ?? this.title,
        category: category ?? this.category,
        content: content ?? this.content,
        likes: likes ?? this.likes,
        likedBy: likedBy ?? this.likedBy,
        createdAt: createdAt ?? this.createdAt,
      );
}
