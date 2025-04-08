// lib/core/services/sesion_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Usuario {
  final String id;       // UUID (de auth y usuarios)
  final String nombre;
  final String rol;

  Usuario({required this.id, required this.nombre, required this.rol});

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        id: map['id'],
        nombre: map['nombre'],
        rol: map['rol'],
      );
}

class SesionService {
  static final SupabaseClient _client = Supabase.instance.client;
  static Usuario? _usuarioActual;

  /// Devuelve el usuario activo, leyendo de memoria o SharedPreferences.
  static Future<Usuario?> obtenerUsuarioActivo() async {
    if (_usuarioActual != null) return _usuarioActual;

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('usuario_id');
    final nombre = prefs.getString('usuario_nombre');
    final rol = prefs.getString('usuario_rol');

    if (id != null && nombre != null && rol != null) {
      _usuarioActual = Usuario(id: id, nombre: nombre, rol: rol);
      return _usuarioActual;
    }
    return null;
  }

  /// Obtiene el usuario consultando la tabla "usuarios" por su id (UUID)
  static Future<Usuario?> obtenerUsuarioPorId(String userId) async {
    if (_usuarioActual != null && _usuarioActual!.id == userId) {
      return _usuarioActual;
    }

    final response = await _client
        .from('usuarios')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    _usuarioActual = Usuario.fromMap(response);

    // Guardar en SharedPreferences para persistencia.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_id', _usuarioActual!.id);
    await prefs.setString('usuario_nombre', _usuarioActual!.nombre);
    await prefs.setString('usuario_rol', _usuarioActual!.rol);

    return _usuarioActual;
  }

  /// Obtiene el id entero del jugador desde la tabla "jugadores" usando el usuario_id (UUID)
  static Future<int?> obtenerJugadorIdPorUsuario(String usuarioId) async {
    final response = await _client
        .from('jugadores')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    if (response == null) return null;
    return response['id'] as int;
  }

  /// Similar, para el cuerpo técnico (si lo necesitas)
  static Future<int?> obtenerCuerpoTecnicoIdPorUsuario(String usuarioId) async {
    final response = await _client
        .from('cuerpo_tecnico')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    if (response == null) return null;
    return response['id'] as int;
  }

  /// Cierra la sesión limpiando la caché y SharedPreferences.
  static Future<void> cerrarSesion() async {
    _usuarioActual = null;
    await _client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
