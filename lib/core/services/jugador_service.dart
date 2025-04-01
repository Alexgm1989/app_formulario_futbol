import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JugadorService {
  static const _cacheKey = 'jugadores_cache';
  static const _cacheDateKey = 'jugadores_cache_fecha';
  static const _diasValidez = 7;

  static final _supabase = Supabase.instance.client;

  /// Devuelve la lista de jugadores desde caché o Supabase si es necesario
  static Future<List<Map<String, dynamic>>> obtenerJugadores() async {
    final prefs = await SharedPreferences.getInstance();

    final fechaCacheStr = prefs.getString(_cacheDateKey);
    final ahora = DateTime.now();

    if (fechaCacheStr != null) {
      final fechaCache = DateTime.tryParse(fechaCacheStr);
      if (fechaCache != null && ahora.difference(fechaCache).inDays < _diasValidez) {
        final cache = prefs.getString(_cacheKey);
        if (cache != null) {
          final decoded = jsonDecode(cache);
          return List<Map<String, dynamic>>.from(decoded);
        }
      }
    }

    return await actualizarCache();
  }

  /// Fuerza la descarga de jugadores desde Supabase y actualiza el caché
  static Future<List<Map<String, dynamic>>> actualizarCache() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await _supabase
        .from('jugadores')
        .select()
        .eq('activo', true)
        .order('nombre', ascending: true);

    final jugadores = List<Map<String, dynamic>>.from(response);
    prefs.setString(_cacheKey, jsonEncode(jugadores));
    prefs.setString(_cacheDateKey, DateTime.now().toIso8601String());

    return jugadores;
  }

  /// Borra el caché manualmente (opcional)
  static Future<void> limpiarCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheDateKey);
  }
}
