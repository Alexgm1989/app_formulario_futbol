import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_storage.dart';
import 'package:app_futbol_cuestionario/modules/shared/services/respuesta_service.dart';

class FormularioPostScreen extends StatefulWidget {
  final int jugadorId;
  final String nombreJugador;

  const FormularioPostScreen({
    super.key,
    required this.jugadorId,
    required this.nombreJugador,
  });

  @override
  State<FormularioPostScreen> createState() => _FormularioPostScreenState();
}

class _FormularioPostScreenState extends State<FormularioPostScreen> {
  int? esfuerzo;
  int? forma;
  int? valoracion;
  String molestias = 'no';
  bool cargando = false;
  final TextEditingController molestiasDetalleController = TextEditingController();
  final TextEditingController comentariosController = TextEditingController();

  @override
  void dispose() {
    molestiasDetalleController.dispose();
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
    if (esfuerzo == null || forma == null || valoracion == null) {
      _mostrarAlerta('Debes completar todas las preguntas obligatorias.');
      return;
    }

    setState(() => cargando = true);

    final datos = {
      'esfuerzo': esfuerzo,
      'forma': forma,
      'valoracion': valoracion,
      'molestias_post': molestias != 'no',
      'molestias_post_detalle': molestias != 'no' ? molestiasDetalleController.text : '',
      'comentarios_post': comentariosController.text,
    };

    try {
      await RespuestaService.guardarRespuesta(
        jugadorId: widget.jugadorId,
        tipo: 'post',
        datos: datos,
      );

      await RespuestaStorage.guardarRespuesta(
        jugador: widget.nombreJugador,
        tipo: 'post',
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Gracias!'),
          content: const Text('Has completado el cuestionario POST.'),
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

  Widget _buildSelectorNumerico({
    required String label,
    required int min,
    required int max,
    required int? value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: List.generate(max - min + 1, (index) {
            final numero = min + index;
            return ChoiceChip(
              label: Text('$numero'),
              selected: value == numero,
              onSelected: (_) => onChanged(numero),
              selectedColor: Colors.green,
            );
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSelectorEstrellas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final filled = valoracion != null && index < valoracion!;
        return IconButton(
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? Colors.amber : Colors.grey,
          ),
          onPressed: () => setState(() => valoracion = index + 1),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuestionario POST - ${widget.nombreJugador}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSelectorNumerico(
              label: 'Esfuerzo que supuso la sesión (0-10)',
              min: 0,
              max: 10,
              value: esfuerzo,
              onChanged: (v) => setState(() => esfuerzo = v),
            ),
            _buildSelectorNumerico(
              label: '¿Cómo te has visto de forma en la sesión? (1-5)',
              min: 1,
              max: 5,
              value: forma,
              onChanged: (v) => setState(() => forma = v),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Has tenido molestias durante la sesión?',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('Sí'),
                  value: 'si',
                  groupValue: molestias,
                  onChanged: (value) => setState(() => molestias = value!),
                ),
                RadioListTile<String>(
                  title: const Text('No'),
                  value: 'no',
                  groupValue: molestias,
                  onChanged: (value) => setState(() => molestias = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Lesionado'),
                  value: 'lesionado',
                  groupValue: molestias,
                  onChanged: (value) => setState(() => molestias = value!),
                ),
              ],
            ),
            if (molestias != 'no')
              TextField(
                controller: molestiasDetalleController,
                decoration: const InputDecoration(
                  labelText: '¿Dónde has tenido molestias?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Valoración de la sesión',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildSelectorEstrellas(),
              ],
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
