class ClienteMostrarDTO {
  final int id;
  final String nombreApellidos;
 final String correo;
  final int usuarioId;

  ClienteMostrarDTO({
    required this.id,
    required this.nombreApellidos,
    required this.correo,
    required this.usuarioId,
      });

  factory ClienteMostrarDTO.fromJson(Map<String, dynamic> json) {
  return ClienteMostrarDTO(
    id: json["id"] ?? 0,
    nombreApellidos: (json["nombreApellidos"])?? '',
     correo: json["correo"]?? '',

    usuarioId: (json["usuarioId"] ?? 0).toInt(),
  );
}
}
