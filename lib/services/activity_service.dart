import 'package:dio/dio.dart';
import '../config/api_client.dart';
import '../config/api_config.dart';
import '../models/activity_model.dart';

class ActivityService {
  final Dio _dio = ApiClient.instance.dio;

  /// Obtiene actividades de una finca, con filtro opcional por tipo.
  Future<List<ActivityModel>> getActivities({
    required String farmId,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.activitiesByFarm(farmId),
        queryParameters: {
          'page':  page,
          'limit': limit,
          if (type != null && type != 'Todas') 'type': type,
        },
      );

      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Registra una nueva actividad.
  Future<ActivityModel> createActivity(ActivityModel activity) async {
    try {
      final response = await _dio.post(
        ApiConfig.activities,
        data: activity.toJson(),
      );
      return ActivityModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Actualiza una actividad existente.
  Future<ActivityModel> updateActivity(ActivityModel activity) async {
    try {
      final response = await _dio.put(
        ApiConfig.activityById(activity.id),
        data: activity.toJson(),
      );
      return ActivityModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Elimina una actividad.
  Future<void> deleteActivity(String id) async {
    try {
      await _dio.delete(ApiConfig.activityById(id));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Mock local (usar mientras el backend no está listo) ────
  List<ActivityModel> getMockActivities() => [
        ActivityModel(
          id: '1', type: 'Riego', lot: 'Lote A', crop: 'Café',
          quantity: '150', unit: 'litros',
          date: DateTime(2026, 2, 19, 6, 30), farmId: 'farm1',
        ),
        ActivityModel(
          id: '2', type: 'Fertilización', lot: 'Lote B', crop: 'Maíz',
          quantity: '25', unit: 'kg',
          date: DateTime(2026, 2, 18, 14, 15), farmId: 'farm1',
        ),
        ActivityModel(
          id: '3', type: 'Fumigación', lot: 'Lote C', crop: 'Tomate',
          quantity: '10', unit: 'litros',
          date: DateTime(2026, 2, 17, 8, 0), farmId: 'farm1',
        ),
        ActivityModel(
          id: '4', type: 'Control de Plagas', lot: 'Lote A', crop: 'Café',
          quantity: '2', unit: 'aplicaciones',
          date: DateTime(2026, 2, 16, 10, 45), farmId: 'farm1',
        ),
        ActivityModel(
          id: '5', type: 'Temperatura', lot: 'Invernadero 1', crop: '',
          quantity: '28', unit: '°C',
          date: DateTime(2026, 2, 15, 12, 0), farmId: 'farm1',
        ),
      ];
}
