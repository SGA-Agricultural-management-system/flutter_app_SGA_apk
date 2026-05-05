import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _farmController;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController  = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _farmController  = TextEditingController(text: user?.farmName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _farmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    // Actualiza el usuario en el provider con los nuevos datos
    final auth = context.read<AuthProvider>();
    final updated = auth.user?.copyWith(
      name:     _nameController.text.trim(),
      email:    _emailController.text.trim(),
      farmName: _farmController.text.trim(),
    );
    if (updated != null) auth.updateUser(updated);

    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
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
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 48),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.yellowFab,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Nombre
              _Label('Nombre Completo'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !_loading,
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
                decoration: const InputDecoration(
                  hintText: 'Tu nombre completo',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textLight, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              _Label('Correo Electrónico'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu correo' : null,
                decoration: const InputDecoration(
                  hintText: 'tu@ejemplo.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Finca
              _Label('Nombre de la Finca'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _farmController,
                enabled: !_loading,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Ej: La Esperanza',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textLight, size: 20),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar Cambios'),
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
