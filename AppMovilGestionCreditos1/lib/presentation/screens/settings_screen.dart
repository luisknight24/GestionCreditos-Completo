import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificacionesEnabled = true;
  bool _biometriaEnabled = false;
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          _buildSwitchTile(
            title: 'Notificaciones Push',
            subtitle: 'Recibir alertas de pagos y promociones',
            value: _notificacionesEnabled,
            onChanged: (val) {
              setState(() => _notificacionesEnabled = val);
              // TODO: Conectar endpoint de preferencias
            },
            icon: Icons.notifications_active,
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('Seguridad'),
          _buildListTile(
            title: 'Cambiar Contraseña',
            icon: Icons.lock_outline,
            onTap: () {
              // Navegar a pantalla de cambio de contraseña o reset
              context.push('/forgot-password');
            },
          ),
          _buildSwitchTile(
            title: 'Inicio con Biometría',
            subtitle: 'Usar huella/rostro para entrar',
            value: _biometriaEnabled,
            onChanged: (val) {
              setState(() => _biometriaEnabled = val);
              // TODO: Implementar lógica local_auth
            },
            icon: Icons.fingerprint,
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('Soporte e Información'),
          _buildListTile(
            title: 'Términos y Condiciones',
            icon: Icons.description_outlined,
            onTap: () {
              // Abrir webview o dialogo
            },
          ),
          _buildListTile(
            title: 'Política de Privacidad',
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Acerca de CellCompay',
            icon: Icons.info_outline,
            trailing: const Text('v1.0.0', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),

          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () async {
                _mostrarDialogoCerrarSesion(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required IconData icon, VoidCallback? onTap, Widget? trailing}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.blue.shade700),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged, required IconData icon}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.blue.shade700),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: Theme.of(context).primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('Tendrás que ingresar tus credenciales nuevamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Limpiar almacenamiento seguro
              await storage.deleteAll();
              if(context.mounted) context.go('/login');
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}