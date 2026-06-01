import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../utils/image_utils.dart';
import 'notifications_service.dart';

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

    final currentUserDoc = await _db.collection('users').doc(currentUid).get();
    final currentUser = UserModel.fromFirestore(currentUserDoc);
    NotificationsService.instance.createNotification(
      toUid: targetUid,
      fromUid: currentUid,
      fromUsername: currentUser.username,
      fromAvatarBase64: currentUser.avatarBase64,
      type: 'follow',
    );
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

  Future<void> sendFollowRequest(String currentUid, String targetUid) async {
    await _db.collection('users').doc(targetUid).update({
      'pendingRequests': FieldValue.arrayUnion([currentUid]),
    });
  }

  Future<void> cancelFollowRequest(String currentUid, String targetUid) async {
    await _db.collection('users').doc(targetUid).update({
      'pendingRequests': FieldValue.arrayRemove([currentUid]),
    });
  }

  Future<void> acceptFollowRequest(String ownerUid, String requesterUid) async {
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(ownerUid), {
      'pendingRequests': FieldValue.arrayRemove([requesterUid]),
      'followers': FieldValue.arrayUnion([requesterUid]),
    });
    batch.update(_db.collection('users').doc(requesterUid), {
      'following': FieldValue.arrayUnion([ownerUid]),
    });
    await batch.commit();

    final ownerDoc = await _db.collection('users').doc(ownerUid).get();
    final ownerUser = UserModel.fromFirestore(ownerDoc);
    NotificationsService.instance.createNotification(
      toUid: requesterUid,
      fromUid: ownerUid,
      fromUsername: ownerUser.username,
      fromAvatarBase64: ownerUser.avatarBase64,
      type: 'follow_accept',
    );
  }

  Future<void> rejectFollowRequest(String ownerUid, String requesterUid) async {
    await _db.collection('users').doc(ownerUid).update({
      'pendingRequests': FieldValue.arrayRemove([requesterUid]),
    });
  }
}
