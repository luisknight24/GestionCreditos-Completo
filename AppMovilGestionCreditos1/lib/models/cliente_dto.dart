import 'tienda_dto.dart';
import 'credito_dto.dart';
import 'detalle_cliente_dto.dart';

class ClienteDTO {
  int id;
  int? usuarioId;
  int detalleClienteID;
  DetalleClienteDTO? detalleCliente;
  List<TiendaAppDTO>? tiendas;
  List<CreditoDTO>? creditos;

  ClienteDTO({
    this.id = 0,
    this.usuarioId,
    this.detalleClienteID = 0,
    this.detalleCliente,
    this.tiendas,
    this.creditos,
  });

 // ------------------- FROM JSON -------------------
  factory ClienteDTO.fromJson(Map<String, dynamic> json) {
    return ClienteDTO(
      id: json['Id'] ?? 0,
      usuarioId: json['UsuarioId'],
      detalleClienteID: json['DetalleClienteID'] ?? 0,
      detalleCliente: json['DetalleCliente'] != null
          ? DetalleClienteDTO.fromJson(json['DetalleCliente'])
          : null,
      tiendas: json['Tiendas'] != null
          ? (json['Tiendas'] as List)
              .map((e) => TiendaAppDTO.fromJson(e))
              .toList()
          : null,
      creditos: json['Creditos'] != null
          ? (json['Creditos'] as List)
              .map((e) => CreditoDTO.fromJson(e))
              .toList()
          : null,
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
        'Id': id,
        'UsuarioId': usuarioId,
        'DetalleClienteID': detalleClienteID,
        'DetalleCliente': detalleCliente?.toJson(),
        'TiendaApps': tiendas?.map((e) => e.toJson()).toList(),
     
      'Creditos': creditos?.map((e) => e.toJson()).toList(),
      };
}

//////////////////////////////////