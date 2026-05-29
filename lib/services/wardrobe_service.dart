import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wardrobe_item.dart';
import '../utils/image_utils.dart';

class WardrobeService {
  static final WardrobeService instance = WardrobeService._();
  WardrobeService._();

  final _db = FirebaseFirestore.instance;

  Stream<List<WardrobeItem>> streamItems(String uid) {
    return _db
        .collection('wardrobe')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(WardrobeItem.fromFirestore).toList());
  }

  Future<List<WardrobeItem>> getItems(String uid) async {
    final snap = await _db
        .collection('wardrobe')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(WardrobeItem.fromFirestore).toList();
  }

  /// Comprime la imagen, la convierte a Base64 y guarda la prenda en Firestore.
  Future<WardrobeItem> addItem(
      String uid, WardrobeItem item, File? imageFile) async {
    final ref = _db
        .collection('wardrobe')
        .doc(uid)
        .collection('items')
        .doc();

    String imageBase64 = '';
    if (imageFile != null) {
      imageBase64 = await ImageUtils.imageToBase64(imageFile);
    }

    final finalItem = item.copyWith(id: ref.id, imageBase64: imageBase64);
    await ref.set(finalItem.toFirestore());
    return finalItem;
  }

  Future<void> deleteItem(String uid, String itemId) async {
    await _db
        .collection('wardrobe')
        .doc(uid)
        .collection('items')
        .doc(itemId)
        .delete();
  }
}
