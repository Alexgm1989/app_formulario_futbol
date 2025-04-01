import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/pre/formulario_pre_screen.dart';
import 'package:app_futbol_cuestionario/modules/post/formulario_post_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_storage.dart';
import 'package:app_futbol_cuestionario/core/services/jugador_service.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final String tipoFormulario;

  const PlayerSelectionScreen({super.key, required this.tipoFormulario});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _jugadoresFuture;
  late Future<Set<String>> _jugadoresBloqueadosFuture;

  @override
  void initState() {
    super.initState();
    _jugadoresFuture = JugadorService.obtenerJugadores();
    _jugadoresBloqueadosFuture = _cargarJugadoresBloqueados();
  }

  Future<Set<String>> _cargarJugadoresBloqueados() async {
    final jugadores = await _jugadoresFuture;
    final bloqueados = <String>{};

    for (var jugador in jugadores) {
      final nombre = jugador['nombre'];
      final respondio = await RespuestaStorage.yaRespondio(
        jugador: nombre,
        tipo: widget.tipoFormulario,
      );
      if (respondio) {
        bloqueados.add(nombre);
      }
    }
    return bloqueados;
  }

  void _seleccionarJugador(
    BuildContext context,
    Map<String, dynamic> jugador,
    Set<String> jugadoresBloqueados,
  ) {
    final nombre = jugador['nombre'];
    final id = jugador['id'];

    if (jugadoresBloqueados.contains(nombre)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este jugador ya completó el formulario hoy')),
      );
      return;
    }

    final pantalla = widget.tipoFormulario == 'pre'
        ? FormularioPreScreen(jugadorId: id, nombreJugador: nombre)
        : FormularioPostScreen(jugadorId: id, nombreJugador: nombre);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    ).then((_) {
      setState(() {
        _jugadoresBloqueadosFuture = _cargarJugadoresBloqueados();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona jugador (${widget.tipoFormulario.toUpperCase()})'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _jugadoresFuture,
        builder: (context, snapshotJugadores) {
          if (!snapshotJugadores.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final jugadores = snapshotJugadores.data!;

          return FutureBuilder<Set<String>>(
            future: _jugadoresBloqueadosFuture,
            builder: (context, snapshotBloqueados) {
              if (!snapshotBloqueados.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final bloqueados = snapshotBloqueados.data!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = (constraints.maxWidth / 140).floor();

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: jugadores.length,
                    itemBuilder: (context, index) {
                      final jugador = jugadores[index];
                      final nombre = jugador['nombre'];
                      final urlFoto = jugador['url_foto'] as String?;
                      final estaBloqueado = bloqueados.contains(nombre);

                      return GestureDetector(
                        onTap: () => _seleccionarJugador(context, jugador, bloqueados),
                        child: Card(
                          color: estaBloqueado ? Colors.grey.shade300 : null,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: urlFoto != null && urlFoto.isNotEmpty
                                      ? Image.network(
                                          urlFoto,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 72,
                                          height: 72,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.person, size: 40),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nombre,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: estaBloqueado ? Colors.grey.shade700 : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
