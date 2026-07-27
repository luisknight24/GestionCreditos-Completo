import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:trabajo1/services/historial_service.dart';
import '../../models/credito_dto.dart';
 import '../../models/tienda_dto.dart'; //  COMENTADO: Tienda
import '../../models/CreditoMostrarDTO.dart';
import '../widgets/credit_summary_card.dart';
import '../widgets/side_menu.dart';
import '../../services/creditoMostrarHome.dart';
 import '../../services/tiendaService.dart'; //  COMENTADO: Tienda
import '../../models/tiendaMostrar_dto.dart'; //  COMENTADO: Tienda
import '../../services/usuario_service.dart';
import '../../models/ClienteMostrarDTO.dart';
import '../../services/location_service.dart';
import 'new_credit_request_screen.dart';

import '../../services/notificacion_service.dart';
import '../../models/notificacion_dto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
// 1. Define una variable booleana fuera del método (en el State o el Servicio)
bool _estaProcesandoRecarga = false;
class _HomeScreenState extends State<HomeScreen> {
  // DATOS FICTICIOS PARA MAQUETACIÓN (MOCKS)
  // Luego esto vendrá de tu API con un FutureBuilder o Provider
  final creditoMostrarHome _creditoService = creditoMostrarHome();
  late Future<List<CreditoMostrarDTO>> _futureCreditos;
  late Future<void> _futureCreditos1;
  final NotificacionService _notificacionService = NotificacionService();
  final HistorialService _historialService = HistorialService();
  final TiendaService _tiendaService = TiendaService();
  late Future<List<TiendaMostrarAppVentaDTO>> _Tiendas;

  //late Future<void> _Tiendas1;

  final UsuarioService _clienteService = UsuarioService();
  late Future<ClienteMostrarDTO> _futureClientes;
  CreditoMostrarDTO? creditoActual;
  final LocationService _locationService = LocationService();

  //final String _nombreUsuario = "aszcsz";
  final String _emailUsuario = "luis@ejemplo.com";

  /*  COMENTADO: Mock de Tienda
  final TiendaDTO _tiendaMock = TiendaDTO(
    nombreTienda: "Celulares El Centro",
    nombreEncargado: "Luis",
    telefono: "0999999999",
    direccion: "Av. Principal 123",
    //  fechaRegistro: DateTime.now(),
  );
  */
  // final creditoServicio = creditoMostrarHome();
 //  AGREGAR ESTE FLAG PARA EVITAR RECARGAS MÚLTIPLES
  bool _estaProcesandoRecarga = false;
  DateTime? _ultimaRecarga;
  bool _isRedirectingToLogin = false;

  void _redirectToLogin(BuildContext context) {
    if (_isRedirectingToLogin) return;
    _isRedirectingToLogin = true;

    final storage = FlutterSecureStorage();
    storage.deleteAll();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Tu sesión ha caducado. Por favor, inicia sesión nuevamente.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      context.go('/login');
    }
  }

  void _checkSessionToken() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _redirectToLogin(context);
      });
    }
  }

  @override
  void initState() {
   // A. Inicializar Futuros de datos inmediatos (Sin lógica de red pesada aquí)
   super.initState();
    debugPrint(
      " [HOME] usando instancia → hash: ${_creditoService.hashCode}",
    );

    _checkSessionToken();

    // _Tiendas = _tiendaService.getTienda(); //  COMENTADO: Carga inicial Tienda
    _futureClientes = _clienteService.getCliente();

    debugPrint(" [HOME] carga inicial créditos");
    // _futureCreditos1 = _creditoService.getCreditos(); // carga inicial
    //_creditoService.connectSignalR();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      debugPrint(" [HOME] extra recibido: ${state.extra}");
      if (state.extra == true) {
        debugPrint(" [HOME] FORZANDO REFRESH DE CRÉDITOS");
        _creditoService.cargarCreditos();
      }
    });
    _futureCreditos1 = _creditoService.getCreditos(); // carga inicial
    _creditoService.connectSignalR();
    _notificacionService.connectSignalR();
    //  CARGAR NOTIFICACIONES AL INICIO
    _cargarNotificaciones();
_historialService.connectSignalR();
    // 3. EJECUTAR RASTREO EN SEGUNDO PLANO (Sin await para no bloquear la UI)
    _locationService.sendCurrentLocation();
  }


  //  FUNCIÓN NUEVA: Obtiene el conteo del servicio
  Future<void> _cargarNotificaciones() async {
    try {
      debugPrint(" [HOME] Iniciando notificaciones...");
      // await _notificacionService.connectSignalR();
      debugPrint(" [HOME] SignalR de notificaciones conectado");
      final notificaciones = await _notificacionService.getNotificaciones();
      _notificacionService.notificacionesNotifier.value = notificaciones;
      debugPrint(" [HOME] ${notificaciones.length} notificaciones cargadas");

    } catch (e) {
      print("Error cargando notificaciones badge: $e");
      if (e.toString().contains("Token no encontrado") || e.toString().contains("autenticado")) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin(context));
      }
    }
  }

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace $url');
    }
  }

  Future<void> _initCreditoFlow() async {
    await _creditoService.connectSignalR(); // ⏳ esperar conexión
    //_futureCreditos = _creditoService.getCreditos();
    _futureCreditos1 = _creditoService.getCreditos();
  }

  Future<void> _refreshCreditos() async {
    _futureCreditos1 = _creditoService.getCreditos();
    await _futureCreditos1;
  }

  //  COMENTADO: Función Refrescar Tienda
  Future<void> _refreshTienda() async {
    _Tiendas = _tiendaService.getTienda();
    await _Tiendas;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: const Text(
          'Resumen de crédito',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // BADGE REACTIVO CON ValueListenableBuilder
          ValueListenableBuilder<List<NotificacionDTO>?>(
            valueListenable: _notificacionService.notificacionesNotifier,
            builder: (context, notificaciones, child) {
              final noLeidas = notificaciones?.where((n) => !n.leida).length ?? 0;

              return IconButton(
                icon: Badge(
                  isLabelVisible: noLeidas > 0,
                  label: Text('$noLeidas'),
                  backgroundColor: const Color(0xFFEF4444),
                  child: const Icon(Icons.notifications_none_rounded, size: 24),
                ),
                onPressed: () async {
                  await context.push('/notifications');
                  try {
                    final actualizadas = await _notificacionService.getNotificaciones(forceRefresh: true);
                    _notificacionService.notificacionesNotifier.value = actualizadas;
                  } catch (e) {
                    debugPrint("Error recargando notificaciones: $e");
                  }
                },
              );
            },
          ),
        ],
      ),
      drawer: FutureBuilder<ClienteMostrarDTO>(
        future: _futureClientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer();
          }

          if (snapshot.hasError) {
            final errStr = snapshot.error.toString();
            if (errStr.contains('Token no encontrado') || errStr.contains('401') || errStr.contains('autenticado')) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin(context));
              return const Drawer();
            }
            return Drawer(
              child: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          final usuario = snapshot.data!;
          return SideMenu(
            userName: usuario.nombreApellidos,
            userEmail: usuario.correo,
          );
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<ClienteMostrarDTO>(
              future: _futureClientes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                }

                if (snapshot.hasError) {
                  final errStr = snapshot.error.toString();
                  if (errStr.contains('Token no encontrado') || errStr.contains('401') || errStr.contains('autenticado')) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin(context));
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                  }
                  return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                }

                if (!snapshot.hasData) {
                  return const Text('No se encontraron datos del usuario', style: TextStyle(color: Colors.white));
                }

                String saludo = 'Hola, usuario';
                if (snapshot.hasData) {
                  saludo = 'Hola, ${snapshot.data!.nombreApellidos}';
                }
                return FadeInDown(
                  child: Text(
                    saludo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 4),
            FadeInDown(
              child: const Text(
                'Aquí está el resumen de tu crédito activo',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13.5),
              ),
            ),

            const SizedBox(height: 20),

            ValueListenableBuilder<List<CreditoMostrarDTO>?>(
              valueListenable: _creditoService.creditosNotifier,
              builder: (context, creditos, _) {
                if (creditos == null) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                }

                if (creditos.isEmpty) {
                  return Column(
                    children: [
                      const Text('No tienes créditos activos.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      _NewCreditRequestCard(
                        isPaid: true,
                        onTap: () async {
                          context.push('/new-credit-request');
                        },
                      ),
                    ],
                  );
                }

                final credito = creditos.first;
                final bool estaPagado = credito.montoPendiente <= 0;

                return Column(
                  children: [
                    CreditSummaryCard(credito: credito),

                    const SizedBox(height: 16),

                    FadeInUp(
                      child: GestureDetector(
                        onTap: () {
                          context.push('/payment-history/${credito.id}');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Text(
                                "Ver historial de pagos",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _NewCreditRequestCard(
                      isPaid: estaPagado,
                      onTap: () async {
                        await context.push('/new-credit-request');
                        await _refreshCreditos();
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 25),

            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                  ),
                  children: [
                    TextSpan(
                      text: "Crédito financiado por ",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: "CELLCOM",
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "PAY",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _QuickActionBtn(
                      icon: Icons.language_rounded,
                      label: 'Página web',
                      color: const Color(0xFF38BDF8),
                      onTap: () {
                        _abrirEnlace('https://www.cellcompayec.com');
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _QuickActionBtn(
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'Soporte',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        _abrirEnlace('https://wa.me/593982327250');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para botones rápidos
class _QuickActionBtn extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xEE0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            icon is IconData
                ? Icon(icon as IconData, color: color, size: 28)
                : FaIcon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCreditRequestCard extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onTap;

  const _NewCreditRequestCard({required this.isPaid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPaid ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xEE0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPaid ? const Color(0xFF10B981).withOpacity(0.4) : Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFF10B981).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_card_rounded,
                  color: isPaid ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitar nuevo crédito',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPaid
                          ? '¡Estás listo para renovar tu equipo!'
                          : 'Termina de pagar tu crédito actual para desbloquear.',
                      style: TextStyle(
                        color: isPaid ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPaid)
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF10B981), size: 16)
              else
                const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
