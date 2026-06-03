import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';

class ReportService {
  static final ReportService instance = ReportService._();
  ReportService._();

  final _db = FirebaseFirestore.instance;

  Future<void> submitReport(ReportModel report) async {
    await _db.collection('reports').add(report.toFirestore());
    if (!kIsWeb) _sendWebhook(report);
  }

  Stream<List<ReportModel>> getUserReports(String userId) {
    return _db
        .collection('reports')
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReportModel.fromFirestore).toList());
  }

  void _sendWebhook(ReportModel report) {
    final url = dotenv.env['WEBHOOK_URL'] ?? '';
    if (url.isEmpty) return;

    final typeLabel = _typeLabel(report.targetType);
    final reasonLabel = _reasonLabel(report.reason);
    final desc = report.description.isNotEmpty ? report.description : '—';
    final content = report.targetContent.isNotEmpty ? report.targetContent : '—';

    final fields = [
      {'name': 'Tipo de contenido', 'value': typeLabel, 'inline': true},
      {'name': 'Motivo', 'value': reasonLabel, 'inline': true},
      {'name': 'Contenido denunciado', 'value': content, 'inline': false},
      {'name': 'ID del contenido', 'value': report.targetId, 'inline': false},
      {'name': 'Denunciante (UID)', 'value': report.reporterId, 'inline': false},
      if (report.description.isNotEmpty)
        {'name': 'Descripción adicional', 'value': desc, 'inline': false},
    ];

    final payload = jsonEncode({
      'embeds': [
        {
          'title': '🚨 Nueva denuncia — OUTFY',
          'color': 0xE53935,
          'fields': fields,
          'timestamp': report.createdAt.toUtc().toIso8601String(),
        }
      ]
    });

    http
        .post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'}, body: payload)
        .ignore();
  }

  String _typeLabel(ReportTargetType t) => switch (t) {
        ReportTargetType.post    => 'Publicación',
        ReportTargetType.comment => 'Comentario',
        ReportTargetType.message => 'Mensaje',
        ReportTargetType.user    => 'Usuario',
        ReportTargetType.story   => 'Historia',
      };

  String _reasonLabel(ReportReason r) => switch (r) {
        ReportReason.spam          => 'Spam',
        ReportReason.hateSpeech    => 'Lenguaje de odio',
        ReportReason.inappropriate => 'Contenido inapropiado',
        ReportReason.harassment    => 'Acoso',
        ReportReason.other         => 'Otro',
      };
}
