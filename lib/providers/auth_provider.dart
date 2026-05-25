import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _usersKey = 'outfy_users_v2';
  static const _sessionKey = 'outfy_session_v2';
  static const _passwordsKey = 'outfy_passwords_v2';

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_sessionKey);
    if (sessionId == null) return;

    final usersRaw = prefs.getString(_usersKey);
    if (usersRaw == null) return;

    try {
      final list = jsonDecode(usersRaw) as List<dynamic>;
      final matches = list
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .where((u) => u.id == sessionId)
          .toList();

      if (matches.isNotEmpty) {
        _currentUser = matches.first;
        await _syncProfile(_currentUser!);
      }
    } catch (_) {
      _currentUser = null;
    }
  }

  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);

    // Simula latencia de red para UX realista
    await Future.delayed(const Duration(milliseconds: 700));

    final prefs = await SharedPreferences.getInstance();

    try {
      final usersRaw = prefs.getString(_usersKey);
      if (usersRaw == null) {
        return _fail('No existe ninguna cuenta con ese correo electrónico.');
      }

      final list = jsonDecode(usersRaw) as List<dynamic>;
      final users = list
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final emailLower = email.toLowerCase().trim();
      final matching = users.where((u) => u.email.toLowerCase() == emailLower).toList();

      if (matching.isEmpty) {
        return _fail('No existe ninguna cuenta con ese correo electrónico.');
      }

      final user = matching.first;
      final passwordsRaw = prefs.getString(_passwordsKey);
      if (passwordsRaw == null) {
        return _fail('Error de autenticación. Inténtalo de nuevo.');
      }

      final passwords = jsonDecode(passwordsRaw) as Map<String, dynamic>;
      final stored = passwords[user.id] as String?;

      if (stored == null || stored != UserModel.hashPassword(password)) {
        return _fail('Contraseña incorrecta.');
      }

      _currentUser = user;
      await prefs.setString(_sessionKey, user.id);
      await _syncProfile(user);

      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } catch (e) {
      return _fail('Error inesperado. Inténtalo de nuevo.');
    }
  }

  Future<AuthResult> register(UserModel user, String password) async {
    _setLoading(true);

    await Future.delayed(const Duration(milliseconds: 900));

    final prefs = await SharedPreferences.getInstance();

    try {
      final usersRaw = prefs.getString(_usersKey);
      final List<UserModel> existing = usersRaw != null
          ? (jsonDecode(usersRaw) as List<dynamic>)
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [];

      if (existing.any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
        return _fail('Este correo electrónico ya está registrado.');
      }

      if (existing.any((u) => u.username.toLowerCase() == user.username.toLowerCase())) {
        return _fail('Este nombre de usuario ya está en uso.');
      }

      final updated = [...existing, user];
      await prefs.setString(
        _usersKey,
        jsonEncode(updated.map((u) => u.toJson()).toList()),
      );

      final passwordsRaw = prefs.getString(_passwordsKey);
      final passwords = passwordsRaw != null
          ? jsonDecode(passwordsRaw) as Map<String, dynamic>
          : <String, dynamic>{};
      passwords[user.id] = UserModel.hashPassword(password);
      await prefs.setString(_passwordsKey, jsonEncode(passwords));

      await prefs.setString(_sessionKey, user.id);
      _currentUser = user;
      await _syncProfile(user);

      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } catch (e) {
      return _fail('Error al crear la cuenta. Inténtalo de nuevo.');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  Future<bool> isUsernameAvailable(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_usersKey);
    if (usersRaw == null) return true;

    final users = (jsonDecode(usersRaw) as List<dynamic>)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return !users.any(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
  }

  Future<void> _syncProfile(UserModel user) async {
    await ProfileService.instance.save(UserProfile(
      userId: user.id,
      username: user.username,
      displayName: user.displayName,
      bio: user.bio ?? '',
      location: user.location,
      profileImagePath: user.profileImagePath,
    ));
  }

  void _setLoading(bool v) {
    _isLoading = v;
    _error = null;
    notifyListeners();
  }

  AuthResult _fail(String msg) {
    _error = msg;
    _isLoading = false;
    notifyListeners();
    return AuthResult.failure(msg);
  }
}

class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult._({required this.success, this.errorMessage});

  factory AuthResult.success() => const AuthResult._(success: true);
  factory AuthResult.failure(String msg) =>
      AuthResult._(success: false, errorMessage: msg);
}
