import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart';
import '../theme/app_theme.dart';
import 'register_activity_screen.dart';
import 'activity_detail_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  static const _filters = ['Todas', 'Riego', 'Fertilización', 'Fumigación', 'Plagas'];

  static Color _iconColor(String type) {
    switch (type) {
      case 'Riego':             return AppColors.blueIcon;
      case 'Fertilización':     return AppColors.primaryGreen;
      case 'Fumigación':        return AppColors.orangeIcon;
      case 'Control de Plagas': return AppColors.redIcon;
      default:                  return AppColors.textMedium;
    }
  }

  static Color _iconBg(String type) {
    switch (type) {
      case 'Riego':             return const Color(0xFFE3F2FD);
      case 'Fertilización':     return const Color(0xFFEAF5E8);
      case 'Fumigación':        return const Color(0xFFFFF3E0);
      case 'Control de Plagas': return const Color(0xFFFFEBEE);
      default:                  return const Color(0xFFF5F5F5);
    }
  }

  static IconData _icon(String type) {
    switch (type) {
      case 'Riego':             return Icons.water_drop;
      case 'Fertilización':     return Icons.eco;
      case 'Fumigación':        return Icons.cleaning_services;
      case 'Control de Plagas': return Icons.pest_control;
      case 'Temperatura':       return Icons.thermostat_outlined;
      default:                  return Icons.assignment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        title: const Text('Actividades Recientes'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final selected = prov.activeFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => prov.setFilter(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.divider),
                        ),
                        child: Text(f,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.textMedium)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // List
          Expanded(
            child: prov.loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : prov.activities.isEmpty
                    ? const Center(child: Text('No hay actividades registradas.',
                          style: TextStyle(color: AppColors.textLight)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: prov.activities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final a = prov.activities[i];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityDetailScreen(activity: a),
                              ),
                            ),
                            child: _ActivityCard(
                              activity: a,
                              icon: _icon(a.type),
                              iconColor: _iconColor(a.type),
                              iconBg: _iconBg(a.type),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RegisterActivityScreen())),
        backgroundColor: AppColors.yellowFab,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add, size: 22),
        label: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final IconData icon;
  final Color iconColor, iconBg;

  const _ActivityCard({required this.activity, required this.icon, required this.iconColor, required this.iconBg});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy', 'es').format(activity.date);
    final timeStr = DateFormat('hh:mm a').format(activity.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(width: 48, height: 48,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 26)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(activity.type, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(activity.lotDisplay, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
          const SizedBox(height: 4),
          RichText(text: TextSpan(children: [
            const TextSpan(text: 'Cantidad: ', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
            TextSpan(text: activity.quantityDisplay,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: iconColor)),
          ])),
          const SizedBox(height: 4),
          Text('$dateStr  •  $timeStr', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ])),
      ]),
    );
  }
}
