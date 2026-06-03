import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportTargetType { post, comment, message, user, story }

enum ReportReason { spam, hateSpeech, inappropriate, harassment, other }

enum ReportStatus { pending, reviewed, resolved }

class ReportModel {
  final String id;
  final String reporterId;
  final String targetId;
  final ReportTargetType targetType;
  final ReportReason reason;
  final String description;
  final String targetContent;
  final DateTime createdAt;
  final ReportStatus status;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetId,
    required this.targetType,
    required this.reason,
    this.description = '',
    this.targetContent = '',
    required this.createdAt,
    this.status = ReportStatus.pending,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      targetId: data['targetId'] as String? ?? '',
      targetType: ReportTargetType.values.byName(
          data['targetType'] as String? ?? 'post'),
      reason: ReportReason.values.byName(
          data['reason'] as String? ?? 'other'),
      description: data['description'] as String? ?? '',
      targetContent: data['targetContent'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ReportStatus.values.byName(
          data['status'] as String? ?? 'pending'),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'reporterId': reporterId,
        'targetId': targetId,
        'targetType': targetType.name,
        'reason': reason.name,
        'description': description,
        'targetContent': targetContent,
        'createdAt': FieldValue.serverTimestamp(),
        'status': status.name,
      };
}
