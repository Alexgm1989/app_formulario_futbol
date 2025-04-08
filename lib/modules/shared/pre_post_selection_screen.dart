import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/post/formulario_post_screen.dart';
import 'package:app_futbol_cuestionario/modules/pre/formulario_pre_screen.dart';
import 'package:app_futbol_cuestionario/modules/admin/admin_panel_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_storage.dart';
import 'package:app_futbol_cuestionario/modules/shared/player_selection_screen.dart';

class PrePostSelectionScreen extends StatelessWidget {
  final String rolUsuario;
  final int? jugadorId; // Se usará si el rol es "jugador"
  final String? nombreJugador; // Se usará si el rol es "jugador"

  PrePostSelectionScreen({
    super.key,
    required this.rolUsuario,
    this.jugadorId,
    this.nombreJugador,
  })  : assert(
          rolUsuario.toLowerCase() != 'jugador' ||
              (jugadorId != null && nombreJugador != null),
          "Para rol 'jugador', jugadorId y nombreJugador deben ser proporcionados",
        );

  Future<void> _handleSelection(BuildContext context, String tipo) async {
    if (rolUsuario.toLowerCase() == 'jugador') {
      // Validamos si el jugador ya completó el formulario diario.
      bool yaRespondio = await RespuestaStorage.yaRespondio(
          jugador: nombreJugador!, tipo: tipo);
      if (yaRespondio) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Ya has rellenado el cuestionario diario, si deseas modificarlo, ve al panel de usuario",
            ),
          ),
        );
        return;
      }
      // Navegación directa al formulario correspondiente sin pasar por la selección.
      if (tipo == 'pre') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioPreScreen(
              jugadorId: jugadorId!,
              nombreJugador: nombreJugador!,
            ),
          ),
        );
      } else if (tipo == 'post') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioPostScreen(
              jugadorId: jugadorId!,
              nombreJugador: nombreJugador!,
            ),
          ),
        );
      }
    } else {
      // Para otros roles se muestra la pantalla de selección de jugador.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerSelectionScreen(tipoFormulario: tipo),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tipo de cuestionario'),
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
            if (rolUsuario.toLowerCase() == 'admin' ||
                rolUsuario.toLowerCase() == 'coach')
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPanelScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Acceso administrador',
                  style: TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
