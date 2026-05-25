import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String userId;
  final String username;
  final String displayName;
  final String bio;
  final String location;
  final DateTime? lastUsernameChange;
  final int followersCount;
  final int followingCount;
  final List<String> followedBy;

  const UserProfile({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.location,
    this.lastUsernameChange,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followedBy = const [],
  });

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  bool get canChangeUsername {
    if (lastUsernameChange == null) return true;
    return DateTime.now().difference(lastUsernameChange!) >=
        const Duration(days: 7);
  }

  int get daysUntilUsernameChange {
    if (lastUsernameChange == null) return 0;
    final elapsed = DateTime.now().difference(lastUsernameChange!);
    final remaining = const Duration(days: 7) - elapsed;
    return remaining.isNegative ? 0 : remaining.inDays + 1;
  }

  UserProfile copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? bio,
    String? location,
    DateTime? lastUsernameChange,
    bool clearLastUsernameChange = false,
    int? followersCount,
    int? followingCount,
    List<String>? followedBy,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      lastUsernameChange: clearLastUsernameChange
          ? null
          : (lastUsernameChange ?? this.lastUsernameChange),
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followedBy: followedBy ?? this.followedBy,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'bio': bio,
    'location': location,
    'lastUsernameChange': lastUsernameChange?.millisecondsSinceEpoch,
    'followersCount': followersCount,
    'followingCount': followingCount,
    'followedBy': followedBy,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'] as String? ?? '',
    username: json['username'] as String? ?? 'usuario',
    displayName: json['displayName'] as String? ?? 'Usuario',
    bio: json['bio'] as String? ?? '',
    location: json['location'] as String? ?? '',
    lastUsernameChange: json['lastUsernameChange'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['lastUsernameChange'] as int)
        : null,
    followersCount: json['followersCount'] as int? ?? 0,
    followingCount: json['followingCount'] as int? ?? 0,
    followedBy: List<String>.from(json['followedBy'] as List? ?? []),
  );

  static const defaultProfile = UserProfile(
    userId: 'u_sergio',
    username: 'sergio.outfy',
    displayName: 'Sergio Ruiz',
    bio: 'Apasionado de la moda\nArmario curado con amor\nMadrid · DAM 2025',
    location: 'Madrid, España',
    followersCount: 1250,
    followingCount: 342,
  );
}

class ProfileService extends ChangeNotifier {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  static const _prefKey = 'outfy_user_profile';

  UserProfile _profile = UserProfile.defaultProfile;
  UserProfile get profile => _profile;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      try {
        _profile = UserProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _profile = UserProfile.defaultProfile;
      }
    }
    notifyListeners();
  }

  Future<void> save(UserProfile updated) async {
    _profile = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(updated.toJson()));
    notifyListeners();
  }
}
