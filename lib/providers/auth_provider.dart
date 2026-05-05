import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

// ── Usuarios locales ──────────────────────────────────────────────────────────
const _localUsers = [
  {
    'id':       '1',
    'name':     'Carlos Productor',
    'email':    'productor@sga.com',
    'password': '123456',
    'farmName': 'Finca La Esperanza',
    'farmId':   'farm1',
    'role':     'farmer',
  },
  {
    'id':       '2',
    'name':     'Admin SGA',
    'email':    'admin@sga.com',
    'password': 'admin123',
    'farmName': 'Finca La Esperanza',
    'farmId':   'farm1',
    'role':     'admin',
  },
];

class AuthProvider extends ChangeNotifier {
  AuthStatus _status  = AuthStatus.unknown;
  UserModel? _user;
  String?    _error;
  bool       _loading = false;

  AuthStatus get status          => _status;
  UserModel? get user            => _user;
  String?    get error           => _error;
  bool       get loading         => _loading;
  bool       get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkSession() async {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    await Future.delayed(const Duration(milliseconds: 600));

    final match = _localUsers.where(
      (u) => u['email'] == email.trim().toLowerCase() &&
             u['password'] == password,
    ).toList();

    if (match.isEmpty) {
      _error = 'Correo o contraseña incorrectos.';
      notifyListeners();
      _setLoading(false);
      return false;
    }

    final u = match.first;
    _user = UserModel(
      id:       u['id']!,
      name:     u['name']!,
      email:    u['email']!,
      farmName: u['farmName'],
      farmId:   u['farmId'],
      role:     u['role']!,
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
    _setLoading(false);
    return true;
  }

  Future<bool> register(String name, String email, String password, {String? farmName}) async {
    _setLoading(true);
    _error = null;
    await Future.delayed(const Duration(milliseconds: 600));
    // En modo local el registro siempre crea sesión
    _user = UserModel(
      id:       DateTime.now().millisecondsSinceEpoch.toString(),
      name:     name,
      email:    email,
      farmName: farmName ?? 'Mi Finca',
      farmId:   'farm1',
      role:     'farmer',
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
    _setLoading(false);
    return true;
  }

  Future<void> logout() async {
    await ApiClient.clearTokens();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateUser(UserModel updated) {
    _user = updated;
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
}
