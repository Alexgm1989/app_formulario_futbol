// lib/modules/shared/pantalla_inicio.dart
import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/shared/pre_post_selection_screen.dart';
import 'package:app_futbol_cuestionario/modules/admin/admin_panel_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/antropometria_options_screen.dart';
import 'package:app_futbol_cuestionario/widgets/app_bar_usuario.dart';

class PantallaInicio extends StatelessWidget {
  final int jugadorId;
  final String rolUsuario;
  final String nombreJugador;

  const PantallaInicio({
    super.key,
    required this.jugadorId,
    required this.rolUsuario,
    required this.nombreJugador,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUsuario(
        title: 'Menú principal',
        usuarioNombre: nombreJugador,
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(32),
          shrinkWrap: true,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.assignment),
              label: const Text('Cuestionarios'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrePostSelectionScreen(
                      rolUsuario: rolUsuario,
                      jugadorId: rolUsuario.toLowerCase() == 'jugador' ? jugadorId : null,
                      nombreJugador: rolUsuario.toLowerCase() == 'jugador' ? nombreJugador : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.monitor_weight),
              label: const Text('Antropometría'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AntropometriaOptionsScreen(
                      jugadorId: jugadorId,
                      rolUsuario: rolUsuario,
                      nombreJugador: nombreJugador,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.healing),
              label: const Text('Lesiones'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlaceholderScreen(
                      title: 'Lesiones',
                      message: 'Sección en desarrollo',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Panel de usuario'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaceholderScreen(
                      title: 'Panel de Usuario',
                      message: 'Panel de Usuario para ${rolUsuario.toLowerCase() == "jugador" ? "jugador" : "entrenador"}: $nombreJugador',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (rolUsuario.toLowerCase() == 'admin')
              ElevatedButton.icon(
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Panel de administrador'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                  );
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Calendario'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlaceholderScreen(
                      title: 'Calendario',
                      message: 'Funcionalidad de Calendario en desarrollo',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.gps_fixed),
              label: const Text('GPS'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlaceholderScreen(
                      title: 'GPS',
                      message: 'Funcionalidad de GPS en desarrollo',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
