/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/HistoriaAppDTO.dart';
import 'package:signalr_core/signalr_core.dart';
class HistorialService {
  final String baseUrl11 = "https://gestioncreditos-backend.onrender.com/api";
  final String baseUrl1 = "https://gestioncreditos-backend.onrender.com";
   final String baseUrl = "https://gestioncreditos-backend.onrender.com/api";
   // Tu URL
  final storage = const FlutterSecureStorage();
// 🔔 NOTIFICADORES UNIFICADOS
  final historialNotifier = ValueNotifier<List<HistoriaAppDTO>?>(null);
  final cargandoNotifier = ValueNotifier<bool>(false);
  final mensajeNotifier = ValueNotifier<String>("");
int? _creditoIdActual;
  late HubConnection _connection;
   bool _isConnected = false;
  // 🟢 CACHÉ INTERNA
  List<HistoriaAppDTO>? _cacheHistorial;

  // --- SINGLETON ---
  HistorialService._internal() {
    debugPrint("🟣 [HistorialService] instancia creada → hash: $hashCode");
  }

  static final HistorialService _instance = HistorialService._internal();
  factory HistorialService() => _instance;

  // --- SIGNALR ---
  Future<void> connectSignalR() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) return;

    final hubUrl = '$baseUrl1/adminhub';

    _connection = HubConnectionBuilder()
        .withUrl(hubUrl, HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ))
        .withAutomaticReconnect() // Agregado para mejor estabilidad
        .build();

    _connection.on('CreditoActualizado', (args) {
      if (args == null || args.isEmpty) return;
      try {
        final data = Map<String, dynamic>.from(args.first);
        final creditoActualizado = HistoriaAppDTO.fromJson(data);

        _actualizarCreditoDesdeEvento(creditoActualizado);
        mensajeNotifier.value = "Estado de crédito actualizado→ $data";

 // Si el crédito actualizado es el que estamos viendo, recargamos
        final creditoIdRecibido = data['id'] ?? data['creditoId'];
        if (creditoIdRecibido == _creditoIdActual) {
          debugPrint("🔄 Recargando historial porque el crédito actual fue actualizado");
          getHistorialPagos(creditoId: _creditoIdActual!, forceRefresh: true);
        }
      } catch (e) {
        debugPrint("❌ Error en evento SignalR: $e");
      }
    });

    try {
      await _connection.start();
      debugPrint("✅ SignalR CONECTADO");
    } catch (e) {
      debugPrint("❌ Error al conectar SignalR: $e");
    }
  }






  Future<void> getHistorialPagos1({required int creditoId,bool forceRefresh = false}) async {
    cargandoNotifier.value = true;

    // Si ya tenemos datos y no forzamos, no recargamos (Opcional)
    // if (historialNotifier.value != null && !forceRefresh) {
    //   cargandoNotifier.value = false;
    //   return;
    // }

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) throw Exception("Sin autenticación");

      // 📝 Endpoint Maquetado: Ajusta la ruta según tu API real
      final url = Uri.parse('$baseUrl/Credito/calendario/$creditoId');

      debugPrint("🔵 Consultando historial: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        // Mapeamos la lista
        final listaHistorial = decoded.map((e) => HistoriaAppDTO.fromJson(e)).toList();

        // Actualizamos el estado
        historialNotifier.value = listaHistorial;
      } else {
        debugPrint("❌ Error API Historial: ${response.statusCode}");
        // Si falla, podrías limpiar o manejar error
        // historialNotifier.value = [];
      }
    } catch (e) {
      debugPrint("❌ Error servicio historial: $e");
      // MOCK DE RESPALDO PARA PRUEBAS VISUALES SI FALLA LA RED
      await Future.delayed(const Duration(seconds: 1));
      historialNotifier.value = [
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-15", montoPendiente: 150.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-22", montoPendiente: 100.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-29", montoPendiente: 50.00, abonadoCuota: 50.00, estadoCuota: "Pendiente", clienteId: 1),
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-11-05", montoPendiente: 0.00, abonadoCuota: 0.00, estadoCuota: "Vencida", clienteId: 1),
      ];
    } finally {
      cargandoNotifier.value = false;
    }
  }


// --- OBTENER HISTORIAL ---
  Future<void> getHistorialPagos({
    required int creditoId,
    bool forceRefresh = false,
  }) async {
    cargandoNotifier.value = true;
    _creditoIdActual = creditoId; // 🔥 Guardamos el crédito actual

    // Optimización: usar caché si existe y no forzamos recarga
    if (!forceRefresh && _cacheHistorial != null && _cacheHistorial!.isNotEmpty) {
      historialNotifier.value = _cacheHistorial;
      cargandoNotifier.value = false;
      debugPrint("📦 Usando caché para crédito $creditoId");
      return;
    }

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) throw Exception("Sin autenticación");

      final url = Uri.parse('$baseUrl/Credito/calendario/$creditoId');
      debugPrint("🔵 Consultando historial: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        final listaHistorial = decoded
            .map((e) => HistoriaAppDTO.fromJson(e))
            .toList();

        // 🔥 Actualizamos AMBOS: caché y notificador
        _cacheHistorial = listaHistorial;
        historialNotifier.value = listaHistorial;

        debugPrint("✅ Historial cargado: ${listaHistorial.length} cuotas");

        // 🔥 Conectar SignalR después de cargar datos
        if (!_isConnected) {
          await connectSignalR();
        }
      } else {
        debugPrint("❌ Error API Historial: ${response.statusCode}");
        throw Exception("Error al cargar historial");
      }
    } catch (e) {
      debugPrint("❌ Error servicio historial: $e");
      mensajeNotifier.value = "Error al cargar historial";
      
      // MOCK DE RESPALDO (solo en desarrollo)
      await Future.delayed(const Duration(seconds: 1));
      _cacheHistorial = [
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-15", montoPendiente: 150.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 2, proximaCuotaStr: "2023-10-22", montoPendiente: 100.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 3, proximaCuotaStr: "2023-10-29", montoPendiente: 50.00, abonadoCuota: 50.00, estadoCuota: "Pendiente", clienteId: 1),
        HistoriaAppDTO(id: 4, proximaCuotaStr: "2023-11-05", montoPendiente: 0.00, abonadoCuota: 0.00, estadoCuota: "Vencida", clienteId: 1),
      ];
      historialNotifier.value = _cacheHistorial;
    } finally {
      cargandoNotifier.value = false;
    }
  }

  // --- LÓGICA DE ACTUALIZACIÓN ---
  void _actualizarCreditoDesdeEvento(HistoriaAppDTO nuevo) {
    if (_cacheHistorial == null) return;

    // Buscamos si el crédito existe en nuestra lista actual
    final index = _cacheHistorial!.indexWhere((c) => c.id == nuevo.id);
    
    if (index != -1) {
      _cacheHistorial![index] = nuevo;
      // Emitimos la nueva lista a la UI
      historialNotifier.value = List.from(_cacheHistorial!);
      debugPrint("✅ UI Sincronizada con SignalR (ID: ${nuevo.id})");
    }
  }
/// 🧹 LIMPIAR ESTADO AL CAMBIAR DE USUARIO
// --- LIMPIEZA ---
  Future<void> limpiar() async {
    debugPrint("🧹 Limpiando HistorialService");
    try {
      if (_connection.state == HubConnectionState.connected) {
        await _connection.stop();
      }
    } catch (_) {}

    _cacheHistorial = null;
    historialNotifier.value = null;
    mensajeNotifier.value = "";
    cargandoNotifier.value = false;
  }
bool get isSignalRConnected => _isConnected;
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/HistoriaAppDTO.dart';
import 'package:signalr_core/signalr_core.dart';

class HistorialService {
  final String baseUrl11 = "https://gestioncreditos-backend.onrender.com/api";
  final String baseUrl1 = "https://gestioncreditos-backend.onrender.com";
  final String baseUrl = "https://gestioncreditos-backend.onrender.com/api";
  final storage = const FlutterSecureStorage();

  // 🔔 NOTIFICADORES UNIFICADOS
  final historialNotifier = ValueNotifier<List<HistoriaAppDTO>?>(null);
  final cargandoNotifier = ValueNotifier<bool>(false);
  final mensajeNotifier = ValueNotifier<String>("");
  
  int? _creditoIdActual;
  late HubConnection _connection;
  bool _isConnected = false;
  
  // 🟢 CACHÉ INTERNA
  List<HistoriaAppDTO>? _cacheHistorial;

  // 🔴 CONTROL DE RECARGA PARA EVITAR BUCLE INFINITO
  bool _estaCargando = false;
  DateTime? _ultimaCarga;

  // --- SINGLETON ---
  HistorialService._internal() {
    debugPrint("🟣 [HistorialService] instancia creada → hash: $hashCode");
  }

  static final HistorialService _instance = HistorialService._internal();
  factory HistorialService() => _instance;

  // --- SIGNALR ---
  Future<void> connectSignalR() async {
    if (_isConnected) {
      debugPrint("⚠️ [HISTORIAL] SignalR ya está conectado");
      return;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      debugPrint("❌ [HISTORIAL] No hay token, no se puede conectar SignalR");
      return;
    }

    final hubUrl = '$baseUrl1/adminhub';

    try {
      _connection = HubConnectionBuilder()
          .withUrl(hubUrl, HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ))
          .withAutomaticReconnect()
          .build();

      _connection.on('CreditoActualizado', (args) {
        if (args == null || args.isEmpty) return;
        
        try {
          final data = Map<String, dynamic>.from(args.first);
          
          // 🔴 FILTRAR: Solo procesar si es del crédito actual
          final creditoIdRecibido = data['id'] ?? data['creditoId'];
          
          if (creditoIdRecibido != _creditoIdActual) {
            debugPrint("⚠️ [HISTORIAL] Evento ignorado, no es del crédito actual");
            return;
          }

          // 🔴 DEBOUNCE: Evitar recargas múltiples
          final ahora = DateTime.now();
          if (_ultimaCarga != null && 
              ahora.difference(_ultimaCarga!).inSeconds < 3) {
            debugPrint("⚠️ [HISTORIAL] Recarga muy reciente (${ahora.difference(_ultimaCarga!).inSeconds}s), ignorando");
            return;
          }

          // 🔴 EVITAR SI YA ESTÁ CARGANDO
          if (_estaCargando) {
            debugPrint("⚠️ [HISTORIAL] Ya hay una carga en proceso, ignorando");
            return;
          }

          debugPrint("📡 [HISTORIAL] Evento recibido para crédito: $creditoIdRecibido");
          debugPrint("🔄 [HISTORIAL] Recargando historial...");
          
          _ultimaCarga = ahora;
          
          // Recargar después de un pequeño delay para agrupar múltiples eventos
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_creditoIdActual != null) {
              getHistorialPagos(creditoId: _creditoIdActual!, forceRefresh: true);
            }
          });

        } catch (e) {
          debugPrint("❌ [HISTORIAL] Error procesando evento SignalR: $e");
        }
      });

      await _connection.start();
      _isConnected = true;
      debugPrint("✅ [HISTORIAL] SignalR CONECTADO");
      
    } catch (e) {
      debugPrint("❌ [HISTORIAL] Error al conectar SignalR: $e");
      _isConnected = false;
    }
  }

  // --- OBTENER HISTORIAL ---
  Future<void> getHistorialPagos({
    required int creditoId,
    bool forceRefresh = false,
  }) async {
    // 🔴 EVITAR MÚLTIPLES CARGAS SIMULTÁNEAS
    if (_creditoIdActual != creditoId) {
    debugPrint("🔄 [HISTORIAL] El ID cambió de $_creditoIdActual a $creditoId. Limpiando caché anterior.");
    _cacheHistorial = null; // Borramos la caché vieja
    historialNotifier.value = null; // Limpiamos la UI
    forceRefresh = true; // Forzamos la descarga del nuevo crédito
  }
  if (_estaCargando) return;

  
    _estaCargando = true;
    cargandoNotifier.value = true;
    _creditoIdActual = creditoId;

    // Optimización: usar caché si existe y no forzamos recarga
    if (!forceRefresh && _cacheHistorial != null && _cacheHistorial!.isNotEmpty) {
      historialNotifier.value = _cacheHistorial;
      cargandoNotifier.value = false;
      _estaCargando = false;
      debugPrint("📦 [HISTORIAL] Usando caché para crédito $creditoId");
      return;
    }

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) throw Exception("Sin autenticación");

      final url = Uri.parse('$baseUrl/Credito/calendario/$creditoId');
      debugPrint("🔵 [HISTORIAL] Consultando: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        final listaHistorial = decoded
            .map((e) => HistoriaAppDTO.fromJson(e))
            .toList();

        // 🔥 Actualizamos AMBOS: caché y notificador
        _cacheHistorial = listaHistorial;
        historialNotifier.value = listaHistorial;

        debugPrint("✅ [HISTORIAL] Cargado: ${listaHistorial.length} cuotas");

        // 🔥 Conectar SignalR después de cargar datos (solo una vez)
        if (!_isConnected) {
          await connectSignalR();
        }
      } else {
        debugPrint("❌ [HISTORIAL] Error API: ${response.statusCode}");
        throw Exception("Error al cargar historial");
      }
    } catch (e) {
      debugPrint("❌ [HISTORIAL] Error: $e");
      mensajeNotifier.value = "Error al cargar historial";
      
      // MOCK DE RESPALDO (solo en desarrollo)
      await Future.delayed(const Duration(seconds: 1));
      _cacheHistorial = [
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-15", montoPendiente: 150.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 2, proximaCuotaStr: "2023-10-22", montoPendiente: 100.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 3, proximaCuotaStr: "2023-10-29", montoPendiente: 50.00, abonadoCuota: 50.00, estadoCuota: "Pendiente", clienteId: 1),
        HistoriaAppDTO(id: 4, proximaCuotaStr: "2023-11-05", montoPendiente: 0.00, abonadoCuota: 0.00, estadoCuota: "Vencida", clienteId: 1),
      ];
      historialNotifier.value = _cacheHistorial;
    } finally {
      _estaCargando = false;
      cargandoNotifier.value = false;
    }
  }

  // --- DESCONECTAR SIGNALR ---
  Future<void> disconnectSignalR() async {
    if (!_isConnected) return;
    
    try {
      if (_connection.state == HubConnectionState.connected) {
        await _connection.stop();
        _isConnected = false;
        debugPrint("🔴 [HISTORIAL] SignalR desconectado");
      }
    } catch (e) {
      debugPrint("❌ [HISTORIAL] Error desconectando SignalR: $e");
    }
  }

  // --- LIMPIEZA ---
  Future<void> limpiar() async {
    debugPrint("🧹 [HISTORIAL] Limpiando servicio");
    await disconnectSignalR();
    
    _cacheHistorial = null;
    _creditoIdActual = null;
    _ultimaCarga = null;
    _estaCargando = false;
    
    historialNotifier.value = null;
    mensajeNotifier.value = "";
    cargandoNotifier.value = false;
  }

  bool get isSignalRConnected => _isConnected;

  // --- DISPOSE ---
  void dispose() {
    disconnectSignalR();
    historialNotifier.dispose();
    cargandoNotifier.dispose();
    mensajeNotifier.dispose();
  }
}