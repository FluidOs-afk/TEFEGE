import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../utils/image_utils.dart';

class ProfileService {
  static final ProfileService instance = ProfileService._();
  ProfileService._();

  final _db = FirebaseFirestore.instance;

  Future<UserModel> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel> streamUser(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromFirestore(doc));
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> saveAvatarBase64(String uid, XFile file) async {
    final base64 = await ImageUtils.imageToBase64(file);
    await _db.collection('users').doc(uid).update({'avatarBase64': base64});
  }

  Future<void> follow(String currentUid, String targetUid) async {
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(currentUid), {
      'following': FieldValue.arrayUnion([targetUid]),
    });
    batch.update(_db.collection('users').doc(targetUid), {
      'followers': FieldValue.arrayUnion([currentUid]),
    });
    await batch.commit();
  }

  Future<void> unfollow(String currentUid, String targetUid) async {
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(currentUid), {
      'following': FieldValue.arrayRemove([targetUid]),
    });
    batch.update(_db.collection('users').doc(targetUid), {
      'followers': FieldValue.arrayRemove([currentUid]),
    });
    await batch.commit();
  }

  Future<bool> isFollowing(String currentUid, String targetUid) async {
    final doc = await _db.collection('users').doc(currentUid).get();
    final data = doc.data();
    if (data == null) return false;
    return List<String>.from(data['following'] as List? ?? []).contains(targetUid);
  }
}
