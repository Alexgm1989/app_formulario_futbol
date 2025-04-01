import 'package:shared_preferences/shared_preferences.dart';

class RespuestaStorage {
  static String _claveRespuesta(String jugador, String tipo, DateTime fecha) {
    final fechaStr = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    return '$jugador-${tipo.toLowerCase()}-$fechaStr';
  }

  static Future<void> guardarRespuesta({
    required String jugador,
    required String tipo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final clave = _claveRespuesta(jugador, tipo, DateTime.now());
    await prefs.setBool(clave, true);
  }

  static Future<bool> yaRespondio({
    required String jugador,
    required String tipo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final clave = _claveRespuesta(jugador, tipo, DateTime.now());
    return prefs.getBool(clave) ?? false;
  }

  static Future<void> eliminarRespuestaDelJugador({
    required String jugador,
    required String tipo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final clave = _claveRespuesta(jugador, tipo, DateTime.now());
    await prefs.remove(clave);
  }

  static Future<void> resetearTodasLasRespuestas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
