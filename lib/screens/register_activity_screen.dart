import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/activity_provider.dart';
import '../providers/auth_provider.dart';
import '../models/activity_model.dart';
import '../services/farm_service.dart';
import '../models/farm_model.dart';
import '../theme/app_theme.dart';

class RegisterActivityScreen extends StatefulWidget {
  final String? preselectedType;
  final ActivityModel? editActivity;
  const RegisterActivityScreen({super.key, this.preselectedType, this.editActivity});

  @override
  State<RegisterActivityScreen> createState() => _RegisterActivityScreenState();
}

class _RegisterActivityScreenState extends State<RegisterActivityScreen> {
  final FarmService _farmService = FarmService();
  final _manualLotController = TextEditingController();
  final _quantityController  = TextEditingController();
  final _notesController     = TextEditingController();
  final ImagePicker _picker  = ImagePicker();

  String? _selectedType;
  LotModel? _selectedLot;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<LotModel> _lots = [];
  String _unit = 'litros';

  // ── Fotos ────────────────────────────────────────────────────────────────
  final List<File> _photos = [];
  static const int _maxPhotos = 5;

  static const _units = ['litros', 'kg', 'aplicaciones', '°C', 'unidades', 'otro'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.editActivity?.type ?? widget.preselectedType;
    _lots = _farmService.getMockFarm().lots; // fallback mientras carga
    if (widget.editActivity != null) {
      final a = widget.editActivity!;
      _quantityController.text = a.quantity;
      _unit = a.unit.isNotEmpty ? a.unit : 'litros';
      _notesController.text = a.notes ?? '';
      _selectedDate = a.date;
      _selectedTime = TimeOfDay(hour: a.date.hour, minute: a.date.minute);
      _manualLotController.text = a.lot;
      // Cargar fotos existentes
      for (final path in a.photoPaths) {
        final f = File(path);
        if (f.existsSync()) _photos.add(f);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLots());
  }

  Future<void> _loadLots() async {
    final farmId = context.read<AuthProvider>().user?.farmId;
    if (farmId == null) return;
    try {
      final lots = await _farmService.getLots(farmId);
      if (mounted && lots.isNotEmpty) setState(() => _lots = lots);
    } catch (_) {
      // si falla usa el mock de fallback
    }
  }

  @override
  void dispose() {
    _manualLotController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Cámara / Galería ─────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= _maxPhotos) {
      _showError('Máximo $_maxPhotos fotos permitidas');
      return;
    }
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked != null) {
        setState(() => _photos.add(File(picked.path)));
      }
    } catch (e) {
      _showError('No se pudo acceder a la ${source == ImageSource.camera ? 'cámara' : 'galería'}');
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Agregar foto',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Abrir cámara del dispositivo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text('Seleccionar de galería'),
                subtitle: const Text('Elegir imagen existente'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPhoto(int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PhotoViewScreen(
        photos: _photos,
        initialIndex: index,
        onDelete: (i) {
          Navigator.pop(context);
          _removePhoto(i);
        },
      ),
    ));
  }

  // ── Fecha / Hora ─────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Guardar ──────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_selectedType == null) {
      _showError('Selecciona un tipo de actividad');
      return;
    }
    final lotName = _selectedLot?.name ?? _manualLotController.text.trim();
    if (lotName.isEmpty) {
      _showError('Ingresa el lote o cultivo');
      return;
    }

    final farmId = context.read<AuthProvider>().user?.farmId ?? 'farm1';
    final lotId  = _selectedLot?.id ?? widget.editActivity?.lotId ?? '';

    final isEditing = widget.editActivity != null;
    final activity = ActivityModel(
      id:         widget.editActivity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type:       _selectedType!,
      lot:        lotName,
      lotId:      lotId,
      crop:       _selectedLot?.crop ?? widget.editActivity?.crop ?? '',
      quantity:   _quantityController.text.trim(),
      unit:       _unit,
      date:       _buildDateTime(),
      notes:      _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      farmId:     farmId,
      photoPaths: _photos.map((f) => f.path).toList(),
    );

    final ok = isEditing
        ? await context.read<ActivityProvider>().updateActivity(activity)
        : await context.read<ActivityProvider>().createActivity(activity);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Actividad actualizada' : 'Actividad guardada exitosamente'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      final err = context.read<ActivityProvider>().error ?? 'Error al guardar la actividad';
      _showError(err);
    }
  }

  DateTime _buildDateTime() {
    final now  = DateTime.now();
    final date = _selectedDate ?? now;
    final time = _selectedTime ?? TimeOfDay.now();
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ActivityProvider>().loading;

    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        title: Text(widget.editActivity != null ? 'Editar Actividad' : 'Registrar Actividad'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tipo de Actividad ──────────────────────────────────────────
            _Label('Tipo de Actividad'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Seleccionar tipo...',
                          style: TextStyle(color: AppColors.textLight, fontSize: 14))),
                  icon: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.keyboard_arrow_down, color: AppColors.textMedium)),
                  borderRadius: BorderRadius.circular(12),
                  items: ActivityType.all
                      .map((t) => DropdownMenuItem(
                          value: t,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(ActivityType.display(t)))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Lote o Cultivo ─────────────────────────────────────────────
            _Label('Lote o Cultivo'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showLotPicker(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.inputBorder)),
                child: Row(children: [
                  Expanded(
                      child: Text(
                    _selectedLot?.display ?? 'Seleccionar de la lista...',
                    style: TextStyle(
                        color: _selectedLot != null
                            ? AppColors.textDark
                            : AppColors.textLight,
                        fontSize: 14),
                  )),
                  const Icon(Icons.chevron_right, color: AppColors.textMedium, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _manualLotController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'O escribe manualmente...',
                hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            // ── Cantidad + Unidad ──────────────────────────────────────────
            _Label('Cantidad'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14)),
              )),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.inputBorder)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _unit,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMedium),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v ?? _unit),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Fecha y Hora ───────────────────────────────────────────────
            Row(children: [
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('Fecha'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder)),
                    child: Row(children: [
                      Expanded(
                          child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                            : 'dd/mm/aaaa',
                        style: TextStyle(
                            color: _selectedDate != null
                                ? AppColors.textDark
                                : AppColors.textLight,
                            fontSize: 13),
                      )),
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.textMedium),
                    ]),
                  ),
                ),
              ])),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('Hora'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder)),
                    child: Row(children: [
                      Expanded(
                          child: Text(
                        _selectedTime != null ? _selectedTime!.format(context) : '--:--',
                        style: TextStyle(
                            color: _selectedTime != null
                                ? AppColors.textDark
                                : AppColors.textLight,
                            fontSize: 13),
                      )),
                      const Icon(Icons.access_time, size: 18, color: AppColors.textMedium),
                    ]),
                  ),
                ),
              ])),
            ]),
            const SizedBox(height: 20),

            // ── FOTOS ──────────────────────────────────────────────────────
            _Label('Evidencia Fotográfica'),
            const SizedBox(height: 4),
            Text(
              '${_photos.length}/$_maxPhotos fotos',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(height: 10),

            // Grid de fotos + botón agregar
            _buildPhotoGrid(),

            const SizedBox(height: 20),

            // ── Notas ──────────────────────────────────────────────────────
            _Label('Notas u Observaciones'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Agregar detalles adicionales...',
                hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _save,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(widget.editActivity != null
                        ? 'Actualizar Actividad'
                        : 'Guardar Actividad'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Widget: Grid de fotos ─────────────────────────────────────────────────

  Widget _buildPhotoGrid() {
    final canAddMore = _photos.length < _maxPhotos;

    // Mostramos las fotos existentes + botón de agregar (si hay cupo)
    final items = _photos.length + (canAddMore ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: items,
      itemBuilder: (_, index) {
        // Botón de agregar foto (último slot)
        if (index == _photos.length) {
          return _AddPhotoButton(onTap: _showPhotoOptions);
        }
        // Miniatura de foto
        return _PhotoThumbnail(
          file: _photos[index],
          onTap: () => _viewPhoto(index),
          onDelete: () => _removePhoto(index),
        );
      },
    );
  }

  // ── Lote picker ───────────────────────────────────────────────────────────

  void _showLotPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Seleccionar Lote',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
          const Divider(),
          ..._lots.map((lot) => ListTile(
                title: Text(lot.display),
                trailing: _selectedLot?.id == lot.id
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() => _selectedLot = lot);
                  Navigator.pop(ctx);
                },
              )),
        ]),
      ),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium));
}

/// Botón para agregar nueva foto
class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.4),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 28, color: AppColors.primaryGreen.withOpacity(0.8)),
            const SizedBox(height: 4),
            Text('Agregar',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryGreen.withOpacity(0.8),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// Miniatura de foto con botón eliminar
class _PhotoThumbnail extends StatelessWidget {
  final File file;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _PhotoThumbnail(
      {required this.file, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file, fit: BoxFit.cover),
          ),
          // Botón eliminar
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de visualización de foto a pantalla completa
class _PhotoViewScreen extends StatefulWidget {
  final List<File> photos;
  final int initialIndex;
  final void Function(int index) onDelete;

  const _PhotoViewScreen({
    required this.photos,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  State<_PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<_PhotoViewScreen> {
  late int _current;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Foto ${_current + 1} de ${widget.photos.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
              child: Image.file(widget.photos[i], fit: BoxFit.contain)),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Deseas eliminar esta foto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete(_current);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
