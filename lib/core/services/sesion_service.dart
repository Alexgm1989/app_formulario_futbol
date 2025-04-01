import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Usuario {
  final String id;
  final String nombre;
  final String rol;

  Usuario({required this.id, required this.nombre, required this.rol});

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'rol': rol,
      };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        id: map['id'],
        nombre: map['nombre'],
        rol: map['rol'],
      );
}

class SesionService {
  static final SupabaseClient _client = Supabase.instance.client;
  static Usuario? _usuarioActual;

  static Future<Usuario?> iniciarSesionConPin(String pin) async {
    final result = await _client
        .from('usuarios')
        .select()
        .eq('pin', pin)
        .eq('activo', true)
        .maybeSingle();

    if (result == null) return null;

    _usuarioActual = Usuario(
      id: result['id'],
      nombre: result['nombre'],
      rol: result['rol'],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_id', _usuarioActual!.id);
    await prefs.setString('usuario_nombre', _usuarioActual!.nombre);
    await prefs.setString('usuario_rol', _usuarioActual!.rol);

    return _usuarioActual;
  }

  static Future<void> cerrarSesion() async {
    _usuarioActual = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

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

  static Usuario? get usuarioActual => _usuarioActual;
}
