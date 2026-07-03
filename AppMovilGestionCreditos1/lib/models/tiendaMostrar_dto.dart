/*class TiendaMostrarAppVentaDTO {
  int id;
   String nombreEncargado;
    String telefono;
  int clienteId;


  TiendaMostrarAppVentaDTO({
    required this.id,
    required this.nombreEncargado,
     required this.telefono,
    required this.clienteId,
 
  });

  factory TiendaMostrarAppVentaDTO.fromJson(Map<String, dynamic> json) {
  return TiendaMostrarAppVentaDTO(
    id: json["id"] ?? 0,
    nombreEncargado: json['nombreEncargado'] ?? '',
   
     telefono: json['telefono'] ?? '',
    clienteId: (json["clienteId"] ?? 0).toInt(),  
  
  );
}

}
*/
class TiendaMostrarAppVentaDTO {
  final int id;
  final String fechaRegistroStr;
  final int clienteId;

  TiendaMostrarAppVentaDTO({
    required this.id,
    required this.fechaRegistroStr,
    required this.clienteId,
  });

  // Mapeo de JSON a Objeto Dart
  factory TiendaMostrarAppVentaDTO.fromJson(Map<String, dynamic> json) {
    return TiendaMostrarAppVentaDTO(
      // Usamos los nombres exactos que vienen de C# (PascalCase o camelCase según tu config de API)
      id: json["id"] ?? 0,
      fechaRegistroStr: json["fechaRegistroStr"] ?? '',
      clienteId: (json["clienteId"] ?? 0).toInt(),
    );
  }

  // Opcional: Mapeo de Objeto Dart a JSON (útil para enviar datos)
  Map<String, dynamic> toJson() => {
        "Id": id,
        "FechaRegistroStr": fechaRegistroStr,
        "ClienteId": clienteId,
      };
}