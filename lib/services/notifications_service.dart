import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class NotificationsService {
  static final NotificationsService instance = NotificationsService._();
  NotificationsService._();

  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  String get _backendUrl =>
      (dotenv.env['BACKEND_URL'] ?? '').replaceAll(RegExp(r'/$'), '');

  Future<void> init(GlobalKey<ScaffoldMessengerState> messengerKey) async {
    if (kIsWeb) return;
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification != null) {
          messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(
                '${notification.title ?? 'OUTFY'}: ${notification.body ?? ''}',
                style: GoogleFonts.dmSans(color: Colors.white),
              ),
            ),
          );
        }
      });
    } catch (_) {}
  }

  Future<void> saveToken(String uid) async {
    if (kIsWeb) return;
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _db.collection('users').doc(uid).update({'fcmToken': token});
      }
    } catch (_) {}
  }

  // ── Notificaciones in-app ─────────────────────────────────────────────────

  Future<void> createNotification({
    required String toUid,
    required String fromUid,
    required String fromUsername,
    required String? fromAvatarBase64,
    required String type,
    String? postId,
    String? postTitle,
    String? text,
  }) async {
    if (toUid == fromUid) return;
    try {
      await _db.collection('notifications').add({
        'toUid': toUid,
        'fromUid': fromUid,
        'fromUsername': fromUsername,
        'fromAvatarBase64': fromAvatarBase64 ?? '',
        'type': type,
        'postId': postId,
        'postTitle': postTitle,
        'text': text,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Enviar push al dispositivo via backend Railway
      _sendPushViaBackend(
        toUid: toUid,
        type: type,
        fromUsername: fromUsername,
        postTitle: postTitle,
        text: text,
      );
    } catch (_) {}
  }

  Future<void> _sendPushViaBackend({
    required String toUid,
    required String type,
    required String fromUsername,
    String? postTitle,
    String? text,
  }) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null || _backendUrl.isEmpty) return;
      await http.post(
        Uri.parse('$_backendUrl/send-push'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'toUid': toUid,
          'type': type,
          'fromUsername': fromUsername,
          'postTitle': postTitle ?? '',
          'text': text ?? '',
        }),
      );
    } catch (_) {}
  }

  Stream<QuerySnapshot> streamNotifications(String uid) {
    // Sin orderBy para evitar requerir un índice compuesto en Firestore.
    // La ordenación se aplica en el cliente dentro de NotificationsScreen.
    return _db
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .limit(50)
        .snapshots();
  }

  Stream<int> streamUnreadCount(String uid) {
    return _db
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<void> markAllAsRead(String uid) async {
    final snap = await _db
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  String getNotificationText(Map<String, dynamic> data) {
    final from = data['fromUsername'] as String? ?? 'Alguien';
    return switch (data['type']) {
      'like'          => '$from le ha dado like a tu publicación "${data['postTitle'] ?? ''}"',
      'comment'       => '$from comentó en tu publicación: "${data['text'] ?? ''}"',
      'follow'         => '$from ha empezado a seguirte',
      'follow_request' => '$from quiere seguirte',
      'follow_accept'  => '$from ha aceptado tu solicitud de seguimiento',
      'comment_like'   => '$from le ha dado like a tu comentario',
      'message'        => '$from te ha enviado un mensaje: "${data['text'] ?? ''}"',
      _               => '$from interactuó contigo',
    };
  }
}
