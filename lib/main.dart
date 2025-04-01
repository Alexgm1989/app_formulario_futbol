import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/core/config/supabase_config.dart';
import 'package:app_futbol_cuestionario/core/services/sesion_service.dart';
import 'package:app_futbol_cuestionario/modules/auth/screens/login_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/pre_post_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fútbol Cuestionario',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final usuario = await SesionService.obtenerUsuarioActivo();

    if (!mounted) return;

    if (usuario == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      final rol = usuario.rol;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PrePostSelectionScreen(rolUsuario: rol)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
