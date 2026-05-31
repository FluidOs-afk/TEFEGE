import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<String> compressImageToBase64(dynamic imageFile) async {
  final file = imageFile as File;
  final compressed = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 800,
    minHeight: 800,
    quality: 70,
    format: CompressFormat.jpeg,
  );
  if (compressed == null) throw Exception('Error al comprimir imagen');
  return base64Encode(compressed);
}
