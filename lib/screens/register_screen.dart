import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart' show AppColors, MainScreen;
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import 'legal_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentStep = 0;
  static const _totalSteps = 4;
  static const _stepLabels = ['Cuenta', 'Sobre ti', 'Tu estilo', 'Finalizar'];

  // ─── Controladores Step 1 ─────────────────────────────────────────────────
  final _formKey1 = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool? _usernameAvailable;
  Timer? _usernameDebounce;

  // ─── Datos Step 2 ─────────────────────────────────────────────────────────
  final _formKey2 = GlobalKey<FormState>();
  DateTime? _birthDate;
  String? _gender;
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // ─── Datos Step 3 ─────────────────────────────────────────────────────────
  final _formKey3 = GlobalKey<FormState>();
  String? _profileImagePath;
  final _bioCtrl = TextEditingController();
  final Set<String> _selectedStyles = {};
  String? _topSize;
  String? _bottomSize;
  String? _shoeSize;

  static const _styleOptions = [
    'Casual', 'Formal', 'Deportivo', 'Elegante', 'Urbano',
    'Bohemio', 'Minimalista', 'Vintage', 'Streetwear', 'Chic',
  ];
  static const _topSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _bottomSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _shoeSizes = ['35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45'];

  // ─── Datos Step 4 ─────────────────────────────────────────────────────────
  final _formKey4 = GlobalKey<FormState>();
  final _instagramCtrl = TextEditingController();
  final _tiktokCtrl = TextEditingController();
  final Set<String> _selectedPreferences = {};
  bool _acceptedTerms = false;
  bool _acceptedNewsletter = false;

  static const _preferenceOptions = [
    'Moda Sostenible', 'Lujo', 'Fast Fashion', 'Vintage',
    'Artesanal', 'Premium', 'Independiente', 'Deportiva',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _usernameDebounce?.cancel();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    _instagramCtrl.dispose();
    _tiktokCtrl.dispose();
    super.dispose();
  }

  // ─── Navegación entre pasos ───────────────────────────────────────────────
  Future<void> _nextStep() async {
    final formKeys = [_formKey1, _formKey2, _formKey3, _formKey4];
    if (!formKeys[_currentStep].currentState!.validate()) return;

    if (_currentStep == 0) {
      if (_usernameAvailable == false) {
        showOutfySnackBar(context, 'El nombre de usuario ya está en uso.', isError: true);
        return;
      }
    }
    if (_currentStep == 1 && _birthDate == null) {
      showOutfySnackBar(context, 'Selecciona tu fecha de nacimiento.', isError: true);
      return;
    }
    if (_currentStep == 1 && _gender == null) {
      showOutfySnackBar(context, 'Selecciona tu género.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _currentStep++);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prevStep() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _currentStep--);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _submit() async {
    if (!_formKey4.currentState!.validate()) return;
    if (!_acceptedTerms) {
      showOutfySnackBar(
        context,
        'Debes aceptar los términos y condiciones.',
        isError: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final user = UserModel(
      id: UserModel.generateId(),
      email: _emailCtrl.text.trim(),
      username: _usernameCtrl.text.trim().toLowerCase(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      profileImagePath: _profileImagePath,
      birthDate: _birthDate,
      gender: _gender,
      country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      favoriteStyles: _selectedStyles.toList(),
      topSize: _topSize,
      bottomSize: _bottomSize,
      shoeSize: _shoeSize,
      instagramHandle: _instagramCtrl.text.trim().isEmpty ? null : _instagramCtrl.text.trim(),
      tiktokHandle: _tiktokCtrl.text.trim().isEmpty ? null : _tiktokCtrl.text.trim(),
      fashionPreferences: _selectedPreferences.toList(),
      createdAt: DateTime.now(),
      acceptedTerms: _acceptedTerms,
      acceptedNewsletter: _acceptedNewsletter,
    );

    final auth = context.read<AuthProvider>();
    final result = await auth.register(user, _passwordCtrl.text);

    if (!mounted) return;

    if (result.success) {
      showOutfySnackBar(context, '¡Cuenta creada! Bienvenido a OUTFY 🎉');
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (ctx, anim, _) => const MainScreen(),
          transitionsBuilder: (ctx, anim, _, child) =>
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

  // ─── Username availability check ─────────────────────────────────────────
  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _usernameAvailable = null);
      return;
    }
    _usernameDebounce = Timer(const Duration(milliseconds: 600), () async {
      final auth = context.read<AuthProvider>();
      final available = await auth.isUsernameAvailable(value.trim());
      if (mounted) setState(() => _usernameAvailable = available);
    });
  }

  // ─── Abrir documento legal ────────────────────────────────────────────────
  void _openLegal(String title, String assetPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalScreen(title: title, assetPath: assetPath),
      ),
    );
  }

  // ─── Selección de foto de perfil ─────────────────────────────────────────
  Future<void> _pickImage() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file != null && mounted) {
      setState(() => _profileImagePath = file.path);
    }
  }

  Future<ImageSource?> _showImageSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Foto de perfil',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _imageSourceOption(
                      ctx,
                      icon: Icons.camera_alt_outlined,
                      label: 'Cámara',
                      source: ImageSource.camera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _imageSourceOption(
                      ctx,
                      icon: Icons.photo_library_outlined,
                      label: 'Galería',
                      source: ImageSource.gallery,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceOption(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(ctx).pop(source),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DatePicker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      helpText: 'Fecha de nacimiento',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            _currentStep == 0 ? Icons.close_rounded : Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: _prevStep,
        ),
        title: Text(
          'Crear cuenta',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // ─── Paso indicador ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: StepProgressIndicator(
              totalSteps: _totalSteps,
              currentStep: _currentStep,
              labels: _stepLabels,
            ),
          ),

          // ─── Contenido del paso ──────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),

          // ─── Botones de navegación ───────────────────────────────────
          _buildBottomNav(isLoading),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isLoading) {
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(
              onPressed: isLoading ? null : _prevStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Atrás',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: AuthPrimaryButton(
              label: isLast ? 'Crear cuenta' : 'Continuar',
              onPressed: isLast ? _submit : _nextStep,
              isLoading: isLoading,
              icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1 — Datos de cuenta
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepHeader('Tu cuenta', 'Crea tus credenciales de acceso'),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _firstNameCtrl,
                    label: 'Nombre *',
                    hint: 'María',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AuthTextField(
                    controller: _lastNameCtrl,
                    label: 'Apellidos *',
                    hint: 'García',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Username con comprobación de disponibilidad
            AuthTextField(
              controller: _usernameCtrl,
              label: 'Nombre de usuario *',
              hint: 'maria.garcia',
              prefixIcon: Icons.alternate_email_rounded,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              onChanged: _onUsernameChanged,
              suffixIcon: _buildUsernameStatus(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obligatorio';
                if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(v.trim())) {
                  return 'Solo letras, números, puntos y guiones bajos';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            if (_usernameAvailable == true)
              _statusText('Usuario disponible', Icons.check_circle_outline_rounded, AppColors.primary)
            else if (_usernameAvailable == false)
              _statusText('Usuario no disponible', Icons.cancel_outlined, Colors.red.shade400),
            const SizedBox(height: 16),

            AuthTextField(
              controller: _emailCtrl,
              label: 'Correo electrónico *',
              hint: 'tu@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obligatorio';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'Correo electrónico no válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            AuthTextField(
              controller: _passwordCtrl,
              label: 'Contraseña *',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !_showPassword,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textHint,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obligatorio';
                if (v.length < 8) return 'Mínimo 8 caracteres';
                return null;
              },
            ),
            ListenableBuilder(
              listenable: _passwordCtrl,
              builder: (ctx, _) =>
                  PasswordStrengthBar(password: _passwordCtrl.text),
            ),
            const SizedBox(height: 16),

            AuthTextField(
              controller: _confirmPasswordCtrl,
              label: 'Confirmar contraseña *',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !_showConfirmPassword,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textHint,
                ),
                onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obligatorio';
                if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildUsernameStatus() {
    if (_usernameAvailable == null) return null;
    return Icon(
      _usernameAvailable! ? Icons.check_circle_rounded : Icons.cancel_rounded,
      size: 20,
      color: _usernameAvailable! ? AppColors.primary : Colors.red.shade400,
    );
  }

  Widget _statusText(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 2 — Información personal
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepHeader('Sobre ti', 'Cuéntanos un poco más'),
            const SizedBox(height: 24),

            // Fecha de nacimiento
            _sectionLabel('Fecha de nacimiento *'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _birthDate == null ? AppColors.border : AppColors.primary,
                    width: _birthDate == null ? 1 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: _birthDate == null ? AppColors.textHint : AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _birthDate == null
                            ? 'Seleccionar fecha'
                            : DateFormat('d MMMM yyyy', 'es').format(_birthDate!),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _birthDate == null
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                          fontWeight: _birthDate == null
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Género
            _sectionLabel('Género *'),
            const SizedBox(height: 10),
            GenderSelector(
              selected: _gender,
              onSelect: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 24),

            // Ubicación
            _sectionLabel('Ubicación'),
            const SizedBox(height: 8),
            AuthTextField(
              controller: _countryCtrl,
              label: 'País',
              hint: 'España',
              prefixIcon: Icons.public_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (_) => null,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _cityCtrl,
              label: 'Ciudad',
              hint: 'Madrid',
              prefixIcon: Icons.location_city_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              validator: (_) => null,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 3 — Estilo personal
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepHeader('Tu estilo', 'Personaliza tu perfil de moda'),
            const SizedBox(height: 24),

            // Foto de perfil
            _sectionLabel('Foto de perfil'),
            const SizedBox(height: 12),
            Center(child: _buildAvatarPicker()),
            const SizedBox(height: 24),

            // Biografía
            _sectionLabel('Biografía'),
            const SizedBox(height: 8),
            AuthTextField(
              controller: _bioCtrl,
              label: 'Bio',
              hint: 'Cuéntanos sobre ti y tu estilo...',
              prefixIcon: Icons.edit_outlined,
              maxLines: 3,
              maxLength: 160,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              validator: (_) => null,
            ),
            const SizedBox(height: 24),

            // Estilos favoritos
            _sectionLabel('Estilos favoritos'),
            const SizedBox(height: 4),
            Text(
              'Selecciona los que más te representen',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 10),
            ChipSelector(
              options: _styleOptions,
              selected: _selectedStyles,
              onToggle: (s) => setState(() {
                if (_selectedStyles.contains(s)) {
                  _selectedStyles.remove(s);
                } else {
                  _selectedStyles.add(s);
                }
              }),
            ),
            const SizedBox(height: 24),

            // Tallas
            _sectionLabel('Tallas habituales'),
            const SizedBox(height: 16),
            _subsectionLabel('Parte superior'),
            const SizedBox(height: 8),
            SizeSelector(
              sizes: _topSizes,
              selected: _topSize,
              onSelect: (s) => setState(() => _topSize = s),
            ),
            const SizedBox(height: 16),
            _subsectionLabel('Parte inferior'),
            const SizedBox(height: 8),
            SizeSelector(
              sizes: _bottomSizes,
              selected: _bottomSize,
              onSelect: (s) => setState(() => _bottomSize = s),
            ),
            const SizedBox(height: 16),
            _subsectionLabel('Calzado'),
            const SizedBox(height: 8),
            SizeSelector(
              sizes: _shoeSizes,
              selected: _shoeSize,
              onSelect: (s) => setState(() => _shoeSize = s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBg,
              border: Border.all(
                color: _profileImagePath != null
                    ? AppColors.primary
                    : AppColors.border,
                width: _profileImagePath != null ? 3 : 1.5,
              ),
            ),
            child: _profileImagePath != null
                ? ClipOval(
                    child: Image.file(
                      File(_profileImagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: AppColors.textHint,
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 4 — Finalizar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Form(
        key: _formKey4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepHeader('Casi listo', 'Un último paso para completar tu perfil'),
            const SizedBox(height: 24),

            // Redes sociales
            _sectionLabel('Redes sociales (opcional)'),
            const SizedBox(height: 8),
            AuthTextField(
              controller: _instagramCtrl,
              label: 'Instagram',
              hint: '@tu_usuario',
              prefixIcon: Icons.photo_camera_outlined,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              validator: (_) => null,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _tiktokCtrl,
              label: 'TikTok',
              hint: '@tu_usuario',
              prefixIcon: Icons.video_library_outlined,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              validator: (_) => null,
            ),
            const SizedBox(height: 24),

            // Preferencias de moda
            _sectionLabel('Preferencias de moda'),
            const SizedBox(height: 4),
            Text(
              'Selecciona lo que define tu consumo',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 10),
            ChipSelector(
              options: _preferenceOptions,
              selected: _selectedPreferences,
              onToggle: (p) => setState(() {
                if (_selectedPreferences.contains(p)) {
                  _selectedPreferences.remove(p);
                } else {
                  _selectedPreferences.add(p);
                }
              }),
            ),
            const SizedBox(height: 28),

            // Términos y condiciones
            _buildCheckRow(
              value: _acceptedTerms,
              onChanged: (v) => setState(() => _acceptedTerms = v),
              child: Wrap(
                children: [
                  Text('Acepto los ',
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.textSec)),
                  GestureDetector(
                    onTap: () => _openLegal(
                      'Términos y Condiciones',
                      'assets/docs/terminos-de-uso.md',
                    ),
                    child: Text(
                      'Términos y Condiciones',
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
                          fontSize: 13, color: AppColors.textSec)),
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
                          fontSize: 13, color: AppColors.textSec)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildCheckRow(
              value: _acceptedNewsletter,
              onChanged: (v) => setState(() => _acceptedNewsletter = v),
              child: Text(
                'Quiero recibir novedades y tendencias de OUTFY',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.textSec),
              ),
            ),
            const SizedBox(height: 20),

            // Resumen de la cuenta que se va a crear
            _buildAccountSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow({
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildAccountSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Resumen de tu cuenta',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _summaryRow(
              Icons.person_outline_rounded,
              '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim()),
          _summaryRow(Icons.alternate_email_rounded,
              '@${_usernameCtrl.text.trim().toLowerCase()}'),
          _summaryRow(Icons.email_outlined, _emailCtrl.text.trim()),
          if (_countryCtrl.text.isNotEmpty || _cityCtrl.text.isNotEmpty)
            _summaryRow(
              Icons.location_on_outlined,
              [_cityCtrl.text.trim(), _countryCtrl.text.trim()]
                  .where((s) => s.isNotEmpty)
                  .join(', '),
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSec),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSec),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers de UI ────────────────────────────────────────────────────────
  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSec),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _subsectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSec,
      ),
    );
  }
}
