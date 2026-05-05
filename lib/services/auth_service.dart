import 'package:dio/dio.dart';
import '../config/api_client.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  /// Inicia sesión y guarda los tokens automáticamente.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      // Guarda tokens en SharedPreferences
      await ApiClient.saveTokens(
        accessToken:  data['access_token']  as String,
        refreshToken: data['refresh_token'] as String,
      );

      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Crea una cuenta nueva.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      await ApiClient.saveTokens(
        accessToken:  data['access_token']  as String,
        refreshToken: data['refresh_token'] as String,
      );

      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Obtiene el usuario autenticado actual.
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConfig.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Cierra sesión e invalida el token en el servidor.
  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } catch (_) {
      // Aunque falle el servidor, limpiamos localmente
    } finally {
      await ApiClient.clearTokens();
    }
  }

  /// Envía correo de recuperación de contraseña.
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(ApiConfig.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Comprueba si hay sesión activa (token en disco).
  Future<bool> hasSession() async {
    final token = await ApiClient.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
