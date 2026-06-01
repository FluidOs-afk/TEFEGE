import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../utils/image_utils.dart';

class StoriesService {
  static final StoriesService instance = StoriesService._();
  StoriesService._();

  final _db = FirebaseFirestore.instance;

  // Stream de historias activas agrupadas por userId (la más reciente de cada usuario)
  Stream<List<StoryModel>> streamActiveStories() {
    final now = Timestamp.now();
    return _db
        .collection('stories')
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt', descending: true)
        .snapshots()
        .map((snap) {
      final stories = snap.docs.map(StoryModel.fromFirestore).toList();
      // Agrupar: una historia por usuario (la más reciente)
      final Map<String, StoryModel> byUser = {};
      for (final s in stories) {
        if (!byUser.containsKey(s.userId) ||
            s.createdAt.isAfter(byUser[s.userId]!.createdAt)) {
          byUser[s.userId] = s;
        }
      }
      final result = byUser.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    });
  }

  // Obtener historia activa del usuario actual (si existe)
  Future<StoryModel?> getMyActiveStory(String uid) async {
    final now = Timestamp.now();
    final snap = await _db
        .collection('stories')
        .where('userId', isEqualTo: uid)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return StoryModel.fromFirestore(snap.docs.first);
  }

  Future<void> createStory(String uid, UserModel user, XFile imageFile) async {
    final base64 = await ImageUtils.imageToBase64(imageFile);
    final now = DateTime.now();
    final expires = now.add(const Duration(hours: 24));
    await _db.collection('stories').add({
      'userId': uid,
      'username': user.username,
      'avatarBase64': user.avatarBase64,
      'frameStyle': user.frameStyle,
      'imageBase64': base64,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expires),
      'viewedBy': [],
    });
  }

  Future<void> markAsViewed(String storyId, String uid) async {
    await _db.collection('stories').doc(storyId).update({
      'viewedBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> deleteExpiredStories() async {
    final now = Timestamp.now();
    final snap = await _db
        .collection('stories')
        .where('expiresAt', isLessThan: now)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }
}
