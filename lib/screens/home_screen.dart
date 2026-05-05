import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/activity_provider.dart';
import '../services/farm_service.dart';
import '../models/farm_model.dart';
import '../theme/app_theme.dart';
import 'activities_screen.dart';
import 'register_activity_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FarmService _farmService = FarmService();
  SensorDataModel _sensors = SensorDataModel.mock();
  FarmModel? _farm;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Mock farm mientras no hay backend
    final farm = _farmService.getMockFarm();
    setState(() => _farm = farm);

    // Carga actividades
    context.read<ActivityProvider>().loadActivities(farm.id);

    // Carga sensores (retorna mock si el endpoint no existe aún)
    try {
      final sensors = await _farmService.getSensorData(farm.id);
      if (mounted) setState(() => _sensors = sensors);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user       = context.watch<AuthProvider>().user;
    final activities = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      body: Column(
        children: [
          // ── Header verde ──────────────────────────────────
          Container(
            color: AppColors.primaryGreen,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AccountScreen())),
                        ),
                        const Expanded(
                          child: Text('SGA', textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Finca', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(_farm?.name ?? 'Cargando...',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido scrollable ──────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sensores
                    Row(
                      children: [
                        Expanded(child: _SensorCard(
                          icon: Icons.thermostat_outlined, iconColor: AppColors.redIcon,
                          iconBgColor: const Color(0xFFFFF0F0),
                          label: 'Temperatura', value: '${_sensors.temperature.toStringAsFixed(0)}°C',
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _SensorCard(
                          icon: Icons.water_drop_outlined, iconColor: AppColors.blueIcon,
                          iconBgColor: const Color(0xFFE8F4FD),
                          label: 'Humedad', value: '${_sensors.humidity.toStringAsFixed(0)}%',
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tareas
                    const Text('Tareas Principales',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _TaskCard(icon: Icons.water_drop, bgColor: AppColors.blueIcon,
                          label: 'Riego', onTap: () => _goToRegister(context, 'Riego'))),
                      const SizedBox(width: 12),
                      Expanded(child: _TaskCard(icon: Icons.eco, bgColor: AppColors.primaryGreen,
                          label: 'Fertilización', onTap: () => _goToRegister(context, 'Fertilización'))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _TaskCard(icon: Icons.cleaning_services, bgColor: AppColors.orangeIcon,
                          label: 'Fumigación', onTap: () => _goToRegister(context, 'Fumigación'))),
                      const SizedBox(width: 12),
                      Expanded(child: _TaskCard(icon: Icons.pest_control, bgColor: AppColors.redIcon,
                          label: 'Control de Plagas', onTap: () => _goToRegister(context, 'Control de Plagas'))),
                    ]),
                    const SizedBox(height: 24),

                    // Registro
                    const Text('Registro',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ActivitiesScreen())),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EBE5), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.assignment_outlined, color: AppColors.brownIcon, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Text('Actividades Recientes',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Última actividad
                    if (activities.activities.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Última actividad registrada',
                              style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          const SizedBox(height: 2),
                          Text(
                            '${activities.activities.first.type} en ${activities.activities.first.lot}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w500),
                          ),
                        ]),
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
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
        label: const Text('Registrar Actividad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  void _goToRegister(BuildContext context, String type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => RegisterActivityScreen(preselectedType: type)));
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBgColor;
  final String label, value;
  const _SensorCard({required this.icon, required this.iconColor, required this.iconBgColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36,
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 10),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ]),
      );
}

class _TaskCard extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final String label;
  final VoidCallback? onTap;
  const _TaskCard({required this.icon, required this.bgColor, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 48, height: 48,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 28)),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ]),
        ),
      );
}
