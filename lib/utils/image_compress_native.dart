import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List?> compressImage(String path) async {
  return FlutterImageCompress.compressWithFile(
    path,
    minWidth: 800,
    minHeight: 800,
    quality: 70,
    format: CompressFormat.jpeg,
  );
}
