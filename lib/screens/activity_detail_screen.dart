import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../theme/app_theme.dart';
import 'register_activity_screen.dart';

class ActivityDetailScreen extends StatelessWidget {
  final ActivityModel activity;
  const ActivityDetailScreen({super.key, required this.activity});

  static Color _iconColor(String type) {
    switch (type) {
      case 'RIEGO':          return AppColors.blueIcon;
      case 'FERTILIZACION':  return AppColors.primaryGreen;
      case 'FUMIGACION':     return AppColors.orangeIcon;
      case 'CONTROL_PLAGAS': return AppColors.redIcon;
      case 'SIEMBRA':        return const Color(0xFF8D6E63);
      case 'COSECHA':        return const Color(0xFFFFB300);
      default:               return AppColors.textMedium;
    }
  }

  static Color _iconBg(String type) {
    switch (type) {
      case 'RIEGO':          return const Color(0xFFE3F2FD);
      case 'FERTILIZACION':  return const Color(0xFFEAF5E8);
      case 'FUMIGACION':     return const Color(0xFFFFF3E0);
      case 'CONTROL_PLAGAS': return const Color(0xFFFFEBEE);
      case 'SIEMBRA':        return const Color(0xFFEFEBE9);
      case 'COSECHA':        return const Color(0xFFFFF8E1);
      default:               return const Color(0xFFF5F5F5);
    }
  }

  static IconData _icon(String type) {
    switch (type) {
      case 'RIEGO':          return Icons.water_drop;
      case 'FERTILIZACION':  return Icons.eco;
      case 'FUMIGACION':     return Icons.cleaning_services;
      case 'CONTROL_PLAGAS': return Icons.pest_control;
      case 'SIEMBRA':        return Icons.grass;
      case 'COSECHA':        return Icons.agriculture;
      default:               return Icons.assignment_outlined;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar actividad',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            '¿Estás seguro de que deseas eliminar esta actividad de ${ActivityType.display(activity.type)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              context.read<ActivityProvider>().deleteActivity(activity.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Actividad eliminada'),
                  backgroundColor: AppColors.redIcon,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.redIcon),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color   = _iconColor(activity.type);
    final bgColor = _iconBg(activity.type);
    final icon    = _icon(activity.type);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'es').format(activity.date);
    final timeStr = DateFormat('hh:mm a').format(activity.date);

    // Filtrar fotos que aún existen en disco
    final validPhotos = activity.photoPaths
        .where((p) => File(p).existsSync())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        title: const Text('Detalle de Actividad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegisterActivityScreen(
                  preselectedType: activity.type,
                  editActivity: activity,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Eliminar',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ActivityType.display(activity.type),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            activity.lotDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Info ────────────────────────────────────────────────────────
            _InfoSection(
              title: 'Información del Registro',
              children: [
                _InfoRow(
                  icon: Icons.straighten,
                  label: 'Cantidad',
                  value: activity.quantityDisplay,
                  valueColor: color,
                ),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Fecha',
                  value: dateStr,
                ),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'Hora',
                  value: timeStr,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Lote',
                  value: activity.lot,
                ),
                if (activity.crop.isNotEmpty)
                  _InfoRow(
                    icon: Icons.eco_outlined,
                    label: 'Cultivo',
                    value: activity.crop,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Fotos ────────────────────────────────────────────────────────
            if (validPhotos.isNotEmpty) ...[
              const Text('Evidencia Fotográfica',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  )),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: validPhotos.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _viewPhoto(context, validPhotos, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(validPhotos[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Notas ────────────────────────────────────────────────────────
            if (activity.notes != null && activity.notes!.isNotEmpty)
              _InfoSection(
                title: 'Notas y Observaciones',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(
                      activity.notes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notes, color: AppColors.textLight, size: 20),
                    SizedBox(width: 10),
                    Text('Sin notas registradas',
                        style: TextStyle(
                            color: AppColors.textLight, fontSize: 13)),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // ── Eliminar ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, color: AppColors.redLogout),
                label: const Text('Eliminar Actividad',
                    style: TextStyle(
                        color: AppColors.redLogout,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.redLogout, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _viewPhoto(BuildContext context, List<String> paths, int initial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullPhotoViewer(paths: paths, initialIndex: initial),
      ),
    );
  }
}

// ── Visor de foto a pantalla completa ─────────────────────────────────────────
class _FullPhotoViewer extends StatefulWidget {
  final List<String> paths;
  final int initialIndex;
  const _FullPhotoViewer({required this.paths, required this.initialIndex});

  @override
  State<_FullPhotoViewer> createState() => _FullPhotoViewerState();
}

class _FullPhotoViewerState extends State<_FullPhotoViewer> {
  late int _current;
  late PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Foto ${_current + 1} de ${widget.paths.length}'),
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.paths.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.file(File(widget.paths[i]), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(children: [
                e.value,
                if (!isLast)
                  const Divider(
                      height: 1, indent: 16, endIndent: 16,
                      color: AppColors.divider),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.textDark,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
