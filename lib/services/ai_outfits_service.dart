import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/ai_outfit.dart';
import '../models/wardrobe_item.dart';

class WeatherInfo {
  final double temperatura;
  final String descripcion;
  const WeatherInfo({required this.temperatura, required this.descripcion});
}

/// Códigos de error que devuelve el backend Railway.
class BackendException implements Exception {
  final String code;
  final String message;
  const BackendException({required this.code, required this.message});
  @override
  String toString() => message;
}

class AiOutfitsService {
  static final AiOutfitsService instance = AiOutfitsService._();
  AiOutfitsService._();

  final _db = FirebaseFirestore.instance;

  String get _backendUrl =>
      (dotenv.env['BACKEND_URL'] ?? '').replaceAll(RegExp(r'/$'), '');

  // ── Clima via Open-Meteo ─────────────────────────────────────────────────────
  Future<WeatherInfo> getWeather() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        throw const _LocationDeniedException();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const _LocationDeniedException();
    }

    final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low));

    final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${pos.latitude}&longitude=${pos.longitude}'
        '&current=temperature_2m,weathercode&timezone=auto');

    final resp = await http.get(uri);
    if (resp.statusCode != 200) throw Exception('Error al obtener el clima');

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final temp = (current['temperature_2m'] as num).toDouble();
    final code = current['weathercode'] as int;

    return WeatherInfo(temperatura: temp, descripcion: _codeToEs(code));
  }

  String _codeToEs(int code) {
    if (code == 0) return 'Despejado';
    if (code <= 3) return 'Parcialmente nublado';
    if (code <= 48) return 'Niebla';
    if (code <= 67) return 'Lluvia';
    if (code <= 77) return 'Nieve';
    if (code <= 82) return 'Chubascos';
    return 'Tormenta';
  }

  // ── Gemini via backend Railway (seguro) ──────────────────────────────────────
  Future<String> generateOutfit(
    String occasion,
    String weatherContext,
    List<WardrobeItem> items,
  ) async {
    // Obtener Firebase ID token del usuario autenticado
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) {
      throw const BackendException(
          code: 'unauthenticated',
          message: 'Debes iniciar sesión para generar outfits.');
    }

    final uri = Uri.parse('$_backendUrl/generate-outfit');
    final wardrobeList = items
        .map((item) => {
              'name': item.name,
              'brand': item.brand,
              'category': item.category,
            })
        .toList();

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'occasion': occasion,
        'weatherContext': weatherContext,
        'wardrobeItems': wardrobeList,
      }),
    );

    final json = jsonDecode(resp.body) as Map<String, dynamic>;

    if (resp.statusCode != 200) {
      final code = json['error'] as String? ?? 'internal';
      final message = json['message'] as String? ?? 'Error inesperado.';
      throw BackendException(code: code, message: message);
    }

    return json['suggestion'] as String;
  }

  // ── Firestore ────────────────────────────────────────────────────────────────
  Future<void> saveOutfit(String uid, AiOutfit outfit) async {
    final ref =
        _db.collection('users').doc(uid).collection('ai_outfits').doc();
    await ref.set(outfit.copyWith(id: ref.id).toFirestore());
  }

  Stream<List<AiOutfit>> streamSavedOutfits(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('ai_outfits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AiOutfit.fromFirestore).toList());
  }
}

class _LocationDeniedException implements Exception {
  const _LocationDeniedException();
}

extension _AiOutfitX on AiOutfit {
  AiOutfit copyWith({String? id}) => AiOutfit(
        id: id ?? this.id,
        occasion: occasion,
        weatherContext: weatherContext,
        suggestion: suggestion,
        wardrobeUsed: wardrobeUsed,
        createdAt: createdAt,
      );
}
