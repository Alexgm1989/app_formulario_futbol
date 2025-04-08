// lib/widgets/app_bar_usuario.dart
import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/auth/screens/login_screen.dart';
import 'package:app_futbol_cuestionario/core/services/sesion_service.dart';

class AppBarUsuario extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String usuarioNombre;

  const AppBarUsuario({
    super.key,
    required this.title,
    required this.usuarioNombre,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _logout(BuildContext context) async {
    await SesionService.cerrarSesion();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Se habilita la flecha de retroceso automáticamente cuando es posible
      automaticallyImplyLeading: true,
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(child: Text(usuarioNombre)),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}
