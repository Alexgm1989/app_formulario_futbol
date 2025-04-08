import 'package:supabase_flutter/supabase_flutter.dart';

class AntropometriaService {
  static final _client = Supabase.instance.client;

  static Future<void> guardarMedidas({
    required int jugadorId,
    required Map<String, dynamic> datos,
    required String creadoPor,
  }) async {
    datos['jugador_id'] = jugadorId;
    datos['creado_por'] = creadoPor;

    try {
      await _client.from('antropometria').insert(datos);
    } catch (e) {
      print('Error Supabase: $e');
      throw Exception('Error al insertar en Supabase: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerHistorialJugador(int jugadorId) async {
    final response = await _client
        .from('antropometria')
        .select()
        .eq('jugador_id', jugadorId)
        .order('fecha', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<bool> yaRegistroHoy(int jugadorId) async {
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('antropometria')
        .select('id')
        .eq('jugador_id', jugadorId)
        .eq('fecha', hoy)
        .maybeSingle();

    return response != null;
  }

  // Método que obtiene los registros del día (con los campos necesarios)
  static Future<List<Map<String, dynamic>>> obtenerRegistrosDelDia() async {
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('antropometria')
        .select('''
          jugador_id,
          fecha,
          peso,
          pliegue_triceps,
          pliegue_subescapular,
          pliegue_suprailiaco,
          pliegue_abdominal,
          pliegue_muslo_anterior,
          pliegue_pectoral,
          pliegue_pantorrilla_medial,
          grasa_jackson_pollock,
          grasa_faulkner,
          jugadores ( nombre )
        ''')
        .eq('fecha', hoy)
        .order('fecha', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Método para obtener el último registro anterior al día actual para un jugador
  static Future<Map<String, dynamic>?> obtenerUltimoRegistro(int jugadorId, String fechaHoy) async {
    final response = await _client
        .from('antropometria')
        .select('grasa_faulkner')
        .eq('jugador_id', jugadorId)
        .lt('fecha', fechaHoy)
        .order('fecha', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }

  // Método que obtiene los registros del día y añade la variación del porcentaje de grasa (Faulkner)
  static Future<List<Map<String, dynamic>>> obtenerRegistrosConVariacion() async {
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    final registros = await obtenerRegistrosDelDia();
    // Para cada registro, obtener el último registro anterior y calcular la variación
    await Future.wait(registros.map((registro) async {
      final jugadorId = registro['jugador_id'];
      final ultimo = await obtenerUltimoRegistro(jugadorId, hoy);
      double? variacion;
      if (ultimo != null && ultimo['grasa_faulkner'] != null && registro['grasa_faulkner'] != null) {
        variacion = (registro['grasa_faulkner'] as num).toDouble() - (ultimo['grasa_faulkner'] as num).toDouble();
      }
      registro['variacion_faulkner'] = variacion;
    }));
    return registros;
  }
}
