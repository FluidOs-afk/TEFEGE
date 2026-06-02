import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  static final ReportService instance = ReportService._();
  ReportService._();

  final _db = FirebaseFirestore.instance;

  Future<void> submitReport(ReportModel report) async {
    await _db.collection('reports').add(report.toFirestore());
  }

  Stream<List<ReportModel>> getUserReports(String userId) {
    return _db
        .collection('reports')
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReportModel.fromFirestore).toList());
  }
}
