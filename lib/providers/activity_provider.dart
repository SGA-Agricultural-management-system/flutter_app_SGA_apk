import 'package:flutter/material.dart';
import '../models/activity_model.dart';

class ActivityProvider extends ChangeNotifier {
  List<ActivityModel> _activities = _initialActivities();
  bool    _loading = false;
  String? _error;
  String  _activeFilter = 'Todas';

  List<ActivityModel> get activities => _activeFilter == 'Todas'
      ? _activities
      : _activities.where((a) => a.type == _activeFilter).toList();

  bool    get loading      => _loading;
  String? get error        => _error;
  String  get activeFilter => _activeFilter;

  Future<void> loadActivities(String farmId) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 400));
    // ya están cargadas por defecto
    _setLoading(false);
  }

  Future<bool> createActivity(ActivityModel activity) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 400));
    _activities.insert(0, activity);
    notifyListeners();
    _setLoading(false);
    return true;
  }

  Future<bool> updateActivity(ActivityModel updated) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _activities.indexWhere((a) => a.id == updated.id);
    if (idx != -1) _activities[idx] = updated;
    notifyListeners();
    _setLoading(false);
    return true;
  }

  void deleteActivity(String id) {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  static List<ActivityModel> _initialActivities() => [
    ActivityModel(
      id: '1', type: 'RIEGO', lot: 'Lote A', lotId: 'lot1', crop: 'Maíz',
      quantity: '150', unit: 'litros',
      date: DateTime(2026, 4, 19, 6, 30), farmId: 'farm1',
      notes: 'Riego por goteo',
    ),
    ActivityModel(
      id: '2', type: 'FERTILIZACION', lot: 'Lote B', lotId: 'lot2', crop: 'Tomate',
      quantity: '25', unit: 'kg',
      date: DateTime(2026, 4, 18, 14, 15), farmId: 'farm1',
      notes: 'Fertilizante orgánico',
    ),
    ActivityModel(
      id: '3', type: 'FUMIGACION', lot: 'Invernadero 1', lotId: 'lot3', crop: 'Lechuga',
      quantity: '10', unit: 'litros',
      date: DateTime(2026, 4, 17, 8, 0), farmId: 'farm1',
    ),
    ActivityModel(
      id: '4', type: 'CONTROL_PLAGAS', lot: 'Lote A', lotId: 'lot1', crop: 'Maíz',
      quantity: '2', unit: 'aplicaciones',
      date: DateTime(2026, 4, 16, 10, 45), farmId: 'farm1',
    ),
    ActivityModel(
      id: '5', type: 'SIEMBRA', lot: 'Invernadero 1', lotId: 'lot3', crop: 'Lechuga',
      quantity: '28', unit: 'kg',
      date: DateTime(2026, 4, 15, 12, 0), farmId: 'farm1',
    ),
  ];
}
