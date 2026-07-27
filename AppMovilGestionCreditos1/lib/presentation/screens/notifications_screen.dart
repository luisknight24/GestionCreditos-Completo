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
      notificaciones.sort((a, b) => b.fecha.compareTo(a.fecha));
      _notificacionService.notificacionesNotifier.value = notificaciones;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar notificaciones: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _marcarComoLeida(NotificacionDTO notificacion) async {
    if (notificacion.leida) return;

    try {
      await _notificacionService.marcarComoLeida(notificacion.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación marcada como leída'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: const Text(
          'Mis notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF10B981)),
            onPressed: () => _cargarNotificaciones(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificacionDTO>?>(
        valueListenable: _notificacionService.notificacionesNotifier,
        builder: (context, notificaciones, child) {
          if (_isLoading && notificaciones == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          if (notificaciones == null || notificaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No tienes notificaciones nuevas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Te avisaremos cuando haya novedades en tus créditos.",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF10B981),
            backgroundColor: const Color(0xFF1E293B),
            onRefresh: _cargarNotificaciones,
            child: ListView.builder(
              itemCount: notificaciones.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                final noti = notificaciones[index];
                final color = _getColorPorTipo(noti.tipo);
                final icon = _getIconPorTipo(noti.tipo);
                final titulo = _getTituloPorTipo(noti.tipo);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: noti.leida
                        ? const Color(0x660F172A)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: noti.leida
                          ? Colors.white.withOpacity(0.06)
                          : color.withOpacity(0.4),
                      width: noti.leida ? 1 : 1.5,
                    ),
                    boxShadow: noti.leida
                        ? []
                        : [
                            BoxShadow(
                              color: color.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _marcarComoLeida(noti),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: Icon(
                                icon,
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        titulo,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                          color: noti.leida
                                              ? const Color(0xFFCBD5E1)
                                              : Colors.white,
                                        ),
                                      ),
                                      if (!noti.leida)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: color.withOpacity(0.5)),
                                          ),
                                          child: const Text(
                                            'Nueva',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    noti.mensaje,
                                    style: TextStyle(
                                      color: noti.leida
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFFE2E8F0),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm')
                                            .format(noti.fecha),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
      case "PagoRealizado":
      case "Pago":
        return const Color(0xFF10B981); // Verde Esmeralda
      case "Recordatorio5Dias":
        return const Color(0xFF0284C7); // Azul Cielo
      case "Recordatorio3Dias":
        return const Color(0xFFF59E0B); // Ámbar
      case "Recordatorio2Dias":
        return const Color(0xFFF97316); // Naranja
      case "PagoHoy":
      case "PagoMañana":
        return const Color(0xFFFACC15); // Amarillo
      case "Moroso":
      case "Mora":
        return const Color(0xFFEF4444); // Rojo
      default:
        return const Color(0xFF38BDF8); // Azul
    }
  }

  IconData _getIconPorTipo(String tipo) {
    switch (tipo) {
      case "PagoRealizado":
      case "Pago":
        return Icons.check_circle_rounded;
      case "Recordatorio5Dias":
        return Icons.calendar_today_rounded;
      case "Recordatorio3Dias":
        return Icons.notifications_active_rounded;
      case "Recordatorio2Dias":
        return Icons.access_time_filled_rounded;
      case "PagoHoy":
      case "PagoMañana":
        return Icons.alarm_on_rounded;
      case "Moroso":
      case "Mora":
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getTituloPorTipo(String tipo) {
    switch (tipo) {
      case "PagoRealizado":
      case "Pago":
        return "Pago confirmado";
      case "Recordatorio5Dias":
        return "Recordatorio (5 días)";
      case "Recordatorio3Dias":
        return "Recordatorio (3 días)";
      case "Recordatorio2Dias":
        return "Próximo vencimiento (2 días)";
      case "PagoHoy":
        return "¡Hoy vence tu cuota!";
      case "PagoMañana":
        return "Pago mañana";
      case "Moroso":
      case "Mora":
        return "Atraso en cuota";
      default:
        return "Notificación";
    }
  }
}