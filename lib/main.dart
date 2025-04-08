// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_futbol_cuestionario/core/config/supabase_config.dart';
import 'package:app_futbol_cuestionario/core/services/sesion_service.dart';
import 'package:app_futbol_cuestionario/modules/shared/pantalla_inicio.dart';
import 'package:app_futbol_cuestionario/modules/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Fútbol Cuestionario',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
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
  bool cargando = true;
  Usuario? usuario;
  int? jugadorIdInt; // id entero del jugador (tabla jugadores)

  @override
  void initState() {
    super.initState();
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    // Obtener el usuario activo (de SharedPreferences o la sesión actual)
    usuario = await SesionService.obtenerUsuarioActivo();
    if (usuario != null) {
      if (usuario!.rol == 'jugador') {
        jugadorIdInt = await SesionService.obtenerJugadorIdPorUsuario(usuario!.id);
      } else if (usuario!.rol == 'cuerpo_tecnico') {
        jugadorIdInt = await SesionService.obtenerCuerpoTecnicoIdPorUsuario(usuario!.id);
      }
    }
    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (usuario == null) {
      return const LoginScreen();
    }

    // Si por alguna razón no se encontró el id entero, podrías tomar una acción (por ejemplo, mostrar un error).
    return PantallaInicio(
      jugadorId: jugadorIdInt ?? 0, // jugadorIdInt es un int
      rolUsuario: usuario!.rol,
      nombreJugador: usuario!.nombre,
    );
  }
}
