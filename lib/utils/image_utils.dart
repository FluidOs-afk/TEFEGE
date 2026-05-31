import 'dart:convert';
import 'package:flutter/material.dart';
import 'image_utils_native.dart' if (dart.library.html) 'image_utils_web.dart';

class ImageUtils {
  ImageUtils._();

  static Future<String> imageToBase64(dynamic imageFile) async {
    return compressImageToBase64(imageFile);
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
