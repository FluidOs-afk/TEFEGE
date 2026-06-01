import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombre;
  final String username;
  final String bio;
  final String avatarBase64;
  final String frameStyle; // 'none', 'green', 'gradient', 'gold'
  final bool isPrivate;
  final List<String> followers;
  final List<String> following;
  final List<String> pendingRequests;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.nombre,
    required this.username,
    this.bio = '',
    this.avatarBase64 = '',
    this.frameStyle = 'none',
    this.isPrivate = false,
    this.followers = const [],
    this.following = const [],
    this.pendingRequests = const [],
    this.fcmToken,
    required this.createdAt,
  });

  String get displayName => nombre;

  String get initials {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nombre: data['nombre'] as String? ?? '',
      username: data['username'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      avatarBase64: data['avatarBase64'] as String? ?? '',
      frameStyle: data['frameStyle'] as String? ?? 'none',
      isPrivate: data['isPrivate'] as bool? ?? false,
      followers: List<String>.from(data['followers'] as List? ?? []),
      following: List<String>.from(data['following'] as List? ?? []),
      pendingRequests: List<String>.from(data['pendingRequests'] as List? ?? []),
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'username': username,
        'bio': bio,
        'avatarBase64': avatarBase64,
        'frameStyle': frameStyle,
        'isPrivate': isPrivate,
        'followers': followers,
        'following': following,
        'pendingRequests': pendingRequests,
        if (fcmToken != null) 'fcmToken': fcmToken,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? uid,
    String? nombre,
    String? username,
    String? bio,
    String? avatarBase64,
    String? frameStyle,
    bool? isPrivate,
    List<String>? followers,
    List<String>? following,
    List<String>? pendingRequests,
    String? fcmToken,
    DateTime? createdAt,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        nombre: nombre ?? this.nombre,
        username: username ?? this.username,
        bio: bio ?? this.bio,
        avatarBase64: avatarBase64 ?? this.avatarBase64,
        frameStyle: frameStyle ?? this.frameStyle,
        isPrivate: isPrivate ?? this.isPrivate,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        pendingRequests: pendingRequests ?? this.pendingRequests,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt ?? this.createdAt,
      );
}
