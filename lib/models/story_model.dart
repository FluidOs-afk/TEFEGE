import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String? avatarBase64;
  final String? frameStyle;
  final String imageBase64;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarBase64,
    this.frameStyle,
    required this.imageBase64,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool isViewedBy(String uid) => viewedBy.contains(uid);

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarBase64: data['avatarBase64'] as String?,
      frameStyle: data['frameStyle'] as String?,
      imageBase64: data['imageBase64'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewedBy: List<String>.from(data['viewedBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'username': username,
        'avatarBase64': avatarBase64 ?? '',
        'frameStyle': frameStyle ?? 'none',
        'imageBase64': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'viewedBy': viewedBy,
      };

  StoryModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarBase64,
    String? frameStyle,
    String? imageBase64,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewedBy,
  }) =>
      StoryModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        avatarBase64: avatarBase64 ?? this.avatarBase64,
        frameStyle: frameStyle ?? this.frameStyle,
        imageBase64: imageBase64 ?? this.imageBase64,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        viewedBy: viewedBy ?? this.viewedBy,
      );
}
