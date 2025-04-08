import 'package:flutter/material.dart';
import 'package:app_futbol_cuestionario/modules/auth/screens/login_screen.dart';
import 'package:app_futbol_cuestionario/core/services/sesion_service.dart';

class AppBarUsuario extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String usuarioNombre;

  const AppBarUsuario({
    Key? key,
    required this.title,
    required this.usuarioNombre,
  }) : super(key: key);

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
      title: Row(
        children: [
          Image.asset(
            'assets/images/escudo_club.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Text(
              usuarioNombre,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') _logout(context);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Text('Cerrar sesión'),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
