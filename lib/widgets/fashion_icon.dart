import 'package:flutter/material.dart';

enum FashionCategory { tops, pants, dress, shoes, accessory, coat }

FashionCategory categoryFromString(String cat) {
  switch (cat) {
    case 'Tops': return FashionCategory.tops;
    case 'Pantalones': return FashionCategory.pants;
    case 'Vestidos': return FashionCategory.dress;
    case 'Zapatos': return FashionCategory.shoes;
    case 'Accesorios': return FashionCategory.accessory;
    case 'Abrigos': return FashionCategory.coat;
    default: return FashionCategory.tops;
  }
}

class FashionIcon extends StatelessWidget {
  final FashionCategory category;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool filled;

  const FashionIcon({
    super.key,
    required this.category,
    required this.color,
    this.size = 40,
    this.strokeWidth = 2.0,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FashionPainter(
        category: category,
        color: color,
        strokeWidth: strokeWidth,
        filled: filled,
      ),
    );
  }
}

class _FashionPainter extends CustomPainter {
  final FashionCategory category;
  final Color color;
  final double strokeWidth;
  final bool filled;

  _FashionPainter({
    required this.category,
    required this.color,
    required this.strokeWidth,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final path = _buildPath(size);
    if (filled) canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  Path _buildPath(Size s) {
    switch (category) {
      case FashionCategory.tops:    return _shirt(s);
      case FashionCategory.pants:   return _pants(s);
      case FashionCategory.dress:   return _dress(s);
      case FashionCategory.shoes:   return _shoe(s);
      case FashionCategory.accessory: return _bag(s);
      case FashionCategory.coat:    return _coat(s);
    }
  }

  // ── Camiseta / Top ────────────────────────────────────────────────────────
  Path _shirt(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();

    p.moveTo(w * 0.38, h * 0.13);
    p.quadraticBezierTo(w * 0.50, h * 0.24, w * 0.62, h * 0.13);
    p.lineTo(w * 0.82, h * 0.17);
    p.lineTo(w * 0.94, h * 0.37);
    p.lineTo(w * 0.72, h * 0.39);
    p.lineTo(w * 0.72, h * 0.88);
    p.lineTo(w * 0.28, h * 0.88);
    p.lineTo(w * 0.28, h * 0.39);
    p.lineTo(w * 0.06, h * 0.37);
    p.lineTo(w * 0.18, h * 0.17);
    p.close();

    return p;
  }

  // ── Pantalón ──────────────────────────────────────────────────────────────
  Path _pants(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();

    // Cinturilla
    p.addRRect(RRect.fromLTRBR(
      w * 0.18, h * 0.08, w * 0.82, h * 0.22,
      const Radius.circular(4),
    ));

    // Pierna izquierda
    p.moveTo(w * 0.20, h * 0.22);
    p.lineTo(w * 0.16, h * 0.92);
    p.lineTo(w * 0.48, h * 0.92);
    p.lineTo(w * 0.50, h * 0.22);
    p.close();

    // Pierna derecha
    p.moveTo(w * 0.50, h * 0.22);
    p.lineTo(w * 0.52, h * 0.92);
    p.lineTo(w * 0.84, h * 0.92);
    p.lineTo(w * 0.80, h * 0.22);
    p.close();

    // Línea de cinturón
    p.moveTo(w * 0.30, h * 0.13);
    p.lineTo(w * 0.70, h * 0.13);

    // Hebilla
    p.addRRect(RRect.fromLTRBR(
      w * 0.44, h * 0.10, w * 0.56, h * 0.18,
      const Radius.circular(2),
    ));

    return p;
  }

  // ── Vestido ───────────────────────────────────────────────────────────────
  Path _dress(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();

    // Cuerpo superior (escote + tirantes)
    p.moveTo(w * 0.32, h * 0.10);
    p.quadraticBezierTo(w * 0.50, h * 0.22, w * 0.68, h * 0.10);
    p.lineTo(w * 0.74, h * 0.14);
    p.lineTo(w * 0.68, h * 0.40);

    // Falda
    p.lineTo(w * 0.92, h * 0.92);
    p.lineTo(w * 0.08, h * 0.92);
    p.lineTo(w * 0.32, h * 0.40);
    p.lineTo(w * 0.26, h * 0.14);
    p.close();

    // Cintura
    p.moveTo(w * 0.32, h * 0.40);
    p.lineTo(w * 0.68, h * 0.40);

    // Detalle costura lateral
    p.moveTo(w * 0.50, h * 0.55);
    p.lineTo(w * 0.50, h * 0.82);

    return p;
  }

  // ── Zapato ────────────────────────────────────────────────────────────────
  Path _shoe(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();

    // Suela
    p.moveTo(w * 0.08, h * 0.75);
    p.cubicTo(w * 0.06, h * 0.56, w * 0.12, h * 0.42, w * 0.24, h * 0.40);
    p.cubicTo(w * 0.30, h * 0.38, w * 0.36, h * 0.36, w * 0.44, h * 0.38);
    p.cubicTo(w * 0.60, h * 0.40, w * 0.76, h * 0.44, w * 0.92, h * 0.56);
    p.cubicTo(w * 0.98, h * 0.62, w * 0.98, h * 0.72, w * 0.90, h * 0.76);
    p.cubicTo(w * 0.66, h * 0.82, w * 0.32, h * 0.82, w * 0.08, h * 0.75);
    p.close();

    // Cordones
    p.moveTo(w * 0.30, h * 0.55);
    p.lineTo(w * 0.64, h * 0.52);
    p.moveTo(w * 0.32, h * 0.46);
    p.lineTo(w * 0.62, h * 0.44);

    // Tacón
    p.moveTo(w * 0.08, h * 0.75);
    p.lineTo(w * 0.08, h * 0.88);
    p.lineTo(w * 0.22, h * 0.88);
    p.lineTo(w * 0.22, h * 0.76);

    return p;
  }

  // ── Bolso / Accesorio ─────────────────────────────────────────────────────
  Path _bag(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();

    // Cuerpo del bolso
    p.addRRect(RRect.fromLTRBR(
      w * 0.12, h * 0.34, w * 0.88, h * 0.90,
      const Radius.circular(8),
    ));

    // Asa izquierda
    p.moveTo(w * 0.28, h * 0.34);
    p.cubicTo(w * 0.26, h * 0.14, w * 0.44, h * 0.08, w * 0.50, h * 0.10);

    // Asa derecha
    p.moveTo(w * 0.50, h * 0.10);
    p.cubicTo(w * 0.56, h * 0.08, w * 0.74, h * 0.14, w * 0.72, h * 0.34);

    // Cierre central
    p.addOval(Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.59),
      width: w * 0.14,
      height: h * 0.09,
    ));

    // Línea decorativa horizontal
    p.moveTo(w * 0.18, h * 0.68);
    p.lineTo(w * 0.82, h * 0.68);

    return p;
  }

  // ── Abrigo ────────────────────────────────────────────────────────────────
  Path _coat(Size s) {
    final w = s.width;
    final h = s.height;
    final p = Path();

    // Silueta exterior
    p.moveTo(w * 0.40, h * 0.08);
    p.lineTo(w * 0.14, h * 0.16);
    p.lineTo(w * 0.04, h * 0.38);
    p.lineTo(w * 0.22, h * 0.40);
    p.lineTo(w * 0.22, h * 0.92);
    p.lineTo(w * 0.78, h * 0.92);
    p.lineTo(w * 0.78, h * 0.40);
    p.lineTo(w * 0.96, h * 0.38);
    p.lineTo(w * 0.86, h * 0.16);
    p.lineTo(w * 0.60, h * 0.08);

    // Solapa derecha
    p.lineTo(w * 0.56, h * 0.36);
    p.lineTo(w * 0.50, h * 0.24);

    // Solapa izquierda
    p.lineTo(w * 0.44, h * 0.36);
    p.lineTo(w * 0.40, h * 0.08);
    p.close();

    // Línea central
    p.moveTo(w * 0.50, h * 0.36);
    p.lineTo(w * 0.50, h * 0.92);

    // Botones
    for (final y in [0.48, 0.60, 0.72, 0.84]) {
      p.addOval(Rect.fromCenter(
        center: Offset(w * 0.50, h * y),
        width: w * 0.05,
        height: h * 0.032,
      ));
    }

    return p;
  }

  @override
  bool shouldRepaint(_FashionPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth || old.filled != filled;
}
