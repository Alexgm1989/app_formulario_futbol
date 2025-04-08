// lib/modules/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_futbol_cuestionario/modules/shared/pantalla_inicio.dart';
import 'package:app_futbol_cuestionario/modules/auth/screens/register_screen.dart';
import 'package:app_futbol_cuestionario/core/services/sesion_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Iniciar sesión usando Supabase Auth con email y contraseña.
    final AuthResponse response = await Supabase.instance.client.auth
        .signInWithPassword(email: email, password: password);

    if (response.user == null) {
      setState(() {
        _error = 'Credenciales incorrectas';
        _loading = false;
      });
      return;
    }

    // Obtener datos adicionales (nombre y rol) desde la tabla "usuarios".
    final usuario = await SesionService.obtenerUsuarioPorId(response.user!.id);
    if (usuario == null) {
      setState(() {
        _error = 'Error al obtener datos del usuario';
        _loading = false;
      });
      return;
    }

    // Obtener el id entero del jugador o del cuerpo técnico según corresponda.
    int jugadorId = 0;
    if (usuario.rol == 'jugador') {
      final id = await SesionService.obtenerJugadorIdPorUsuario(usuario.id);
      if (id != null) jugadorId = id;
    } else if (usuario.rol == 'cuerpo_tecnico') {
      final id = await SesionService.obtenerCuerpoTecnicoIdPorUsuario(usuario.id);
      if (id != null) jugadorId = id;
    }

    if (!mounted) return;
    // Navegar a PantallaInicio para todos los roles.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaInicio(
          jugadorId: jugadorId,
          rolUsuario: usuario.rol,
          nombreJugador: usuario.nombre,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            // Limitar el ancho máximo a 400px.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen del escudo.
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      maxHeight: 200,
                    ),
                    child: Image.asset(
                      'assets/images/escudo_club.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '¡Bienvenido a la App Pontevedra CF',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Inicia sesión con tu email y contraseña',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Entrar'),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
