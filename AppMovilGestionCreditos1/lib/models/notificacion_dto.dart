class NotificacionDTO {
  int id;
  int clienteId;
  String tipo;
  String mensaje;
  DateTime fecha;
  bool leida;

  NotificacionDTO({
    this.id = 0,
    required this.clienteId,
    required this.tipo,
    required this.mensaje,
    required this.fecha,
    this.leida = false,
  });

  factory NotificacionDTO.fromJson(Map<String, dynamic> json) {
    return NotificacionDTO(
      id: json['id'] ?? 0,
      clienteId: json['clienteId'] ?? 0,
      tipo: json['tipo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      leida: json['leida'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ClienteId': clienteId,
    'Tipo': tipo,
    'Mensaje': mensaje,
    'Fecha': fecha.toIso8601String(),
    'Leida': leida,
  };
}