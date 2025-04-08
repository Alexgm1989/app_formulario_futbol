import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/core/services/antropometria_service.dart';
import 'package:app_futbol_cuestionario/modules/shared/estudio_antropometrico_screen.dart';
import 'package:intl/intl.dart';

class ConsultaAntropometriaScreen extends StatefulWidget {
  final int jugadorId;
  final String nombreJugador;
  final String rolUsuario;

  const ConsultaAntropometriaScreen({
    super.key,
    required this.jugadorId,
    required this.nombreJugador,
    required this.rolUsuario,
  });

  @override
  State<ConsultaAntropometriaScreen> createState() => _ConsultaAntropometriaScreenState();
}

class _ConsultaAntropometriaScreenState extends State<ConsultaAntropometriaScreen> {
  List<Map<String, dynamic>> historial = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final datos = await AntropometriaService.obtenerHistorialJugador(widget.jugadorId);
    setState(() {
      historial = datos;
      cargando = false;
    });
  }

  void _abrirFormulario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstudioAntropometricoScreen(
          jugadorId: widget.jugadorId,
          nombreJugador: widget.nombreJugador,
          creadoPor: widget.rolUsuario,
        ),
      ),
    ).then((_) => _cargarHistorial());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de ${widget.nombreJugador}')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : historial.isEmpty
              ? const Center(child: Text('Sin registros disponibles'))
              : ListView.builder(
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final registro = historial[index];
                    // Se parsea el valor de la fecha y se formatea a dd/MM/yyyy.
                    final fechaStr = registro['fecha']?.toString() ?? '';
                    final fechaDate = DateTime.tryParse(fechaStr);
                    final fechaFormateada = fechaDate != null ? DateFormat('dd/MM/yyyy').format(fechaDate) : '-';

                    return ExpansionTile(
                      title: Text('Registro del $fechaFormateada'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: registro.entries.map((e) {
                              if (e.key == 'id' || e.key == 'jugador_id' || e.key == 'fecha') return const SizedBox();
                              return Text("${e.key.replaceAll('_', ' ')}: ${e.value ?? '-'}");
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton: widget.rolUsuario != 'jugador'
          ? FloatingActionButton(
              onPressed: _abrirFormulario,
              tooltip: 'Nuevo estudio',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
