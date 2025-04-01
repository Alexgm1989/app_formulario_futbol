// login_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_futbol_cuestionario/modules/shared/pre_post_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;
  bool _cargando = false;

  Future<void> _validarPin() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final pinIngresado = _pinController.text.trim();
    final response = await Supabase.instance.client
        .from('usuarios')
        .select()
        .eq('pin', pinIngresado)
        .maybeSingle();

    if (response == null) {
      setState(() {
        _error = 'PIN incorrecto';
        _cargando = false;
      });
      return;
    }

    final rol = response['rol'] as String? ?? 'jugador';

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PrePostSelectionScreen(rolUsuario: rol),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Introduce tu PIN', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PIN',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _validarPin(),
            ),
            const SizedBox(height: 20),
            _cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _validarPin,
                    child: const Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
