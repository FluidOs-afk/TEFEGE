import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userAvatarBase64;
  final String title;
  final String description;
  final List<String> tags;
  final String category;
  final String imageBase64;
  final List<String> wardrobeItems;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatarBase64 = '',
    required this.title,
    this.description = '',
    this.tags = const [],
    this.category = '',
    this.imageBase64 = '',
    this.wardrobeItems = const [],
    this.likes = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    required this.createdAt,
  });

  bool isLikedBy(String uid) => likedBy.contains(uid);

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      userAvatarBase64: data['userAvatarBase64'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List? ?? []),
      category: data['category'] as String? ?? '',
      imageBase64: data['imageBase64'] as String? ?? '',
      wardrobeItems: List<String>.from(data['wardrobeItems'] as List? ?? []),
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'username': username,
        'userAvatarBase64': userAvatarBase64,
        'title': title,
        'description': description,
        'tags': tags,
        'category': category,
        'imageBase64': imageBase64,
        'wardrobeItems': wardrobeItems,
        'likes': likes,
        'likedBy': likedBy,
        'commentCount': commentCount,
        'createdAt': FieldValue.serverTimestamp(),
      };

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarBase64,
    String? title,
    String? description,
    List<String>? tags,
    String? category,
    String? imageBase64,
    List<String>? wardrobeItems,
    int? likes,
    List<String>? likedBy,
    int? commentCount,
    DateTime? createdAt,
  }) =>
      PostModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        userAvatarBase64: userAvatarBase64 ?? this.userAvatarBase64,
        title: title ?? this.title,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        category: category ?? this.category,
        imageBase64: imageBase64 ?? this.imageBase64,
        wardrobeItems: wardrobeItems ?? this.wardrobeItems,
        likes: likes ?? this.likes,
        likedBy: likedBy ?? this.likedBy,
        commentCount: commentCount ?? this.commentCount,
        createdAt: createdAt ?? this.createdAt,
      );
}
