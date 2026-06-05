import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors, AppColorsExt, MainScreen;
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import 'legal_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptedTerms = false;

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
    _nombreCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      showOutfySnackBar(
        context,
        'Debes aceptar los Términos y la Política de Privacidad.',
        isError: true,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final result = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      nombre: _nombreCtrl.text.trim(),
      username: _usernameCtrl.text.trim().toLowerCase(),
    );
    if (!mounted) return;
    if (result.success) {
      showOutfySnackBar(context, '¡Bienvenido a OUTFY!');
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const MainScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 450),
        ),
        (_) => false,
      );
    } else {
      showOutfySnackBar(
        context,
        result.errorMessage ?? 'Error al crear la cuenta.',
        isError: true,
      );
    }
  }

  void _openLegal(String title, String assetPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalScreen(title: title, assetPath: assetPath),
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
          // Fondo degradado
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.38,
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
                    top: -60, right: -60,
                    child: _circle(200, Colors.white.withValues(alpha: 0.04)),
                  ),
                  Positioned(
                    bottom: 20, left: -30,
                    child: _circle(140, Colors.white.withValues(alpha: 0.04)),
                  ),
                ],
              ),
            ),
          ),

          // Header: botón atrás + logo
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 30,
            left: 0, right: 0,
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.checkroom_rounded,
                        size: 32, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Crear cuenta',
                  style: GoogleFonts.dmSans(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800, letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Tarjeta del formulario
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _cardSlide,
              child: FadeTransition(
                opacity: _cardOpacity,
                child: Container(
                  height: size.height * 0.70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colBgCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 32, offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre completo
                          AuthTextField(
                            controller: _nombreCtrl,
                            label: 'Nombre completo',
                            hint: 'María García',
                            prefixIcon: Icons.person_outline_rounded,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Introduce tu nombre'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // Username
                          AuthTextField(
                            controller: _usernameCtrl,
                            label: 'Nombre de usuario',
                            hint: 'maria.garcia',
                            prefixIcon: Icons.alternate_email_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Introduce un nombre de usuario';
                              }
                              if (v.contains(' ')) {
                                return 'El usuario no puede tener espacios';
                              }
                              if (v.trim().length < 3) {
                                return 'Mínimo 3 caracteres';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(v.trim())) {
                                return 'Solo letras, números, puntos y guiones bajos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email
                          AuthTextField(
                            controller: _emailCtrl,
                            label: 'Correo electrónico',
                            hint: 'tu@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
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
                          const SizedBox(height: 14),

                          // Contraseña
                          AuthTextField(
                            controller: _passwordCtrl,
                            label: 'Contraseña',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: !_showPassword,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20, color: AppColors.textHint,
                              ),
                              onPressed: () =>
                                  setState(() => _showPassword = !_showPassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Introduce una contraseña';
                              }
                              if (v.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          ListenableBuilder(
                            listenable: _passwordCtrl,
                            builder: (_, _) =>
                                PasswordStrengthBar(password: _passwordCtrl.text),
                          ),
                          const SizedBox(height: 14),

                          // Confirmar contraseña
                          AuthTextField(
                            controller: _confirmPasswordCtrl,
                            label: 'Confirmar contraseña',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: !_showConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20, color: AppColors.textHint,
                              ),
                              onPressed: () => setState(
                                  () => _showConfirmPassword = !_showConfirmPassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirma tu contraseña';
                              }
                              if (v != _passwordCtrl.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Checkbox términos (obligatorio)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _acceptedTerms = !_acceptedTerms),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 22, height: 22,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    color: _acceptedTerms
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _acceptedTerms
                                          ? AppColors.primary
                                          : context.colBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: _acceptedTerms
                                      ? const Icon(Icons.check_rounded,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Wrap(
                                    children: [
                                      Text('Acepto los ',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              color: context.colTextSec)),
                                      GestureDetector(
                                        onTap: () => _openLegal(
                                          'Términos de Uso',
                                          'assets/docs/terminos-de-uso.md',
                                        ),
                                        child: Text(
                                          'Términos de Uso',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.underline,
                                            decorationColor: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(' y la ',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              color: AppColors.textSec)),
                                      GestureDetector(
                                        onTap: () => _openLegal(
                                          'Política de Privacidad',
                                          'assets/docs/politica-de-privacidad.md',
                                        ),
                                        child: Text(
                                          'Política de Privacidad',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.underline,
                                            decorationColor: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(' *',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              color: Colors.red.shade400)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón crear cuenta
                          AuthPrimaryButton(
                            label: 'Crear cuenta',
                            onPressed: _submit,
                            isLoading: isLoading,
                            icon: Icons.check_rounded,
                          ),
                          const SizedBox(height: 20),

                          // Ya tengo cuenta
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13.5, color: context.colTextSec),
                                  children: [
                                    const TextSpan(text: '¿Ya tienes cuenta? '),
                                    TextSpan(
                                      text: 'Inicia sesión',
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
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
