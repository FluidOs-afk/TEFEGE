import 'package:cloud_firestore/cloud_firestore.dart';

class AiOutfit {
  final String id;
  final String occasion;
  final String weatherContext;
  final String suggestion;
  final List<String> wardrobeUsed;
  final DateTime createdAt;

  const AiOutfit({
    required this.id,
    required this.occasion,
    required this.weatherContext,
    required this.suggestion,
    this.wardrobeUsed = const [],
    required this.createdAt,
  });

  factory AiOutfit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AiOutfit(
      id: doc.id,
      occasion: data['occasion'] as String? ?? '',
      weatherContext: data['weatherContext'] as String? ?? '',
      suggestion: data['suggestion'] as String? ?? '',
      wardrobeUsed: List<String>.from(data['wardrobeUsed'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'occasion': occasion,
        'weatherContext': weatherContext,
        'suggestion': suggestion,
        'wardrobeUsed': wardrobeUsed,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
