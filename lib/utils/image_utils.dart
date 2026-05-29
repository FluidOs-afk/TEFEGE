import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  ImageUtils._();

  static Future<String> imageToBase64(File imageFile) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) throw Exception('Error al comprimir imagen');
    return base64Encode(compressed);
  }

  static Widget imageFromBase64(
    String base64String, {
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final fallback = placeholder ??
        const ColoredBox(
          color: Color(0xFFE8F5EE),
          child: SizedBox.expand(),
        );
    if (base64String.isEmpty) return fallback;
    try {
      return Image.memory(base64Decode(base64String), fit: fit);
    } catch (_) {
      return fallback;
    }
  }
}
