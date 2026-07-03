import '../models/cliente_dto.dart';



class UsuarioRegistroData {
  int? id;
  String? nombreApellidos;
  String? correo;
  String? clave;
  int? rolId;

  ClienteDTO? cliente;

  Map<String, dynamic> toJson() {
    return {
      "Id": id,
      "NombreApellidos": nombreApellidos,
      "Correo": correo,
      "Clave": clave,
      "RolId": rolId,
      "Cliente": cliente?.toJson(),
    };
  }
}
