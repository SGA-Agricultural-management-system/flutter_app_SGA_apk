import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        title: const Text('Acerca de la App'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo + nombre
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 16, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 16),
                const Text('SGA',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Sistema de Gestión Agrícola',
                    style: TextStyle(fontSize: 14, color: AppColors.textMedium)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBg,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text('Versión 1.0.0',
                      style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Descripción
            _Section(
              title: 'Descripción',
              content: 'SGA es una aplicación móvil diseñada para facilitar la gestión de actividades agrícolas. '
                  'Permite registrar y hacer seguimiento de riegos, fertilizaciones, fumigaciones, '
                  'control de plagas y más, todo desde tu celular.',
            ),
            const SizedBox(height: 16),

            // Características
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Características',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 14),
                  _Feature(icon: Icons.assignment_outlined, color: AppColors.primaryGreen, text: 'Registro de actividades agrícolas'),
                  _Feature(icon: Icons.thermostat_outlined, color: AppColors.redIcon, text: 'Monitoreo de temperatura y humedad'),
                  _Feature(icon: Icons.history, color: AppColors.blueIcon, text: 'Historial detallado de actividades'),
                  _Feature(icon: Icons.filter_list, color: AppColors.orangeIcon, text: 'Filtros por tipo de actividad'),
                  _Feature(icon: Icons.cloud_sync_outlined, color: AppColors.brownIcon, text: 'Sincronización con backend en la nube'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info técnica
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                _InfoTile(label: 'Versión', value: '1.0.0'),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                _InfoTile(label: 'Desarrollado con', value: 'Flutter 3.x'),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                _InfoTile(label: 'Plataforma', value: 'Android / iOS / Web'),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                _InfoTile(label: 'Región', value: 'Santander, Colombia'),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                _InfoTile(label: 'Año', value: '2026'),
              ]),
            ),
            const SizedBox(height: 32),

            const Text('Santander, Colombia • 2026',
                style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5)),
        ]),
      );
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Feature({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
        ]),
      );
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMedium))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ]),
      );
}
