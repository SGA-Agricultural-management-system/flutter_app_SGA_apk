import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'notifications_screen.dart';
import 'about_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        title: const Text('Cuenta y Ajustes'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?.name ?? 'Carlos Rodríguez',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(user?.role ?? 'Usuario',
                        style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                  ]),
                ]),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.email_outlined, text: user?.email ?? 'carlos.rodriguez@email.com'),
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.location_on_outlined, text: 'Finca ${user?.farmName ?? "La Esperanza"}'),
              ]),
            ),
            const SizedBox(height: 24),

            const Text('Configuración',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
            const SizedBox(height: 10),

            _SettingsItem(icon: Icons.edit_outlined, iconBgColor: const Color(0xFFEAF5E8),
                iconColor: AppColors.primaryGreen, title: 'Editar Perfil', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            const SizedBox(height: 10),
            _SettingsItem(icon: Icons.lock_outline, iconBgColor: const Color(0xFFFFF3E0),
                iconColor: AppColors.orangeIcon, title: 'Cambiar Contraseña', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
            const SizedBox(height: 10),
            _SettingsItem(icon: Icons.notifications_outlined, iconBgColor: const Color(0xFFE3F2FD),
                iconColor: AppColors.blueIcon, title: 'Notificaciones', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            const SizedBox(height: 10),
            _SettingsItem(icon: Icons.info_outline, iconBgColor: const Color(0xFFF5F5F5),
                iconColor: AppColors.textMedium, title: 'Acerca de la App', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),

            const SizedBox(height: 32),
            const Center(child: Column(children: [
              Text('SGA - Sistema de Gestión Agrícola', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              SizedBox(height: 2),
              Text('Versión 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            ])),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.redLogout),
                label: const Text('Cerrar Sesión',
                    style: TextStyle(color: AppColors.redLogout, fontWeight: FontWeight.w600, fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.redLogout, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, color: AppColors.primaryGreen, size: 18),
          const SizedBox(width: 10),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textMedium))),
        ]),
      );
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor, iconColor;
  final String title;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.iconBgColor, required this.iconColor, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(width: 40, height: 40,
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark))),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 22),
          ]),
        ),
      );
}
