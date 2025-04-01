import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_futbol_cuestionario/core/services/jugador_service.dart';

class RespuestaService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Guarda la respuesta de un formulario (pre o post)
  static Future<void> guardarRespuesta({
    required int jugadorId,
    required String tipo, // 'pre' o 'post'
    required Map<String, dynamic> datos,
  }) async {
    final now = DateTime.now();
    final fecha = now.toIso8601String().split('T')[0]; // YYYY-MM-DD
    final hora = now.toIso8601String().split('T')[1].split('.')[0]; // HH:mm:ss

    // Buscar si ya existe una respuesta para el jugador en la fecha actual
    final existing = await _client
        .from('respuestas')
        .select()
        .eq('jugador_id', jugadorId)
        .eq('fecha', fecha)
        .maybeSingle();

    final nuevaData = {
      if (tipo == 'pre') ...{
        'sueno': datos['sueno'],
        'estres': datos['estres'],
        'fatiga': datos['fatiga'],
        'dolor_muscular': datos['dolor_muscular'],
        'molestias_pre': datos['molestias_pre'],
        'detalle_molestias_pre': datos['detalle_molestias_pre'],
        'comentarios_pre': datos['comentarios_pre'],
        'respondio_pre': true,
        'hora_pre': hora,
      },
      if (tipo == 'post') ...{
        'esfuerzo': datos['esfuerzo'],
        'forma': datos['forma'],
        'valoracion': datos['valoracion'],
        'molestias_post': datos['molestias_post'],
        'molestias_post_detalle': datos['molestias_post_detalle'],
        'comentarios_post': datos['comentarios_post'],
        'respondio_post': true,
        'hora_post': hora,
      }
    };

    if (existing == null) {
      // Insertar nueva respuesta
      await _client.from('respuestas').insert({
        'jugador_id': jugadorId,
        'fecha': fecha,
        ...nuevaData,
      });
    } else {
      // Actualizar respuesta existente
      await _client
          .from('respuestas')
          .update(nuevaData)
          .eq('id', existing['id']);
    }
  }

  /// Elimina una respuesta específica (pre o post) en Supabase sin borrar toda la fila
  static Future<void> eliminarRespuestaDeSupabase({
    required int jugadorId,
    required String tipo,
  }) async {
    final fecha = DateTime.now().toIso8601String().split('T')[0];

    // Buscar si hay una fila existente
    final existing = await _client
        .from('respuestas')
        .select()
        .eq('jugador_id', jugadorId)
        .eq('fecha', fecha)
        .maybeSingle();

    if (existing == null) return;

    final camposAResetear = {
      if (tipo == 'pre') ...{
        'sueno': null,
        'estres': null,
        'fatiga': null,
        'dolor_muscular': null,
        'molestias_pre': null,
        'detalle_molestias_pre': null,
        'comentarios_pre': null,
        'hora_pre': null,
        'respondio_pre': false,
      },
      if (tipo == 'post') ...{
        'esfuerzo': null,
        'forma': null,
        'valoracion': null,
        'molestias_post': null,
        'molestias_post_detalle': null,
        'comentarios_post': null,
        'hora_post': null,
        'respondio_post': false,
      }
    };

    // Aplicar reset
    await _client
        .from('respuestas')
        .update(camposAResetear)
        .eq('id', existing['id']);

    // Verificar si ya no queda ningún formulario respondido
    final quedoPre = (tipo == 'post') ? existing['respondio_pre'] == true : false;
    final quedoPost = (tipo == 'pre') ? existing['respondio_post'] == true : false;

    if (!quedoPre && !quedoPost) {
      await _client
          .from('respuestas')
          .delete()
          .eq('id', existing['id']);
    }
  }

  /// Obtiene el ID del jugador a partir de su nombre
  static Future<int?> obtenerIdJugadorPorNombre(String nombre) async {
    final jugadores = await JugadorService.obtenerJugadores();
    final jugador = jugadores.firstWhere(
      (j) => j['nombre'] == nombre,
      orElse: () => {},
    );
    return jugador['id'] as int?;
  }
}
