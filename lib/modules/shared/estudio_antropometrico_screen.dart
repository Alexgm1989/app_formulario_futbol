
import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/core/services/antropometria_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstudioAntropometricoScreen extends StatefulWidget {
  final int jugadorId;
  final String nombreJugador;
  final String creadoPor;

  const EstudioAntropometricoScreen({
    super.key,
    required this.jugadorId,
    required this.nombreJugador,
    required this.creadoPor,
  });

  @override
  State<EstudioAntropometricoScreen> createState() => _EstudioAntropometricoScreenState();
}

class _EstudioAntropometricoScreenState extends State<EstudioAntropometricoScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _campos = {};

  final List<String> camposPrincipales = [
    'peso',
    'pliegue_triceps',
    'pliegue_subescapular',
    'pliegue_suprailiaco',
    'pliegue_abdominal',
    'pliegue_muslo_anterior',
    'pliegue_pectoral',
    'pliegue_pantorrilla_medial',
  ];

  final List<String> camposPerimetros = [
    'perimetro_brazo_relajado',
    'perimetro_brazo_flexionado',
    'perimetro_cintura',
    'perimetro_cadera',
    'perimetro_muslo',
    'perimetro_pantorrilla',
  ];

  bool _incluirPerimetros = false;
  final TextEditingController _comentariosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var campo in [...camposPrincipales, ...camposPerimetros]) {
      _campos[campo] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controlador in _campos.values) {
      controlador.dispose();
    }
    _comentariosController.dispose();
    super.dispose();
  }

  Future<int> obtenerEdadDesdeBD(int jugadorId) async {
    final response = await Supabase.instance.client
        .from('jugadores')
        .select('fecha_nacimiento')
        .eq('id', jugadorId)
        .maybeSingle();

    if (response != null && response['fecha_nacimiento'] != null) {
      final birthDate = DateTime.parse(response['fecha_nacimiento']);
      final today = DateTime.now();
      int edad = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        edad--;
      }
      return edad;
    }
    return 18; // Default fallback
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> datos = {
      'jugador_id': widget.jugadorId,
      'creado_por': widget.creadoPor,
      'comentarios': _comentariosController.text,
    };

    for (var campo in camposPrincipales) {
      final text = _campos[campo]!.text.trim();
      if (text.isNotEmpty) {
        datos[campo] = double.tryParse(text);
      }
    }

    if (_incluirPerimetros) {
      for (var campo in camposPerimetros) {
        final text = _campos[campo]!.text.trim();
        if (text.isNotEmpty) {
          datos[campo] = double.tryParse(text);
        }
      }
    }

    try {
      final edad = await obtenerEdadDesdeBD(widget.jugadorId);

      final Map<String, double> plieguesJP = {

        'pliegue_triceps': (datos['pliegue_triceps'] ?? 0).toDouble(),
        'pliegue_subescapular': (datos['pliegue_subescapular'] ?? 0).toDouble(),
        'pliegue_suprailiaco': (datos['pliegue_suprailiaco'] ?? 0).toDouble(),
        'pliegue_abdominal': (datos['pliegue_abdominal'] ?? 0).toDouble(),
        'pliegue_muslo_anterior': (datos['pliegue_muslo_anterior'] ?? 0).toDouble(),
        'pliegue_pectoral': (datos['pliegue_pectoral'] ?? 0).toDouble(),
        'pliegue_pantorrilla_medial': (datos['pliegue_pantorrilla_medial'] ?? 0).toDouble(),
      };

      final Map<String, double> plieguesFaulkner = {

        'pliegue_triceps': (datos['pliegue_triceps'] ?? 0).toDouble(),
        'pliegue_subescapular': (datos['pliegue_subescapular'] ?? 0).toDouble(),
        'pliegue_suprailiaco': (datos['pliegue_suprailiaco'] ?? 0).toDouble(),
        'pliegue_abdominal': (datos['pliegue_abdominal'] ?? 0).toDouble(),
      };

      final porcentajeJackson = calcularPorcentajeGrasaJacksonPollock7(pliegues: plieguesJP, edad: edad);
      final porcentajeFaulkner = calcularPorcentajeGrasaFaulkner(pliegues: plieguesFaulkner);

      datos['grasa_jackson_pollock'] = double.parse(porcentajeJackson.toStringAsFixed(2));
      datos['grasa_faulkner'] = double.parse(porcentajeFaulkner.toStringAsFixed(2));


      await AntropometriaService.guardarMedidas(
        jugadorId: widget.jugadorId,
        datos: datos,
        creadoPor: widget.creadoPor,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Porcentajes de grasa'),
          content: Text(
            'Jackson & Pollock: ${porcentajeJackson.toStringAsFixed(1)}%'
            'Faulkner: ${porcentajeFaulkner.toStringAsFixed(1)}%',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            )
          ],
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los datos')),
      );
    }
  }

  double calcularPorcentajeGrasaJacksonPollock7({required Map<String, double> pliegues, required int edad}) {
    final suma = pliegues.values.reduce((a, b) => a + b);
    final densidad = 1.112 -
        0.00043499 * suma +
        0.00000055 * suma * suma -
        0.00028826 * edad;
    return (495 / densidad) - 450;
  }

  double calcularPorcentajeGrasaFaulkner({required Map<String, double> pliegues}) {
    final suma = pliegues.values.reduce((a, b) => a + b);
    return suma * 0.153 + 5.783;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo estudio - ${widget.nombreJugador}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...camposPrincipales.map((campo) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: _campos[campo],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: campo.replaceAll('_', ' ').toUpperCase(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty && double.tryParse(value.trim()) == null) {
                          return 'Introduce un número válido';
                        }
                        return null;
                      },
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Text('¿Quieres añadir perímetros?'),
                    const SizedBox(width: 8),
                    Switch(
                      value: _incluirPerimetros,
                      onChanged: (valor) {
                        setState(() {
                          _incluirPerimetros = valor;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (_incluirPerimetros)
                ...camposPerimetros.map((campo) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _campos[campo],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: campo.replaceAll('_', ' ').toUpperCase(),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty && double.tryParse(value.trim()) == null) {
                            return 'Introduce un número válido';
                          }
                          return null;
                        },
                      ),
                    )),
              const SizedBox(height: 12),
              TextField(
                controller: _comentariosController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentarios',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
