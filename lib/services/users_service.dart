import 'package:flutter/foundation.dart';

class User {
  final String userId;
  final String username;
  final String displayName;
  final String bio;
  final String location;
  final int followersCount;
  final int followingCount;

  const User({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.location,
    required this.followersCount,
    required this.followingCount,
  });

  User copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? bio,
    String? location,
    int? followersCount,
    int? followingCount,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

class UsersService extends ChangeNotifier {
  UsersService._();
  static final UsersService instance = UsersService._();

  // Mock data of other users
  final Map<String, User> _users = {
    'u_sofia': const User(
      userId: 'u_sofia',
      username: 'sofia.styles',
      displayName: 'Sofia Martínez',
      bio: 'Amante de la moda sostenible\nFotógrafa de outfits\nMadrid',
      location: 'Madrid, España',
      followersCount: 2340,
      followingCount: 456,
    ),
    'u_marta': const User(
      userId: 'u_marta',
      username: 'marta.fashion',
      displayName: 'Marta López',
      bio:
          'Fashion blogger & stylist\nConsultor de imágenes personales\nTendencias y clásicos',
      location: 'Barcelona, España',
      followersCount: 5678,
      followingCount: 234,
    ),
    'u_lucia': const User(
      userId: 'u_lucia',
      username: 'lucia.vintage',
      displayName: 'Lucía García',
      bio:
          'Vintage lover ✨\nThrift store hunter\nSostenibilidad y estilo retro',
      location: 'Valencia, España',
      followersCount: 1890,
      followingCount: 567,
    ),
    'u_andrea': const User(
      userId: 'u_andrea',
      username: 'andrea.glam',
      displayName: 'Andrea Fernández',
      bio: 'Estilismo y moda minimalista\nConsultora de looks\nLess is more',
      location: 'Madrid, España',
      followersCount: 3456,
      followingCount: 789,
    ),
    'u_carmen': const User(
      userId: 'u_carmen',
      username: 'carmen.b',
      displayName: 'Carmen Blanco',
      bio: 'Color, denim y prendas faciles para diario',
      location: 'Sevilla, Espana',
      followersCount: 1480,
      followingCount: 321,
    ),
    'u_paula': const User(
      userId: 'u_paula',
      username: 'paula.m',
      displayName: 'Paula Molina',
      bio: 'Looks urbanos, cargo pants y accesorios mini',
      location: 'Bilbao, Espana',
      followersCount: 2035,
      followingCount: 412,
    ),
  };

  // Track which users the current user is following
  final Set<String> _following = {};

  // Get user by userId
  User? getUser(String userId) {
    return _users[userId];
  }

  User? getUserByUsername(String username) {
    final normalized = username.toLowerCase();
    for (final user in _users.values) {
      if (user.username.toLowerCase() == normalized) return user;
    }
    return null;
  }

  // Get all users except current user
  List<User> getAllUsers(String currentUserId) {
    return _users.values.where((user) => user.userId != currentUserId).toList();
  }

  // Search users by username, displayName, or bio
  List<User> searchUsers(String query, String currentUserId) {
    if (query.isEmpty) {
      return getAllUsers(currentUserId);
    }

    final lowerQuery = query.toLowerCase();
    return _users.values
        .where(
          (user) =>
              user.userId != currentUserId &&
              (user.username.toLowerCase().contains(lowerQuery) ||
                  user.displayName.toLowerCase().contains(lowerQuery) ||
                  user.bio.toLowerCase().contains(lowerQuery)),
        )
        .toList();
  }

  // Follow a user
  void followUser(String userId) {
    if (_users.containsKey(userId) && !_following.contains(userId)) {
      _following.add(userId);
      notifyListeners();
    }
  }

  // Unfollow a user
  void unfollowUser(String userId) {
    if (_following.contains(userId)) {
      _following.remove(userId);
      notifyListeners();
    }
  }

  // Check if following a user
  bool isFollowing(String userId) {
    return _following.contains(userId);
  }

  // Get follower count for a user
  int getFollowingCount() {
    return _following.length;
  }

  // Get list of users being followed
  List<User> getFollowingList() {
    return _following
        .map((userId) => _users[userId])
        .whereType<User>()
        .toList();
  }

  // Load following list (can be extended to use SharedPreferences)
  void loadFollowing() {
    // TODO: Load from SharedPreferences if needed
  }

  // Save following list (can be extended to use SharedPreferences)
  void saveFollowing() {
    // TODO: Save to SharedPreferences if needed
  }
}
