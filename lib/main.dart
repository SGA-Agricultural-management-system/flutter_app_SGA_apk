import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/activity_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización en español
  await initializeDateFormatting('es', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SGAApp());
}

class SGAApp extends StatelessWidget {
  const SGAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MaterialApp(
        title: 'SGA - Sistema de Gestión Agrícola',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _SplashRouter(),
      ),
    );
  }
}

/// Decide si mostrar Login o Home según el estado de sesión.
class _SplashRouter extends StatelessWidget {
  const _SplashRouter();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    switch (status) {
      case AuthStatus.unknown:
        // Cargando sesión
        return const Scaffold(
          backgroundColor: Color(0xFFF0F4E8),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_rounded, color: Color(0xFF6AAE35), size: 64),
                SizedBox(height: 16),
                CircularProgressIndicator(color: Color(0xFF6AAE35)),
              ],
            ),
          ),
        );

      case AuthStatus.authenticated:
        return const HomeScreen();

      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
