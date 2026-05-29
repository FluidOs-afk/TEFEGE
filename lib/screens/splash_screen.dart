import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors, MainScreen;
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _subtitleCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _subtitleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 120));
    _subtitleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1100));
    // Esperar a que Firebase Auth resuelva el estado de sesión
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    while (!auth.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final target = auth.isLoggedIn ? const MainScreen() : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => target,
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F4229),
              AppColors.primary,
              AppColors.primaryMed,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Círculos decorativos de fondo
            Positioned(
              top: -80,
              right: -80,
              child: _decorCircle(220, Colors.white.withValues(alpha: 0.04)),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: _decorCircle(300, Colors.white.withValues(alpha: 0.03)),
            ),
            Positioned(
              top: 160,
              left: -40,
              child: _decorCircle(140, Colors.white.withValues(alpha: 0.03)),
            ),

            // Contenido central
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, _) => Opacity(
                      opacity: _logoOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _buildLogoIcon(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Nombre OUTFY
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, _) => Opacity(
                      opacity: _textOpacity.value.clamp(0.0, 1.0),
                      child: SlideTransition(
                        position: _textSlide,
                        child: Text(
                          'OUTFY',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 10,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtítulo
                  AnimatedBuilder(
                    animation: _subtitleCtrl,
                    builder: (_, _) => Opacity(
                      opacity: _subtitleOpacity.value.clamp(0.0, 1.0),
                      child: Text(
                        'Tu armario, tu identidad',
                        style: GoogleFonts.dmSans(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Indicador de carga en la parte inferior
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _subtitleCtrl,
                builder: (_, _) => Opacity(
                  opacity: _subtitleOpacity.value.clamp(0.0, 1.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoIcon() {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 54,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
