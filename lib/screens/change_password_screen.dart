import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey           = GlobalKey<FormState>();
  bool _loading            = false;
  bool _obscureCurrent     = true;
  bool _obscureNew         = true;
  bool _obscureConfirm     = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contraseña actualizada correctamente'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blueIcon.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.blueIcon, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'La nueva contraseña debe tener al menos 6 caracteres.',
                        style: TextStyle(fontSize: 13, color: AppColors.blueIcon),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _Label('Contraseña Actual'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                enabled: !_loading,
                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu contraseña actual' : null,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textLight, size: 20),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Nueva Contraseña'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                enabled: !_loading,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textLight, size: 20),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Confirmar Nueva Contraseña'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                enabled: !_loading,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma tu nueva contraseña';
                  if (v != _newController.text) return 'Las contraseñas no coinciden';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textLight, size: 20),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Cambiar Contraseña'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMedium));
}
