import 'package:cloud_firestore/cloud_firestore.dart';

class WardrobeItem {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String color;
  final String imageBase64;
  final String barcodeValue;
  final DateTime createdAt;

  const WardrobeItem({
    required this.id,
    required this.name,
    this.brand = '',
    required this.category,
    this.color = '',
    this.imageBase64 = '',
    this.barcodeValue = '',
    required this.createdAt,
  });

  factory WardrobeItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WardrobeItem(
      id: doc.id,
      name: data['name'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      category: data['category'] as String? ?? '',
      color: data['color'] as String? ?? '',
      imageBase64: data['imageBase64'] as String? ?? '',
      barcodeValue: data['barcodeValue'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'brand': brand,
        'category': category,
        'color': color,
        'imageBase64': imageBase64,
        'barcodeValue': barcodeValue,
        'createdAt': FieldValue.serverTimestamp(),
      };

  WardrobeItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    String? color,
    String? imageBase64,
    String? barcodeValue,
    DateTime? createdAt,
  }) =>
      WardrobeItem(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        category: category ?? this.category,
        color: color ?? this.color,
        imageBase64: imageBase64 ?? this.imageBase64,
        barcodeValue: barcodeValue ?? this.barcodeValue,
        createdAt: createdAt ?? this.createdAt,
      );
}
