import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_futbol_cuestionario/modules/shared/pre_post_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final supabase = Supabase.instance.client;

    try {
      // 1. Verificar que el email exista en jugadores o cuerpo_tecnico
      final jugadorResponse = await supabase
          .from('jugadores')
          .select('*')
          .eq('email', email)
          .maybeSingle(); // Retorna Map? o null

      final tecnicoResponse = await supabase
          .from('cuerpo_tecnico')
          .select('*')
          .eq('email', email)
          .maybeSingle();

      if (jugadorResponse == null && tecnicoResponse == null) {
        setState(() {
          _error = 'Email no autorizado para registro.';
          _loading = false;
        });
        return;
      }

      // Determinar la tabla de origen y el rol
      String role;
      Map<String, dynamic> sourceRecord;
      String tableName;
      if (jugadorResponse != null) {
        role = 'jugador';
        sourceRecord = jugadorResponse;
        tableName = 'jugadores';
      } else {
        role = 'cuerpo_tecnico';
        sourceRecord = tecnicoResponse!;
        tableName = 'cuerpo_tecnico';
      }

      // Verificar si ya se registró (por ejemplo, con el campo "registrado")
      if (sourceRecord['registrado'] == true) {
        setState(() {
          _error = 'Este email ya ha sido registrado.';
          _loading = false;
        });
        return;
      }

      // 2. Registrar en Supabase Auth (signUp)
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        setState(() {
          _error = 'Error al registrarse. Verifica tus datos.';
          _loading = false;
        });
        return;
      }

      final uuid = authResponse.user!.id;

      // 3. Insertar en la tabla "usuarios"
      final nombre = sourceRecord['nombre'] ?? 'Sin Nombre';
      final insertUserResponse = await supabase
          .from('usuarios')
          .insert({
            'id': uuid,
            'nombre': nombre,
            'email': email,
            'rol': role,
          })
          .select()
          .maybeSingle(); // Retorna el registro insertado o null

      if (insertUserResponse == null) {
        setState(() {
          _error = 'Error al crear registro de usuario.';
          _loading = false;
        });
        return;
      }

      // 4. Actualizar la tabla de origen
      final updateResponse = await supabase
          .from(tableName)
          .update({
            'usuario_id': uuid,
            'registrado': true,
            'fecha_registro': DateTime.now().toIso8601String(),
          })
          .eq('email', email)
          .select()
          .maybeSingle();

      if (updateResponse == null) {
        setState(() {
          _error = 'Error al actualizar el registro en $tableName.';
          _loading = false;
        });
        return;
      }

      // Registro exitoso: navegar a PrePostSelectionScreen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PrePostSelectionScreen(rolUsuario: role, nombreJugador: nombre,)),
      );
    } catch (e) {
      setState(() {
        _error = 'Excepción: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Registrarse'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
