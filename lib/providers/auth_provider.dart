import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/notifications_service.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _initialized = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _initialized = true;
      notifyListeners();
      return;
    }
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      _currentUser = doc.exists ? UserModel.fromFirestore(doc) : null;
      if (_currentUser != null) {
        NotificationsService.instance.saveToken(firebaseUser.uid);
      }
    } catch (_) {
      _currentUser = null;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return _fail(_authErrorToSpanish(e.code));
    } catch (_) {
      return _fail('Error inesperado. Inténtalo de nuevo.');
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String nombre,
    required String username,
  }) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final now = DateTime.now();
      await _db.collection('users').doc(uid).set({
        'nombre': nombre.trim(),
        'username': username.trim().toLowerCase(),
        'bio': '',
        'avatarBase64': '',
        'isPrivate': false,
        'followers': [],
        'following': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      _currentUser = UserModel(
        uid: uid,
        nombre: nombre.trim(),
        username: username.trim().toLowerCase(),
        createdAt: now,
      );
      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return _fail(_authErrorToSpanish(e.code));
    } catch (_) {
      return _fail('Error al crear la cuenta. Inténtalo de nuevo.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_authErrorToSpanish(e.code));
    }
  }

  Future<void> refreshCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      _currentUser = doc.exists ? UserModel.fromFirestore(doc) : null;
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
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

  String _authErrorToSpanish(String code) => switch (code) {
        'user-not-found' => 'No existe ninguna cuenta con ese correo.',
        'wrong-password' => 'Contraseña incorrecta.',
        'invalid-credential' => 'Email o contraseña incorrectos.',
        'email-already-in-use' => 'Este email ya está registrado.',
        'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
        'invalid-email' => 'El email no tiene un formato válido.',
        'too-many-requests' => 'Demasiados intentos. Inténtalo más tarde.',
        'network-request-failed' => 'Sin conexión. Comprueba tu internet.',
        'user-disabled' => 'Esta cuenta ha sido desactivada.',
        _ => 'Error de autenticación. Inténtalo de nuevo.',
      };
}

class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult._({required this.success, this.errorMessage});

  factory AuthResult.success() => const AuthResult._(success: true);
  factory AuthResult.failure(String msg) =>
      AuthResult._(success: false, errorMessage: msg);
}
