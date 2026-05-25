import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors, MainScreen;
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _showPassword = false;
  bool _rememberMe = true;

  late final AnimationController _entryCtrl;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final result = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (result.success) {
      showOutfySnackBar(context, '¡Bienvenido de nuevo!');
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const MainScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
    } else {
      showOutfySnackBar(
        context,
        result.errorMessage ?? 'Error al iniciar sesión.',
        isError: true,
      );
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const RegisterScreen(),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ─── Fondo degradado superior ─────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F4229), AppColors.primary, AppColors.primaryMed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -60,
                    right: -60,
                    child: _circle(200, Colors.white.withValues(alpha: 0.04)),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -30,
                    child: _circle(140, Colors.white.withValues(alpha: 0.04)),
                  ),
                ],
              ),
            ),
          ),

          // ─── Logo y título en el header ───────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 36,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'OUTFY',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu armario, tu identidad',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ─── Tarjeta del formulario ───────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _cardSlide,
              child: FadeTransition(
                opacity: _cardOpacity,
                child: Container(
                  height: size.height * 0.65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 32,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido de nuevo',
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inicia sesión para ver tu armario',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textSec,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Email
                          AuthTextField(
                            controller: _emailCtrl,
                            label: 'Correo electrónico',
                            hint: 'tu@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_passwordFocus),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Introduce tu correo electrónico';
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(v.trim())) {
                                return 'Correo electrónico no válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          AuthTextField(
                            controller: _passwordCtrl,
                            label: 'Contraseña',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: !_showPassword,
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.textHint,
                              ),
                              onPressed: () =>
                                  setState(() => _showPassword = !_showPassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Introduce tu contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Recordarme + Olvidaste contraseña
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: _rememberMe
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 2,
                                        ),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(Icons.check_rounded,
                                              size: 13, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Recordarme',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: AppColors.textSec,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => showOutfySnackBar(
                                  context,
                                  'Recuperación disponible próximamente',
                                  icon: Icons.info_outline_rounded,
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Botón iniciar sesión
                          AuthPrimaryButton(
                            label: 'Iniciar sesión',
                            onPressed: _login,
                            isLoading: isLoading,
                            icon: Icons.login_rounded,
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: AppColors.border)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'o',
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textHint,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: AppColors.border)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Ir a registro
                          Center(
                            child: GestureDetector(
                              onTap: _goToRegister,
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.5,
                                    color: AppColors.textSec,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: '¿No tienes cuenta? '),
                                    TextSpan(
                                      text: 'Regístrate',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13.5,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
