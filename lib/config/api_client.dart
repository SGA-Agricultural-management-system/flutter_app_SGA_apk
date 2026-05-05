import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Cliente HTTP global con:
///  - Inyección automática del Bearer token
///  - Refresh de token cuando recibe 401
///  - Logging en modo debug
///  - Manejo centralizado de errores
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String _tokenKey   = 'access_token';
  static const String _refreshKey = 'refresh_token';

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  // ── Build Dio ─────────────────────────────────────────────
  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    dio.interceptors.add(_AuthInterceptor(dio));
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[SGA API] $obj'),
    ));

    return dio;
  }

  // ── Token helpers ─────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
  }
}

// ── Auth Interceptor ──────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final Dio dio;
  _AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await ApiClient.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Intenta refresh si el token expiró (401)
    if (err.response?.statusCode == 401) {
      final refreshToken = await ApiClient.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await dio.post(
            ApiConfig.refreshToken,
            data: {'refresh_token': refreshToken},
          );
          final newToken = response.data['access_token'] as String;
          await ApiClient.saveTokens(
            accessToken: newToken,
            refreshToken: refreshToken,
          );
          // Reintenta la petición original con el nuevo token
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retried = await dio.fetch(err.requestOptions);
          return handler.resolve(retried);
        } catch (_) {
          await ApiClient.clearTokens();
          // Emite error para que el provider redirija al login
          return handler.next(
            DioException(
              requestOptions: err.requestOptions,
              error: 'SESSION_EXPIRED',
              type: DioExceptionType.unknown,
            ),
          );
        }
      }
    }
    handler.next(err);
  }
}

// ── API Exception ─────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data   = e.response?.data;

    String msg;
    if (e.error == 'SESSION_EXPIRED') {
      msg = 'Sesión expirada. Por favor inicia sesión nuevamente.';
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      msg = 'Sin conexión. Verifica tu internet e intenta de nuevo.';
    } else if (data is Map && data.containsKey('message')) {
      final m = data['message'];
      msg = m is List ? m.join(', ') : m.toString();
    } else if (data is Map && data.containsKey('detail')) {
      msg = data['detail'].toString();
    } else if (data is Map && data.containsKey('error')) {
      msg = data['error'].toString();
    } else if (data != null) {
      // Muestra la respuesta completa para debug
      msg = '[$status] $data';
    } else {
      msg = 'Error inesperado (código $status).';
    }

    return ApiException(message: msg, statusCode: status);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
