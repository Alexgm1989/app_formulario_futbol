import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/core/services/antropometria_service.dart';

class InformeDiarioScreen extends StatelessWidget {
  const InformeDiarioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Constantes definidas para esta versión
    const double valor_objetivo = 10;
    const double importe_sancion = 5;

    return Scaffold(
      appBar: AppBar(title: const Text("Informe Diario")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: AntropometriaService.obtenerRegistrosConVariacion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay registros para el día de hoy."));
          }
          final registros = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Jugador")),
                DataColumn(label: Text("Peso")),
                DataColumn(label: Text("Tríceps")),
                DataColumn(label: Text("Subescapular")),
                DataColumn(label: Text("Suprailiaco")),
                DataColumn(label: Text("Abdominal")),
                DataColumn(label: Text("Muslo anterior")),
                DataColumn(label: Text("Pectoral")),
                DataColumn(label: Text("Pantorrilla medial")),
                DataColumn(label: Text("% Grasa (Jackson)")),
                DataColumn(label: Text("% Grasa (Faulkner)")),
                DataColumn(label: Text("Variación Faulkner")),
                DataColumn(label: Text("Multa")),
              ],
              rows: registros.map((registro) {
                final jugador = registro['jugadores'];
                final nombreJugador = jugador != null
                    ? (jugador['nombre'] ?? 'Desconocido')
                    : 'Desconocido';

                final variacion = registro['variacion_faulkner'];
                final variacionStr = variacion != null
                    ? '${variacion.toStringAsFixed(2)}%'
                    : '-';

                final grasaFaulkner = (registro['grasa_faulkner'] is num)
                    ? (registro['grasa_faulkner'] as num).toDouble()
                    : 0.0;
                final diff = grasaFaulkner - valor_objetivo;
                final multa = diff > 0 ? diff * importe_sancion / 0.1 : 0.0;
                final multaStr = multa > 0 ? multa.toStringAsFixed(2) : '0.00';

                return DataRow(cells: [
                  DataCell(Text(nombreJugador.toString())),
                  DataCell(Text(registro['peso']?.toString() ?? '-')),
                  DataCell(Text(registro['pliegue_triceps']?.toString() ?? '-')),
                  DataCell(Text(registro['pliegue_subescapular']?.toString() ?? '-')),
                  DataCell(Text(registro['pliegue_suprailiaco']?.toString() ?? '-')),
                  DataCell(Text(registro['pliegue_abdominal']?.toString() ?? '-')),
                  DataCell(Text(registro['pliegue_muslo_anterior']?.toString() ?? '-')),
                  DataCell(Text(registro['pliegue_pectoral']?.toString() ?? '-')),
                  DataCell(Text(registro['pliegue_pantorrilla_medial']?.toString() ?? '-')),
                  DataCell(Text(registro['grasa_jackson_pollock']?.toString() ?? '-')),
                  DataCell(Text(registro['grasa_faulkner']?.toString() ?? '-')),
                  DataCell(Text(variacionStr)),
                  DataCell(Text("$multaStr €")),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
