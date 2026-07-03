class ReporteDTO {
  int id;
  String? fechaCredito;
  String? detalleCliente;
  String? credito;
  String? tienda;

  ReporteDTO({
    this.id = 0,
    this.fechaCredito,
    this.detalleCliente,
    this.credito,
    this.tienda,
  });

  factory ReporteDTO.fromJson(Map<String, dynamic> json) {
    return ReporteDTO(
      id: json['id'] ?? 0,
      fechaCredito: json['fechaCredito'],
      detalleCliente: json['detalleCliente'],
      credito: json['credito'],
      tienda: json['tienda'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'fechaCredito': fechaCredito,
    'DetalleCliente': detalleCliente,
    'Credito': credito,
    'Tienda': tienda,
  };
}