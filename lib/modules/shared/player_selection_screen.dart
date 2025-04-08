import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/pre/formulario_pre_screen.dart';
import 'package:app_futbol_cuestionario/modules/post/formulario_post_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_storage.dart';
import 'package:app_futbol_cuestionario/core/services/jugador_service.dart';
import 'package:app_futbol_cuestionario/modules/shared/estudio_antropometrico_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/consulta_antropometria_screen.dart';
import 'package:app_futbol_cuestionario/modules/shared/informe_antropometrico_screen.dart';
import 'package:app_futbol_cuestionario/core/services/antropometria_service.dart';

class PlayerSelectionScreen extends StatefulWidget {
  /// Indica el flujo a utilizar:
  /// - "pre" o "post" para formularios
  /// - "antropometria_medidas", "antropometria_consultar" o "antropometria_informe"
  final String tipoFormulario;

  /// Opcional: se usará para diferenciar el flujo de antropometría.
  /// Si se pasa y es "jugador", se filtrará la lista para usar solo su registro.
  final String? rolUsuario;

  /// Opcional: si el rol es "jugador", se debe pasar su id para filtrar automáticamente.
  /// Para coaches o administradores, este valor debe ser null.
  final int? jugadorId;

  const PlayerSelectionScreen({
    super.key,
    required this.tipoFormulario,
    this.rolUsuario,
    this.jugadorId,
  });

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _jugadoresFuture;
  late Future<Set<String>> _jugadoresBloqueadosFuture;

  @override
  void initState() {
    super.initState();
    // Si el rol NO es "jugador", ignoramos el jugadorId y devolvemos todos los jugadores.
    _jugadoresFuture = JugadorService.obtenerJugadores().then((jugadores) {
      if (widget.rolUsuario?.toLowerCase() == "jugador" && widget.jugadorId != null) {
        return jugadores.where((j) => j['id'] == widget.jugadorId).toList();
      }
      return jugadores;
    });
    _jugadoresBloqueadosFuture = _cargarJugadoresBloqueados();
  }

  Future<Set<String>> _cargarJugadoresBloqueados() async {
    final jugadores = await _jugadoresFuture;
    final bloqueados = <String>{};

    for (var jugador in jugadores) {
      final nombre = jugador['nombre'];
      final jugadorId = jugador['id'];
      bool respondio = false;

      if (!widget.tipoFormulario.startsWith('antropometria_medidas')) {
        respondio = await RespuestaStorage.yaRespondio(
          jugador: nombre,
          tipo: widget.tipoFormulario,
        );
      } else {
        respondio = await AntropometriaService.yaRegistroHoy(jugadorId);
      }

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

    // Si ya completó el formulario o registro, mostramos un mensaje.
    if (jugadoresBloqueados.contains(nombre)) {
      final mensaje = widget.tipoFormulario == 'antropometria_medidas'
          ? 'Este jugador ya fue registrado hoy en antropometría'
          : 'Este jugador ya completó el formulario hoy';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      return;
    }

    Widget pantalla;
    switch (widget.tipoFormulario) {
      case 'pre':
        pantalla = FormularioPreScreen(jugadorId: id, nombreJugador: nombre);
        break;
      case 'post':
        pantalla = FormularioPostScreen(jugadorId: id, nombreJugador: nombre);
        break;
      case 'antropometria_medidas':
        pantalla = EstudioAntropometricoScreen(
          jugadorId: id,
          nombreJugador: nombre,
          // Se usa el rol recibido, o "coach" por defecto.
          creadoPor: widget.rolUsuario ?? "coach",
        );
        break;
      case 'antropometria_consultar':
        pantalla = ConsultaAntropometriaScreen(
          jugadorId: id,
          nombreJugador: nombre,
          rolUsuario: widget.rolUsuario ?? "coach",
        );
        break;
      case 'antropometria_informe':
        pantalla = InformeAntropometricoScreen(
          jugadorId: id,
          nombreJugador: nombre,
        );
        break;
      default:
        pantalla = Container();
    }

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
          // Si el rol es "jugador" y solo hay un registro, navega automáticamente.
          if (widget.rolUsuario?.toLowerCase() == "jugador" &&
              jugadores.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _seleccionarJugador(context, jugadores.first, {});
            });
            return const Center(child: CircularProgressIndicator());
          }
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
