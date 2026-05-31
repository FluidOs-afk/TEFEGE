import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsService {
  static final NotificationsService instance = NotificationsService._();
  NotificationsService._();

  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> init(GlobalKey<ScaffoldMessengerState> messengerKey) async {
    if (kIsWeb) return;

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

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
}
