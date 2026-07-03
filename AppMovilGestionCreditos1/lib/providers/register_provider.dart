import 'package:flutter/material.dart';
import 'package:trabajo1/models/tienda_dto.dart';
import '../models/usuario_dto.dart';
import '../models/cliente_dto.dart';
import '../models/detalle_cliente_dto.dart';
import '../models/tienda_crear_dto.dart';
import '../models/credito_dto.dart';
import '../models/credito_dto.dart';
class RegisterProvider extends ChangeNotifier {
  // --- OBJETOS DTO TEMPORALES ---
  // Guardamos las piezas por separado hasta el final

  final UsuarioDTO _usuarioData = UsuarioDTO(rolId: 2, esActivo: 1); // Rol 2 por defecto
  DetalleClienteDTO? _detalleClienteData;
  TiendaAppDTO? _tiendaData;
  CreditoDTO? _creditoData;

  // Getters para acceder a la info si la necesitamos
  UsuarioDTO get usuario => _usuarioData;
  DetalleClienteDTO? get detalleCliente => _detalleClienteData;
  TiendaAppDTO? get tienda => _tiendaData;

CreditoDTO? get credito => _creditoData;
  // 1. Guardar Datos Básicos (UsuarioDTO)
  void setUsuarioBasico(String nombre, String correo, String clave) {
    _usuarioData.nombreApellidos = nombre;
    _usuarioData.correo = correo;
    _usuarioData.clave = clave;
    notifyListeners();
  }

  // 2. Guardar Detalle Cliente (DetalleClienteDTO)
  void setDetalleCliente(DetalleClienteDTO detalle) {
    _detalleClienteData = detalle;
    notifyListeners();
  }

  // 3. Guardar Tienda (TiendaCrearDTO)
  void setTienda(TiendaAppDTO tienda) {
    _tiendaData = tienda;
    notifyListeners();
  }

  // 4. Guardar Crédito (CreditoDTO)
  void setCredito(CreditoDTO credito) {
    _creditoData = credito;
    notifyListeners();
  }

  // --- EL GRAN FINAL: ARMAR EL JSON GIGANTE ---
  // Esta función la llamaremos cuando estemos listos para enviar todo a la API
  Map<String, dynamic> armarJsonRegistroCompleto() {

    // Aquí ocurre la magia de anidar los objetos como lo espera tu API
    // Estructura: Usuario -> Cliente -> (Detalle, Tiendas, Creditos)

    // 1. Armamos el ClienteDTO
    final clienteFinal = ClienteDTO(
      detalleCliente: _detalleClienteData,
      // Convertimos la tienda única en una lista, ya que tu DTO pide List<TiendaDTO>
      // NOTA: Aquí hay un detalle técnico. Tu 'TiendaCrearDTO' es diferente a 'TiendaDTO'.
      // La API probablemente maneje la conversión interna, o debamos adaptar esto.
      // Por ahora, asumiremos que en el registro inicial no mandamos la lista de tiendas
      // dentro del cliente, sino que se crean por separado, O que tu API es inteligente.
      // Si tu registro de Usuario espera TODO junto, tendríamos que ajustar el modelo.

      creditos: _creditoData != null ? [_creditoData!] : [],
      tiendas: _tiendaData != null ? [_tiendaData!] : [],
    );

    _usuarioData.cliente = clienteFinal;

    return _usuarioData.toJson();
  }

  void printSummary() {
    print("--- DTO READY ---");
    print("User: ${_usuarioData.nombreApellidos}");
    print("Cedula: ${_detalleClienteData?.numeroCedula}");
    //print("Tienda: ${_tiendaData?.nombreTienda}");
    print("Credito Total: ${_creditoData?.montoTotal}");
  }

  UsuarioDTO getUsuarioFinal() {
    // Aseguramos que la estructura esté armada
    armarJsonRegistroCompleto();
    return _usuarioData;
  }
}