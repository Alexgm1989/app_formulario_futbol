import 'package:flutter/material.dart';

class InformeAntropometricoScreen extends StatelessWidget {
  final int jugadorId;
  final String nombreJugador;

  const InformeAntropometricoScreen({
    super.key,
    required this.jugadorId,
    required this.nombreJugador,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informe Antropométrico")),
      body: Center(
        child: Text("Generación de informe para $nombreJugador (ID: $jugadorId)"),
      ),
    );
  }
}
