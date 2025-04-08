import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/shared/consulta_antropometria_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/estudio_antropometrico_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/informe_antropometrico_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/informe_diario_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/player_selection_screen.dart';

class AntropometriaOptionsScreen extends StatelessWidget {
  final int jugadorId;
  final String rolUsuario;
  final String nombreJugador;

  const AntropometriaOptionsScreen({
    Key? key,
    required this.jugadorId,
    required this.rolUsuario,
    required this.nombreJugador,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isJugador = rolUsuario.toLowerCase() == 'jugador';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Antropometría"),
      ),
      body: Center(
        child: isJugador
            // Si es jugador, mostramos directamente el historial
            ? ConsultaAntropometriaScreen(
                jugadorId: jugadorId,
                nombreJugador: nombreJugador,
                rolUsuario: rolUsuario,
              )
            // Si es coach o admin, se muestran las 3 opciones
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón "Añadir medida" ahora redirige a PlayerSelectionScreen para seleccionar jugador
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Añadir medida"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerSelectionScreen(
                              tipoFormulario: 'antropometria_medidas',
                              rolUsuario: rolUsuario,
                              jugadorId: null, // Mostrar lista completa para seleccionar jugador
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text("Consultar historial"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerSelectionScreen(
                              tipoFormulario: 'antropometria_consultar',
                              rolUsuario: rolUsuario,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.description),
                      label: const Text("Generar informe"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Seleccione el tipo de informe"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    child: const Text("Informe Diario"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const InformeDiarioScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  ElevatedButton(
                                    child: const Text("Informe Jugador"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const PlayerSelectionScreen(
                                            tipoFormulario: 'antropometria_informe',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
