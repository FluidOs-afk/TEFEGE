import 'package:flutter/material.dart';

/// Logo de OUTFY — icono minimalista con gradiente.
/// Dibujado 100% con widgets Flutter, sin paquetes externos.
///
/// Uso:
///   OutfyLogo(size: 108)          // cuadrado redondeado con icono
///   OutfyLogo(size: 72)           // versión pequeña (login)
class OutfyLogo extends StatelessWidget {
  final double size;

  const OutfyLogo({super.key, this.size = 108});

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.28;
    final double iconSize = size * 0.46;
    final double dotSize = size * 0.13;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          colors: [Color(0xFF9B59F5), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo decorativo de fondo (efecto glassmorphism sutil)
          Positioned(
            top: -size * 0.15,
            right: -size * 0.1,
            child: Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -size * 0.2,
            left: -size * 0.1,
            child: Container(
              width: size * 0.55,
              height: size * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Letra "O" en negrita + punto acento
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // La "O" principal
                  Text(
                    'O',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: iconSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  // Punto acento lila claro arriba a la derecha
                  Positioned(
                    top: -dotSize * 0.3,
                    right: -dotSize * 0.4,
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD8B4FE),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size * 0.018),
              // Línea decorativa delgada
              Container(
                width: size * 0.42,
                height: size * 0.028,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD8B4FE), Color(0xFF9B59F5)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
