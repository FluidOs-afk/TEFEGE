import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contraseña actualizada correctamente',
            style: GoogleFonts.dmSans(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Cambiar contraseña',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tu contraseña debe tener al menos 8 caracteres.',
                        style: GoogleFonts.dmSans(
                            color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _fieldLabel('Contraseña actual'),
              const SizedBox(height: 8),
              _passwordField(
                controller: _currentCtrl,
                hint: 'Introduce tu contraseña actual',
                obscure: _obscureCurrent,
                onToggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              _fieldLabel('Nueva contraseña'),
              const SizedBox(height: 8),
              _passwordField(
                controller: _newCtrl,
                hint: 'Mínimo 8 caracteres',
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _fieldLabel('Confirmar nueva contraseña'),
              const SizedBox(height: 8),
              _passwordField(
                controller: _confirmCtrl,
                hint: 'Repite la nueva contraseña',
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (v != _newCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Actualizar contraseña',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textSec));
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 14),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textHint,
              size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }
}
