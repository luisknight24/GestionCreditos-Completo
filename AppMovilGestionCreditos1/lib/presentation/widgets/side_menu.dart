/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/usuario_service.dart';

class SideMenu extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SideMenu({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E), // Azul primario
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF1A237E)),
            ),
            accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(userEmail),
          ),

          /*
          
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context); // 1. Cierra el drawer
              context.push('/profile'); // 2. Navega a la pantalla de perfil
            },
          ),

          
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context); // 1. Cierra el drawer
              context.push('/settings'); // 2. Navega a la pantalla de configuración
            },
          ),
        */
          const Divider(),

          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final usuarioService = UsuarioService();

              // Cierra el drawer antes de salir
              Navigator.pop(context);

              await usuarioService.logout(); //  Limpia storage/tokens

              if (context.mounted) {
                context.go('/login'); // Redirige al login borrando el historial
              }
            },
          ),
        ],
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/usuario_service.dart';

class SideMenu extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SideMenu({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF090D16),
      elevation: 16,
      child: Column(
        children: [
          // 1. HEADER CON GRADIENTE OSCURO ELEGANTE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 55, bottom: 25, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(32),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar con anillo verde esmeralda
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF0284C7)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFF0F172A),
                    child: Icon(Icons.person_rounded, size: 38, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Correo
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. LISTA DE OPCIONES DE NAVEGACIÓN
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _DrawerTile(
                  icon: Icons.dashboard_rounded,
                  title: 'Inicio',
                  isActive: true,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 3. FOOTER (Cerrar Sesión)
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 14, right: 14),
            child: Column(
              children: [
                Divider(color: Colors.white.withOpacity(0.08)),
                const SizedBox(height: 8),
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión',
                  isLogout: true,
                  onTap: () async {
                    final usuarioService = UsuarioService();

                    bool confirm = await _mostrarDialogoConfirmacion(context);
                    if (!confirm) return;

                    if (context.mounted) Navigator.pop(context);

                    await usuarioService.logout();

                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  "Versión 1.0.0",
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _mostrarDialogoConfirmacion(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                SizedBox(width: 10),
                Text('¿Cerrar sesión?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: const Text(
              'Tendrás que ingresar tus credenciales nuevamente.',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final bool isLogout;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorIcon = isLogout
        ? const Color(0xFFF87171)
        : (isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8));
    final colorText = isLogout
        ? const Color(0xFFF87171)
        : (isActive ? Colors.white : const Color(0xFFCBD5E1));
    final colorBg = isLogout
        ? const Color(0xFFEF4444).withOpacity(0.12)
        : (isActive ? const Color(0xFF10B981).withOpacity(0.15) : Colors.transparent);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: const Color(0xFF10B981).withOpacity(0.3))
            : (isLogout ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)) : null),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorIcon, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: colorText,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14.5,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}