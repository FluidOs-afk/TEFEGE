import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_thread.dart';
import '../models/forum_reply.dart';

class ForumService {
  static final ForumService instance = ForumService._();
  ForumService._();

  final _db = FirebaseFirestore.instance;

  Stream<List<ForumThread>> streamThreads({String? category}) {
    Query<Map<String, dynamic>> q =
        _db.collection('forum').orderBy('createdAt', descending: true);
    if (category != null && category != 'Todos') {
      q = q.where('category', isEqualTo: category);
    }
    return q
        .snapshots()
        .map((s) => s.docs.map(ForumThread.fromFirestore).toList());
  }

  Future<void> createThread(ForumThread thread) async {
    final ref = _db.collection('forum').doc();
    await ref.set(thread.copyWith(id: ref.id).toFirestore());
  }

  Future<void> deleteThread(String threadId) async {
    await _db.collection('forum').doc(threadId).delete();
  }

  Future<void> toggleLike(String threadId, String uid) async {
    final ref = _db.collection('forum').doc(threadId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final likedBy = List<String>.from(
        (doc.data() as Map<String, dynamic>)['likedBy'] as List? ?? []);
    if (likedBy.contains(uid)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  Stream<List<ForumReply>> streamReplies(String threadId) {
    return _db
        .collection('forum')
        .doc(threadId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(ForumReply.fromFirestore).toList());
  }

  Future<void> addReply(String threadId, ForumReply reply) async {
    final ref = _db
        .collection('forum')
        .doc(threadId)
        .collection('replies')
        .doc();
    await ref.set(reply.toFirestore());
  }

  Future<void> deleteReply(String threadId, String replyId) async {
    await _db
        .collection('forum')
        .doc(threadId)
        .collection('replies')
        .doc(replyId)
        .delete();
  }

  Future<void> toggleReplyLike(String threadId, String replyId, String uid) async {
    final ref = _db
        .collection('forum')
        .doc(threadId)
        .collection('replies')
        .doc(replyId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final likedBy = List<String>.from(
        (doc.data() as Map<String, dynamic>)['likedBy'] as List? ?? []);
    if (likedBy.contains(uid)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likes': FieldValue.increment(1),
      });
    }
  }
}
