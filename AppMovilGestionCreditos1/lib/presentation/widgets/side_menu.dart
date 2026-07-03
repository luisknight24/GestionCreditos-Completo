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
          // --- OPCIÓN MI PERFIL ---
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context); // 1. Cierra el drawer
              context.push('/profile'); // 2. Navega a la pantalla de perfil
            },
          ),

          // --- OPCIÓN CONFIGURACIÓN ---
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

          // --- OPCIÓN CERRAR SESIÓN ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final usuarioService = UsuarioService();

              // Cierra el drawer antes de salir
              Navigator.pop(context);

              await usuarioService.logout(); // 🔥 Limpia storage/tokens

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
    // Definimos colores del tema localmente o los tomas de Theme.of(context)
    final primaryColor = Theme.of(context).primaryColor;
    final primaryDark = const Color(0xFF1A237E); // Tu azul original

    return Drawer(
      elevation: 0, // Quitamos la sombra por defecto para un look más plano
      child: Column(
        children: [
          // 1. HEADER CON DEGRADADO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryDark, primaryColor], // Degradado elegante
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30), // Curva moderna
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar con borde
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF1A237E)),
                  ),
                ),
                const SizedBox(height: 15),
                // Nombre
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Correo
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. LISTA DE OPCIONES (Navegación)
          // Usamos Expanded para que ocupe el espacio disponible
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [

                // Ejemplo de cómo se vería un item activo (Home)
                _DrawerTile(
                  icon: Icons.dashboard_outlined,
                  title: 'Inicio',
                  isActive: true, // Puedes controlar esto según la ruta actual
                  onTap: () => Navigator.pop(context), // Ya estás en home
                ),

                // --- TUS OPCIONES COMENTADAS (Ahora con el nuevo diseño) ---
                /*
                _DrawerTile(
                  icon: Icons.person_outline,
                  title: 'Mi Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),

                _DrawerTile(
                  icon: Icons.settings_outlined,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
                */
              ],
            ),
          ),

          // 3. FOOTER (Cerrar Sesión)
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
            child: Column(
              children: [
                const Divider(), // Línea separadora sutil
                _DrawerTile(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  isLogout: true, // Estilo especial para logout
                  onTap: () async {
                    final usuarioService = UsuarioService();

                    // Mostrar diálogo de confirmación (Opcional pero recomendado)
                    bool confirm = await _mostrarDialogoConfirmacion(context);
                    if (!confirm) return;

                    if(context.mounted) Navigator.pop(context); // Cerrar drawer

                    await usuarioService.logout();

                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Versión 1.0.0",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para confirmar salida
  Future<bool> _mostrarDialogoConfirmacion(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que ingresar tus credenciales nuevamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Salir', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }
}

// --------------------------------------------------------------------------
// WIDGET AUXILIAR PARA LOS ITEMS DEL MENÚ (Para no repetir código)
// --------------------------------------------------------------------------
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
    final theme = Theme.of(context);

    // Colores dinámicos
    final colorIcon = isLogout ? Colors.redAccent : (isActive ? theme.primaryColor : Colors.grey[600]);
    final colorText = isLogout ? Colors.redAccent : (isActive ? theme.primaryColor : Colors.grey[800]);
    final colorBg   = isLogout ? Colors.red.withOpacity(0.05) : (isActive ? theme.primaryColor.withOpacity(0.1) : Colors.transparent);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), // Espacio entre botones
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(10), // Bordes redondeados modernos
      ),
      child: ListTile(
        leading: Icon(icon, color: colorIcon),
        title: Text(
          title,
          style: TextStyle(
            color: colorText,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}