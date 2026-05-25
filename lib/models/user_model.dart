import 'dart:math';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profileImagePath;
  final DateTime? birthDate;
  final String? gender;
  final String? country;
  final String? city;
  final List<String> favoriteStyles;
  final String? topSize;
  final String? bottomSize;
  final String? shoeSize;
  final String? instagramHandle;
  final String? tiktokHandle;
  final List<String> fashionPreferences;
  final DateTime createdAt;
  final bool acceptedTerms;
  final bool acceptedNewsletter;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profileImagePath,
    this.birthDate,
    this.gender,
    this.country,
    this.city,
    this.favoriteStyles = const [],
    this.topSize,
    this.bottomSize,
    this.shoeSize,
    this.instagramHandle,
    this.tiktokHandle,
    this.fashionPreferences = const [],
    required this.createdAt,
    this.acceptedTerms = false,
    this.acceptedNewsletter = false,
  });

  String get displayName => '$firstName $lastName'.trim();

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }

  String get location {
    if (city != null && city!.isNotEmpty && country != null && country!.isNotEmpty) {
      return '$city, $country';
    }
    if (city != null && city!.isNotEmpty) return city!;
    if (country != null && country!.isNotEmpty) return country!;
    return '';
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
    String? profileImagePath,
    DateTime? birthDate,
    String? gender,
    String? country,
    String? city,
    List<String>? favoriteStyles,
    String? topSize,
    String? bottomSize,
    String? shoeSize,
    String? instagramHandle,
    String? tiktokHandle,
    List<String>? fashionPreferences,
    DateTime? createdAt,
    bool? acceptedTerms,
    bool? acceptedNewsletter,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      favoriteStyles: favoriteStyles ?? this.favoriteStyles,
      topSize: topSize ?? this.topSize,
      bottomSize: bottomSize ?? this.bottomSize,
      shoeSize: shoeSize ?? this.shoeSize,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      tiktokHandle: tiktokHandle ?? this.tiktokHandle,
      fashionPreferences: fashionPreferences ?? this.fashionPreferences,
      createdAt: createdAt ?? this.createdAt,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      acceptedNewsletter: acceptedNewsletter ?? this.acceptedNewsletter,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'bio': bio,
        'profileImagePath': profileImagePath,
        'birthDate': birthDate?.millisecondsSinceEpoch,
        'gender': gender,
        'country': country,
        'city': city,
        'favoriteStyles': favoriteStyles,
        'topSize': topSize,
        'bottomSize': bottomSize,
        'shoeSize': shoeSize,
        'instagramHandle': instagramHandle,
        'tiktokHandle': tiktokHandle,
        'fashionPreferences': fashionPreferences,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'acceptedTerms': acceptedTerms,
        'acceptedNewsletter': acceptedNewsletter,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String? ?? '',
        bio: json['bio'] as String?,
        profileImagePath: json['profileImagePath'] as String?,
        birthDate: json['birthDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['birthDate'] as int)
            : null,
        gender: json['gender'] as String?,
        country: json['country'] as String?,
        city: json['city'] as String?,
        favoriteStyles: (json['favoriteStyles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        topSize: json['topSize'] as String?,
        bottomSize: json['bottomSize'] as String?,
        shoeSize: json['shoeSize'] as String?,
        instagramHandle: json['instagramHandle'] as String?,
        tiktokHandle: json['tiktokHandle'] as String?,
        fashionPreferences: (json['fashionPreferences'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        acceptedTerms: json['acceptedTerms'] as bool? ?? false,
        acceptedNewsletter: json['acceptedNewsletter'] as bool? ?? false,
      );

  // Deterministic DJB2 hash - for prototype use only
  static String hashPassword(String password) {
    final salt = 'outfy_2025_\$alt';
    final input = '$password$salt';
    var hash = 5381;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) + hash + input.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return '${hash.toRadixString(16)}${password.length.toRadixString(16)}';
  }

  static String generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random.secure();
    final part = rnd.nextInt(0xFFFFFF).toRadixString(36).padLeft(5, '0');
    return '${now.toRadixString(36)}_$part';
  }
}
