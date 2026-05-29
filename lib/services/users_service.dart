import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UsersService {
  static final UsersService instance = UsersService._();
  UsersService._();

  final _db = FirebaseFirestore.instance;

  /// Búsqueda por prefijo de username usando startAt/endAt de Firestore.
  Future<List<UserModel>> searchByUsername(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final snap = await _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: q)
        .where('username', isLessThan: '$q')
        .limit(20)
        .get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }
}
