import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _allNotifications   = true;
  bool _activityReminders  = true;
  bool _weatherAlerts      = true;
  bool _weeklyReport       = false;
  bool _plagueAlerts       = true;
  bool _systemUpdates      = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _allNotifications ? AppColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: _allNotifications ? Colors.white : AppColors.textMedium, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Todas las notificaciones',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _allNotifications ? Colors.white : AppColors.textDark,
                            )),
                        Text('Activar o desactivar todo',
                            style: TextStyle(
                              fontSize: 12,
                              color: _allNotifications ? Colors.white70 : AppColors.textLight,
                            )),
                      ],
                    ),
                  ),
                  Switch(
                    value: _allNotifications,
                    onChanged: (v) => setState(() {
                      _allNotifications  = v;
                      _activityReminders = v;
                      _weatherAlerts     = v;
                      _plagueAlerts      = v;
                    }),
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.darkGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Recordatorios',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
            const SizedBox(height: 10),

            _NotifTile(
              icon: Icons.assignment_outlined,
              iconBg: const Color(0xFFEAF5E8),
              iconColor: AppColors.primaryGreen,
              title: 'Recordatorios de actividades',
              subtitle: 'Riego, fertilización y fumigación',
              value: _activityReminders && _allNotifications,
              enabled: _allNotifications,
              onChanged: (v) => setState(() => _activityReminders = v),
            ),
            const SizedBox(height: 10),
            _NotifTile(
              icon: Icons.pest_control,
              iconBg: const Color(0xFFFFEBEE),
              iconColor: AppColors.redIcon,
              title: 'Alertas de plagas',
              subtitle: 'Avisos de control de plagas',
              value: _plagueAlerts && _allNotifications,
              enabled: _allNotifications,
              onChanged: (v) => setState(() => _plagueAlerts = v),
            ),
            const SizedBox(height: 20),

            const Text('Información',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
            const SizedBox(height: 10),

            _NotifTile(
              icon: Icons.cloud_outlined,
              iconBg: const Color(0xFFE3F2FD),
              iconColor: AppColors.blueIcon,
              title: 'Alertas climáticas',
              subtitle: 'Temperatura y humedad fuera de rango',
              value: _weatherAlerts && _allNotifications,
              enabled: _allNotifications,
              onChanged: (v) => setState(() => _weatherAlerts = v),
            ),
            const SizedBox(height: 10),
            _NotifTile(
              icon: Icons.bar_chart,
              iconBg: const Color(0xFFFFF3E0),
              iconColor: AppColors.orangeIcon,
              title: 'Reporte semanal',
              subtitle: 'Resumen de actividades de la semana',
              value: _weeklyReport,
              enabled: _allNotifications,
              onChanged: (v) => setState(() => _weeklyReport = v),
            ),
            const SizedBox(height: 10),
            _NotifTile(
              icon: Icons.system_update_outlined,
              iconBg: const Color(0xFFF5F5F5),
              iconColor: AppColors.textMedium,
              title: 'Actualizaciones del sistema',
              subtitle: 'Nuevas versiones y mejoras',
              value: _systemUpdates,
              enabled: true,
              onChanged: (v) => setState(() => _systemUpdates = v),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Preferencias de notificaciones guardadas'),
                      backgroundColor: AppColors.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Guardar Preferencias'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final bool value, enabled;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle,
    required this.value, required this.enabled, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: enabled ? iconColor : AppColors.textLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: enabled ? AppColors.textDark : AppColors.textLight)),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ])),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.primaryGreen,
          ),
        ]),
      );
}
