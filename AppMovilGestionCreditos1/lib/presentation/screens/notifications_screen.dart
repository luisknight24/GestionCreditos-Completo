import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notificacion_dto.dart';
import '../../services/notificacion_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  final _notificacionService = NotificacionService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => _isLoading = true);
    try {
      final notificaciones = await _notificacionService.getNotificaciones();
      _notificacionService.notificacionesNotifier.value = notificaciones;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notificaciones: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _marcarComoLeida(NotificacionDTO notificacion) async {
    if (notificacion.leida) return; // Ya está leída

    try {
      await _notificacionService.marcarComoLeida(notificacion.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación marcada como leída'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Notificaciones',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _cargarNotificaciones(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificacionDTO>?>(
        valueListenable: _notificacionService.notificacionesNotifier,
        builder: (context, notificaciones, child) {
          // Estado de carga
          if (_isLoading && notificaciones == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Sin datos
          if (notificaciones == null || notificaciones.isEmpty) {
            return const Center(
              child: Text("No tienes notificaciones nuevas"),
            );
          }

          return RefreshIndicator(
            onRefresh: _cargarNotificaciones,
            child: ListView.builder(
              itemCount: notificaciones.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final noti = notificaciones[index];
                return Card(
                  elevation: noti.leida ? 0 : 3,
                  color: noti.leida ? Colors.white : Colors.blue[50],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColorPorTipo(noti.tipo),
                      child: Icon(
                        _getIconPorTipo(noti.tipo),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      noti.tipo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: noti.leida ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(noti.mensaje),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(noti.fecha),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: !noti.leida
                        ? IconButton(
                            icon: const Icon(
                              Icons.mark_email_read,
                              color: Colors.blue,
                            ),
                            onPressed: () => _marcarComoLeida(noti),
                            tooltip: 'Marcar como leída',
                          )
                        : const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                    onTap: () => _marcarComoLeida(noti),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo) {
      case "Pago":
        return Colors.green;
      case "Aviso":
        return Colors.orange;
      case "Mora":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconPorTipo(String tipo) {
    switch (tipo) {
      case "Pago":
        return Icons.check_circle_outline;
      case "Aviso":
        return Icons.notifications_active_outlined;
      case "Mora":
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  void dispose() {
    // No cerrar el servicio aquí si se usa globalmente
    super.dispose();
  }
}