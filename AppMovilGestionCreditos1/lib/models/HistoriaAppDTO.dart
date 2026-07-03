class HistoriaAppDTO {
  final int id; // Id del crédito
  final String proximaCuotaStr; // Fecha de pago o vencimiento
  final double montoPendiente;
  final double abonadoCuota;
  final String estadoCuota; // "Pagada", "Pendiente", "Vencida"
  final int clienteId;
  final int? tiendaId;
  final int? creditoId;

  HistoriaAppDTO({
    required this.id,
    required this.proximaCuotaStr,
    required this.montoPendiente,
    required this.abonadoCuota,
    required this.estadoCuota,
    required this.clienteId,
    this.tiendaId,
    this.creditoId,
  });

  factory HistoriaAppDTO.fromJson(Map<String, dynamic> json) {
    return HistoriaAppDTO(
      id: json['id'] ?? json['Id'] ?? 0,
      proximaCuotaStr: json['proximaCuotaStr'] ?? json['ProximaCuotaStr'] ?? '',
      montoPendiente: (json['montoPendiente'] ?? json['MontoPendiente'] ?? 0).toDouble(),
      abonadoCuota: (json['abonadoCuota'] ?? json['AbonadoCuota'] ?? 0).toDouble(),
      estadoCuota: json['estadoCuota'] ?? json['EstadoCuota'] ?? 'Pendiente',
      clienteId: json['clienteId'] ?? json['ClienteId'] ?? 0,
      tiendaId: json['tiendaId'] ?? json['TiendaId'],
      creditoId: json['creditoId'] ?? json['CreditoId'], // Nuevo cam
    
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ProximaCuotaStr': proximaCuotaStr,
    'MontoPendiente': montoPendiente,
    'AbonadoCuota': abonadoCuota,
    'EstadoCuota': estadoCuota,
    'ClienteId': clienteId,
    'TiendaId': tiendaId,
    'CreditoId': creditoId,
  };
}