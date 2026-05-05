import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController      = TextEditingController();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _confirmController   = TextEditingController();
  final _farmController      = TextEditingController();

  bool _obscurePassword      = true;
  bool _obscureConfirm       = true;
  final _formKey             = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _farmController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre completo';
    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Correo no válido';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      farmName: _farmController.text.trim().isEmpty
          ? null
          : _farmController.text.trim(),
    );

    if (ok && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header verde
            Container(
              color: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Crear Cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Formulario
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ícono pequeño arriba
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 36),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bienvenido al SGA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Completa los datos para registrarte',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 32),

                      // ── Nombre completo ──────────────────────
                      _FieldLabel('Nombre Completo'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        enabled: !loading,
                        textCapitalization: TextCapitalization.words,
                        validator: _validateName,
                        decoration: const InputDecoration(
                          hintText: 'Carlos Rodríguez',
                          hintStyle: TextStyle(color: AppColors.textLight),
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.textLight, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Correo ───────────────────────────────
                      _FieldLabel('Correo Electrónico'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        enabled: !loading,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          hintText: 'tu@ejemplo.com',
                          hintStyle: TextStyle(color: AppColors.textLight),
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Contraseña ───────────────────────────
                      _FieldLabel('Contraseña'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !loading,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          hintText: 'Mínimo 6 caracteres',
                          hintStyle: const TextStyle(color: AppColors.textLight),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textLight, size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Confirmar contraseña ─────────────────
                      _FieldLabel('Confirmar Contraseña'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmController,
                        enabled: !loading,
                        obscureText: _obscureConfirm,
                        validator: _validateConfirm,
                        decoration: InputDecoration(
                          hintText: 'Repite tu contraseña',
                          hintStyle: const TextStyle(color: AppColors.textLight),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textLight, size: 20,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Nombre de la finca (opcional) ────────
                      _FieldLabel('Nombre de la Finca (opcional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _farmController,
                        enabled: !loading,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Ej: La Esperanza',
                          hintStyle: TextStyle(color: AppColors.textLight),
                          prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textLight, size: 20),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Botón Registrarse ────────────────────
                      ElevatedButton(
                        onPressed: loading ? null : _register,
                        child: loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Crear Cuenta'),
                      ),
                      const SizedBox(height: 16),

                      // ── Ya tengo cuenta ──────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                          ),
                          TextButton(
                            onPressed: loading ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
        ),
      );
}
