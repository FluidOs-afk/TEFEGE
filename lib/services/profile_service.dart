import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String username;
  final String displayName;
  final String bio;
  final String location;
  final String? profileImagePath;
  final DateTime? lastUsernameChange;

  const UserProfile({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.location,
    this.profileImagePath,
    this.lastUsernameChange,
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
    String? username,
    String? displayName,
    String? bio,
    String? location,
    String? profileImagePath,
    DateTime? lastUsernameChange,
    bool clearLastUsernameChange = false,
  }) {
    return UserProfile(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      lastUsernameChange: clearLastUsernameChange
          ? null
          : (lastUsernameChange ?? this.lastUsernameChange),
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'displayName': displayName,
        'bio': bio,
        'location': location,
        'profileImagePath': profileImagePath,
        'lastUsernameChange': lastUsernameChange?.millisecondsSinceEpoch,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json['username'] as String? ?? 'usuario',
        displayName: json['displayName'] as String? ?? 'Usuario',
        bio: json['bio'] as String? ?? '',
        location: json['location'] as String? ?? '',
        profileImagePath: json['profileImagePath'] as String?,
        lastUsernameChange: json['lastUsernameChange'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json['lastUsernameChange'] as int)
            : null,
      );

  static const defaultProfile = UserProfile(
    username: 'sergio.outfy',
    displayName: 'Sergio Ruiz',
    bio: 'Apasionado de la moda\nArmario curado con amor\nMadrid · DAM 2025',
    location: 'Madrid, España',
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
        _profile =
            UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
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
