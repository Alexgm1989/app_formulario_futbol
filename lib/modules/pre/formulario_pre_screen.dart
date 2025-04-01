import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_storage.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_service.dart';

class FormularioPreScreen extends StatefulWidget {
  final int jugadorId;
  final String nombreJugador;

  const FormularioPreScreen({
    super.key,
    required this.jugadorId,
    required this.nombreJugador,
  });

  @override
  State<FormularioPreScreen> createState() => _FormularioPreScreenState();
}

class _FormularioPreScreenState extends State<FormularioPreScreen> {
  int? sueno;
  int? estres;
  int? fatiga;
  int? dolorMuscular;
  bool tieneMolestias = false;
  bool cargando = false;
  final TextEditingController molestiasController = TextEditingController();
  final TextEditingController comentariosController = TextEditingController();

  @override
  void dispose() {
    molestiasController.dispose();
    comentariosController.dispose();
    super.dispose();
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atención'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarFormulario() async {
    if (sueno == null || estres == null || fatiga == null || dolorMuscular == null) {
      _mostrarAlerta('Debes completar todas las preguntas obligatorias.');
      return;
    }

    setState(() => cargando = true);

    final datos = {
      'sueno': sueno,
      'estres': estres,
      'fatiga': fatiga,
      'dolor_muscular': dolorMuscular,
      'molestias_pre': tieneMolestias,
      'detalle_molestias_pre': tieneMolestias ? molestiasController.text : '',
      'comentarios_pre': comentariosController.text,
    };

    try {
      await RespuestaService.guardarRespuesta(
        jugadorId: widget.jugadorId,
        tipo: 'pre',
        datos: datos,
      );

      await RespuestaStorage.guardarRespuesta(
        jugador: widget.nombreJugador,
        tipo: 'pre',
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Gracias!'),
          content: const Text('Has completado el cuestionario PRE.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    } catch (e) {
      _mostrarAlerta('Ocurrió un error al guardar. Verifica tu conexión.');
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Widget _buildPreguntaBotones({
    required String label,
    required int? value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final numero = index + 1;
            return ChoiceChip(
              label: Text('$numero'),
              selected: value == numero,
              onSelected: (_) => onChanged(numero),
              selectedColor: Colors.green,
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuestionario PRE - ${widget.nombreJugador}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPreguntaBotones(
              label: 'Sueño',
              value: sueno,
              onChanged: (v) => setState(() => sueno = v),
            ),
            _buildPreguntaBotones(
              label: 'Estrés',
              value: estres,
              onChanged: (v) => setState(() => estres = v),
            ),
            _buildPreguntaBotones(
              label: 'Fatiga',
              value: fatiga,
              onChanged: (v) => setState(() => fatiga = v),
            ),
            _buildPreguntaBotones(
              label: 'Dolor muscular',
              value: dolorMuscular,
              onChanged: (v) => setState(() => dolorMuscular = v),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('¿Tienes molestias?'),
                const SizedBox(width: 10),
                Switch(
                  value: tieneMolestias,
                  onChanged: (v) => setState(() => tieneMolestias = v),
                ),
              ],
            ),
            if (tieneMolestias)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: molestiasController,
                  decoration: const InputDecoration(
                    labelText: '¿Dónde tienes molestias?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: comentariosController,
              decoration: const InputDecoration(
                labelText: 'Comentarios adicionales',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _enviarFormulario,
                    child: const Text('Enviar'),
                  ),
          ],
        ),
      ),
    );
  }
}
