import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_compress_web.dart'
    if (dart.library.io) 'image_compress_native.dart';

class ImageUtils {
  ImageUtils._();

  static Future<String> imageToBase64(XFile xfile) async {
    final compressed = await compressImage(xfile.path);
    final bytes = compressed ?? await xfile.readAsBytes();
    return base64Encode(bytes);
  }

  static Widget imageWidgetFromXFile(XFile xfile, {BoxFit fit = BoxFit.cover}) =>
      _XFileImage(xfile: xfile, fit: fit);

  static Widget imageFromBase64(
    String base64String, {
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    String? cacheKey,
  }) {
    final fallback = placeholder ??
        const ColoredBox(color: Color(0xFFE8F5EE), child: SizedBox.expand());
    if (base64String.isEmpty) return fallback;
    return _CachedBase64Image(
      key: ValueKey(cacheKey ?? base64String.hashCode),
      base64String: base64String,
      fit: fit,
      fallback: fallback,
    );
  }
}

class _CachedBase64Image extends StatefulWidget {
  final String base64String;
  final BoxFit fit;
  final Widget fallback;
  const _CachedBase64Image({
    super.key,
    required this.base64String,
    required this.fit,
    required this.fallback,
  });
  @override
  State<_CachedBase64Image> createState() => _CachedBase64ImageState();
}

class _CachedBase64ImageState extends State<_CachedBase64Image> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    try {
      _bytes = base64Decode(widget.base64String);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) return widget.fallback;
    return Image.memory(_bytes!, fit: widget.fit);
  }
}

class _XFileImage extends StatefulWidget {
  final XFile xfile;
  final BoxFit fit;
  const _XFileImage({required this.xfile, required this.fit});
  @override
  State<_XFileImage> createState() => _XFileImageState();
}

class _XFileImageState extends State<_XFileImage> {
  late final Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.xfile.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (_, snap) {
        if (snap.hasData) {
          return Image.memory(snap.data!, fit: widget.fit, width: double.infinity);
        }
        return const ColoredBox(color: Color(0xFFE8F5EE), child: SizedBox.expand());
      },
    );
  }
}
