import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/tiendaMostrar_dto.dart';
import 'package:trabajo1/models/tienda_dto.dart';
import 'package:trabajo1/models/tienda_crear_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class TiendaService {
  final String baseUrl1= "https://gestioncreditos-backend.onrender.com/api";
   final String baseUrl = "https://gestioncreditos-backend.onrender.com/api";
 final storage = const FlutterSecureStorage();
  List<TiendaMostrarAppVentaDTO>? _cacheTiendas;
final cargandoNotifier = ValueNotifier<bool>(false);
final tiendasNotifier = ValueNotifier<List<TiendaMostrarAppVentaDTO>?>(null);



 TiendaService._internal() {
    debugPrint("🟣 [TiendaService] instancia creada → hash: $hashCode");
  }

  static final TiendaService _instance = TiendaService._internal();
  factory TiendaService() {

    return _instance;
    
  }


 Future<List<TiendaMostrarAppVentaDTO>> getTienda0() async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/TiendaApp/tiendasApp');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Respuesta API Tiendas: ${response.body}");

  if (response.statusCode == 200) {
   final List decoded = jsonDecode(response.body);
  // final decoded = jsonDecode(response.body);



    return decoded
        .map((item) => TiendaMostrarAppVentaDTO.fromJson(item))
        .toList();
  } else {
    throw Exception("Error al obtener las tiendas: ${response.statusCode}");
  }
}


  
Future<List<TiendaMostrarAppVentaDTO>> getTiendaSinLogs({bool forceRefresh = false}) async {
  debugPrint("🔵 [getTienda] llamado | forceRefresh=$forceRefresh");
  debugPrint("🔵 [getTienda] cache actual: ${_cacheTiendas?.length}");
  cargandoNotifier.value = true;

  try {
    // 1️⃣ Usar cache si no se fuerza refresh
    if (_cacheTiendas != null && !forceRefresh) {
      tiendasNotifier.value = List.unmodifiable(_cacheTiendas!);
      return tiendasNotifier.value!; // ✅ RETORNA LISTA
    }

    // 2️⃣ Leer token
    String? token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Por favor inicia sesión.");
    }

    // 3️⃣ Petición HTTP
    final response = await http.get(
      Uri.parse('$baseUrl/TiendaApp/tiendasAppFechaV'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // 4️⃣ Respuesta
    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      _cacheTiendas = decoded
          .map((e) => TiendaMostrarAppVentaDTO.fromJson(e))
          .toList();

      tiendasNotifier.value = List.unmodifiable(_cacheTiendas!);
      return tiendasNotifier.value!; // ✅ RETORNA LISTA
    }

    if (response.statusCode == 401) {
      await storage.delete(key: 'jwt_token');
      throw Exception("Sesión expirada. Inicia sesión nuevamente.");
    }

    throw Exception("Error API: ${response.statusCode}");

  } catch (e) {
    debugPrint('❌ Error getTienda: $e');
    rethrow;
  } finally {
    cargandoNotifier.value = false;
    debugPrint("🟢 [getTienda] tiendas cargadas: ${tiendasNotifier.value?.length}");
  }
}



Future<List<TiendaMostrarAppVentaDTO>> getTienda({bool forceRefresh = false}) async {
  debugPrint("🚀 [getTienda] INICIO | forceRefresh=$forceRefresh");
  cargandoNotifier.value = true;

  try {
    // 1️⃣ Cache check
    if (_cacheTiendas != null && !forceRefresh) {
      debugPrint("📦 [getTienda] Usando datos de cache");
      tiendasNotifier.value = List.unmodifiable(_cacheTiendas!);
      return tiendasNotifier.value!;
    }

    // 2️⃣ Token check
    debugPrint("🔑 [getTienda] Leyendo token...");
    String? token = await storage.read(key: 'jwt_token');
    if (token == null) {
      debugPrint("⚠️ [getTienda] Token NULL");
      throw Exception("Token no encontrado.");
    }

    // 3️⃣ Request
    final url = '$baseUrl/TiendaApp/tiendasAppFechaV';
    debugPrint("🌐 [getTienda] GET a: $url");
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10)); // ⏱️ Timeout para que no cargue eterno

    debugPrint("📡 [getTienda] Status Code: ${response.statusCode}");
    debugPrint("📄 [getTienda] Body: ${response.body}");

    // 4️⃣ Response Handling
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      
      if (decoded is List) {
        debugPrint("✅ [getTienda] Lista recibida con ${decoded.length} elementos");
        
        _cacheTiendas = decoded.map((e) {
          try {
            return TiendaMostrarAppVentaDTO.fromJson(e);
          } catch (e) {
            debugPrint("❌ [getTienda] Error mapeando un elemento: $e");
            rethrow;
          }
        }).toList();

        tiendasNotifier.value = List.unmodifiable(_cacheTiendas!);
        return tiendasNotifier.value!;
      } else {
        debugPrint("❌ [getTienda] El JSON no es una LISTA, es: ${decoded.runtimeType}");
        throw Exception("Formato de respuesta incorrecto");
      }
    }

    if (response.statusCode == 401) {
      debugPrint("🚫 [getTienda] 401 Unauthorized");
      await storage.delete(key: 'jwt_token');
      throw Exception("Sesión expirada.");
    }

    throw Exception("Error API: ${response.statusCode}");

  } catch (e, stacktrace) {
    debugPrint('🚨 [getTienda] ERROR CRÍTICO: $e');
    debugPrint('📚 [getTienda] STACKTRACE: $stacktrace');
    rethrow;
  } finally {
    // IMPORTANTE: Aseguramos que el estado cambie pase lo que pase
    cargandoNotifier.value = false;
    debugPrint("🏁 [getTienda] FIN DEL PROCESO");
  }
}

  // 🧹 Limpiar caché
  void clearCache() {
    _cacheTiendas = null;
  }


Future<TiendaMostrarAppVentaDTO> GuardarTienda(TiendaAppDTO tienda) async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl1/TiendaApp/GuardarTiendaJWT');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(tienda.toJson()),
  );

  print("Respuesta API Guardar TiendaApp: ${response.body}");

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    if (decoded['status'] == true) {
      // 🔄 Limpiamos caché para que al listar se refresque
      clearCache();

      return TiendaMostrarAppVentaDTO.fromJson(decoded['value']);
    } else {
      throw Exception(decoded['msg']);
    }
  } else {
    throw Exception("Error al guardar tienda: ${response.statusCode}");
  }
}


Future<void> cargarTienda() async {
  await getTienda(forceRefresh: true);
  
}

void _actualizarTiendaDesdeEvento(TiendaMostrarAppVentaDTO nuevaTienda) {
  if (_cacheTiendas == null) return;

  final index = _cacheTiendas!.indexWhere((t) => t.id == nuevaTienda.id);
  if (index == -1) return;

  //final actual = _cacheCreditos![index];
_cacheTiendas![index] = nuevaTienda;
  tiendasNotifier.value = List.from(_cacheTiendas!);
   //debugPrint("✅ Tienda actualizada | id: ${nuevaTienda.id} | nombre: ${nuevaTienda.nombreEncargado}");
}

/// 🧹 LIMPIAR ESTADO AL CAMBIAR DE USUARIO
Future<void> limpiar() async {
  debugPrint("🧹 [creditoMostrarHome] limpiando estado");



  // 2️⃣ Limpiar cache
   _cacheTiendas = null;

  // 3️⃣ Limpiar notifiers
  tiendasNotifier.value = null;

  cargandoNotifier.value = false;

}

 
}