import 'package:flutter/material.dart';
import 'admin_panel_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String _pinCorrecto = '1234';
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _validarPin() {
    if (_pinController.text == _pinCorrecto) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    } else {
      setState(() => _error = 'PIN incorrecto');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso Administrador')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Introduce el PIN de administrador',
                style: TextStyle(fontSize: 18)),
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
            ElevatedButton(
              onPressed: _validarPin,
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
