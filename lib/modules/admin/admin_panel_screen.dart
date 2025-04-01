import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_storage.dart';
import 'package:app_futbol_cuestionario/core/services/jugador_service.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<Map<String, dynamic>> jugadores = [];
  String? jugadorSeleccionado;
  String tipoFormulario = 'pre';
  String mensaje = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarJugadores();
  }

  Future<void> _cargarJugadores({bool forzar = false}) async {
    setState(() => cargando = true);
    try {
      final lista = forzar
          ? await JugadorService.actualizarCache()
          : await JugadorService.obtenerJugadores();
      setState(() {
        jugadores = lista;
        mensaje = forzar ? 'Jugadores actualizados desde Supabase.' : '';
      });
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar jugadores.';
      });
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> _eliminarRespuesta() async {
    if (jugadorSeleccionado == null) {
      setState(() {
        mensaje = 'Selecciona un jugador primero.';
      });
      return;
    }

    final jugadorId = await RespuestaService.obtenerIdJugadorPorNombre(jugadorSeleccionado!);
    if (jugadorId == null) {
      setState(() {
        mensaje = 'No se encontró el ID del jugador seleccionado.';
      });
      return;
    }

    await RespuestaService.eliminarRespuestaDeSupabase(
      jugadorId: jugadorId,
      tipo: tipoFormulario,
    );

    await RespuestaStorage.eliminarRespuestaDelJugador(
      jugador: jugadorSeleccionado!,
      tipo: tipoFormulario,
    );

    final snackBar = SnackBar(
      content: Text(
        'Respuesta $tipoFormulario eliminada correctamente para $jugadorSeleccionado.',
      ),
      backgroundColor: Colors.green,
    );
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      mensaje = 'Respuesta eliminada para $jugadorSeleccionado ($tipoFormulario)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administrador')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Eliminar respuesta de un jugador:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            cargando
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: jugadorSeleccionado,
                    items: jugadores
                        .map((jugador) => DropdownMenuItem<String>(
                              value: jugador['nombre'],
                              child: Text(jugador['nombre']),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => jugadorSeleccionado = value),
                    decoration: const InputDecoration(
                      labelText: 'Jugador',
                      border: OutlineInputBorder(),
                    ),
                  ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: tipoFormulario,
              items: const [
                DropdownMenuItem(value: 'pre', child: Text('Formulario PRE')),
                DropdownMenuItem(value: 'post', child: Text('Formulario POST')),
              ],
              onChanged: (value) => setState(() => tipoFormulario = value!),
              decoration: const InputDecoration(
                labelText: 'Tipo de formulario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _eliminarRespuesta,
              child: const Text('Eliminar respuesta'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _cargarJugadores(forzar: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar jugadores desde Supabase'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 16,
                color: mensaje.contains('Error') ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
