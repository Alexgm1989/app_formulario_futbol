// pre_post_selection_screen.dart
import 'package:flutter/material.dart';
import 'player_selection_screen.dart';
import 'package:app_futbol_cuestionario/modules/admin/admin_panel_screen.dart';

class PrePostSelectionScreen extends StatelessWidget {
  final String rolUsuario;

  const PrePostSelectionScreen({super.key, required this.rolUsuario});

  void _handleSelection(BuildContext context, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerSelectionScreen(tipoFormulario: tipo),
      ),
    );
  }

  void _irAPanelAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puedeVerPanel = rolUsuario == 'admin' || rolUsuario == 'coach';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tipo de cuestionario'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _handleSelection(context, 'pre'),
              icon: const Icon(Icons.access_time),
              label: const Text('Cuestionario PRE'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _handleSelection(context, 'post'),
              icon: const Icon(Icons.nightlight_round),
              label: const Text('Cuestionario POST'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 40),
            if (puedeVerPanel)
              TextButton(
                onPressed: () => _irAPanelAdmin(context),
                child: const Text('Acceso administrador',
                    style: TextStyle(fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }
}
