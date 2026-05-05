/// ============================================================
///  API CONFIGURATION
///  Cambia [baseUrl] cuando tengas el backend desplegado.
///  En desarrollo apunta a tu localhost o IP local.
/// ============================================================

class ApiConfig {
  ApiConfig._();

  // ── Entornos ──────────────────────────────────────────────
  static const String _devUrl  = 'http://10.0.2.2:8000/api/v1';    // Android emulator → localhost
  static const String _serverUrl = 'http://52.73.66.124:8000/api/v1'; // Servidor desplegado
  static const String _prodUrl = 'https://api.sga.com/api/v1';     // Producción (cambiar cuando esté listo)

  /// URL activa. Cambia a [_prodUrl] para producción.
  static const String baseUrl = _serverUrl;

  // ── Timeouts ──────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Auth endpoints ────────────────────────────────────────
  static const String login           = '/auth/login';
  static const String register        = '/auth/register';
  static const String logout          = '/auth/logout';
  static const String refreshToken    = '/auth/refresh';
  static const String forgotPassword  = '/auth/forgot-password';
  static const String resetPassword   = '/auth/reset-password';
  static const String me              = '/auth/me';

  // ── User / Account endpoints ──────────────────────────────
  static const String updateProfile   = '/users/me';
  static const String changePassword  = '/users/me/password';

  // ── Farm endpoints ────────────────────────────────────────
  static const String farms           = '/farms';
  static String farmById(String id)   => '/farms/$id';
  static String farmLots(String id)   => '/farms/$id/lots';

  // ── Activities endpoints ──────────────────────────────────
  static const String activities            = '/activities';
  static String activityById(String id)     => '/activities/$id';
  static String activitiesByFarm(String id) => '/farms/$id/activities';

  // ── Sensors / Telemetry endpoints ────────────────────────
  static String sensorData(String farmId)   => '/farms/$farmId/sensors/latest';

  // ── Headers comunes ───────────────────────────────────────
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
