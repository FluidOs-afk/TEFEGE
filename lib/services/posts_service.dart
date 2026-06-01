import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/user_post.dart';
import '../utils/image_utils.dart';
import 'notifications_service.dart';

class PostsService {
  static final PostsService instance = PostsService._();
  PostsService._();

  final _db = FirebaseFirestore.instance;

  Stream<List<PostModel>> streamFeedPosts(
      String currentUid, List<String> following,
      {int limit = 10}) {
    final ids = [...following, currentUid];
    if (ids.isEmpty) return Stream.value([]);
    final batch = ids.take(30).toList();
    return _db
        .collection('posts')
        .where('userId', whereIn: batch)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(PostModel.fromFirestore).toList());
  }

  Stream<List<PostModel>> streamUserPosts(String uid) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PostModel.fromFirestore).toList());
  }

  Future<void> createPost(PostModel post, XFile imageFile) async {
    final docRef = _db.collection('posts').doc();
    final base64 = await ImageUtils.imageToBase64(imageFile);
    final data = post.toFirestore();
    data['imageBase64'] = base64;
    await docRef.set(data);
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  Future<void> toggleLike(String postId, String uid) async {
    final ref = _db.collection('posts').doc(postId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
    final wasLiked = likedBy.contains(uid);

    if (wasLiked) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likes': FieldValue.increment(1),
      });
      // Notificar al dueño del post
      final postOwnerId = data['userId'] as String? ?? '';
      if (postOwnerId.isNotEmpty) {
        final currentUserDoc = await _db.collection('users').doc(uid).get();
        final currentUser = UserModel.fromFirestore(currentUserDoc);
        NotificationsService.instance.createNotification(
          toUid: postOwnerId,
          fromUid: uid,
          fromUsername: currentUser.username,
          fromAvatarBase64: currentUser.avatarBase64,
          type: 'like',
          postId: postId,
          postTitle: data['title'] as String? ?? '',
        );
      }
    }
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    final postDoc = await _db.collection('posts').doc(postId).get();
    await _db.collection('posts').doc(postId).collection('comments').add(comment.toFirestore());

    // Notificar al dueño del post
    if (postDoc.exists) {
      final postData = postDoc.data() as Map<String, dynamic>;
      final postOwnerId = postData['userId'] as String? ?? '';
      if (postOwnerId.isNotEmpty) {
        final currentUserDoc = await _db.collection('users').doc(comment.userId).get();
        final currentUser = UserModel.fromFirestore(currentUserDoc);
        NotificationsService.instance.createNotification(
          toUid: postOwnerId,
          fromUid: comment.userId,
          fromUsername: currentUser.username,
          fromAvatarBase64: currentUser.avatarBase64,
          type: 'comment',
          postId: postId,
          postTitle: postData['title'] as String? ?? '',
          text: comment.text,
        );
      }
    }
  }

  Stream<List<CommentModel>> streamComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CommentModel.fromFirestore).toList());
  }
}
