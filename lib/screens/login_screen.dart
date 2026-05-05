import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              Center(
                child: Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.35),
                        blurRadius: 20, offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 20),
              const Text('SGA', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 4),
              const Text('Sistema de Gestión Agrícola', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textMedium)),
              const SizedBox(height: 48),

              const Text('Correo Electrónico',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMedium)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !loading,
                decoration: const InputDecoration(
                  hintText: 'tu@ejemplo.com',
                  hintStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Contraseña',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMedium)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !loading,
                decoration: InputDecoration(
                  hintText: '••••••••',
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
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: loading ? null : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: loading ? null : _login,
                child: loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: loading ? null : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Crear Cuenta'),
              ),
              const SizedBox(height: 48),
              const Text('Santander, Colombia • 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
