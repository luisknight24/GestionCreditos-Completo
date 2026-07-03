
import '../models/tiendaMostrar_dto.dart';

class CreditoMostrarDTO {
  final int id;
  final  double montoTotal;
  final double montoPendiente;
  final String proximaCuotaStr;
  final double entrada;
  final int plazoCuotas;
  final double valorPorCuota;
  final String estado;
  final String marca;
  final String modelo;
  final double abonadoTotal;
  final double abonadoCuota;
  final String estadoCuota;
  final String? fechaCreditoStr;
  final int clienteId;
  final int? tiendaId;
   final TiendaMostrarAppVentaDTO? tienda;

  CreditoMostrarDTO({
    required this.id,
    required this.montoTotal,
    required this.montoPendiente,
    required this.proximaCuotaStr,
    required this.entrada,
    required this.plazoCuotas,
    required this.valorPorCuota,
    required this.estado,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.abonadoTotal,
    required this.abonadoCuota,
    required this.estadoCuota,
    this.fechaCreditoStr,

    this.tiendaId,
    this.tienda,
  });



  // 🎯 GETTERS CALCULADOS PARA CUOTAS
  
  /// Calcula cuántas cuotas completas se han pagado
/// Calcula el dinero que se ha pagado EXCLUSIVAMENTE en cuotas (sin la entrada)
  double get dineroEnCuotas {
    final pagado = abonadoTotal - entrada;
    return pagado > 0 ? pagado : 0.0;
  }

  /// Calcula cuántas cuotas se han pagado realmente
  int get cuotasPagadas {
    if (valorPorCuota <= 0) return 0;
    double resultadoProporcional = dineroEnCuotas / valorPorCuota;
    // Dividimos solo el excedente de la entrada entre el valor de la cuota
    return (resultadoProporcional + 0.0001).floor();
  }

  /// Retorna el formato "2/12"
  String get progresoCuotas {
    return '$cuotasPagadas/$plazoCuotas';
  }

  /// Porcentaje de cuotas completadas (0.0 a 1.0)
  double get porcentajeCuotasCompletadas {
    if (plazoCuotas <= 0) return 0;
    return (cuotasPagadas / plazoCuotas).clamp(0.0, 1.0);
  }

  int get cuotasRestantes {
    final restantes = plazoCuotas - cuotasPagadas;
    return restantes > 0 ? restantes : 0;
  }

  

  factory CreditoMostrarDTO.fromJson(Map<String, dynamic> json) {
  return CreditoMostrarDTO(
    id: json["id"] ?? 0,
    montoTotal: (json['MontoTotal'] ?? 0).toDouble(),
    montoPendiente: (json["montoPendiente"] ?? 0).toDouble(),
    proximaCuotaStr: json["proximaCuotaStr"] ?? "",
    entrada: (json["entrada"] ?? 0).toDouble(),
    plazoCuotas: (json["plazoCuotas"] ?? 0).toInt(),
    valorPorCuota: (json["valorPorCuota"] ?? 0).toDouble(),
    estado: json["estado"] ?? "",
    clienteId: (json["clienteId"] ?? 0).toInt(),
    tiendaId: (json["tiendaAppId"]?? 0).toInt(),
      // 🔥 AQUÍ está la clave
      tienda: json['tiendaApp'] != null
          ? TiendaMostrarAppVentaDTO.fromJson(json['tiendaApp'])
          : null,
    marca: json['marca'] ?? '',
    modelo: json['modelo'] ?? '',
    abonadoTotal: (json['abonadoTotal'] ?? 0).toDouble(),
    abonadoCuota: (json['abonadoCuota'] ?? 0).toDouble(),
    estadoCuota: json['estadoCuota'] ?? '',
    fechaCreditoStr: json['fechaCreditoStr'],

  );
}


  // 🔑 Método copyWith para actualizaciones parciales
  CreditoMostrarDTO copyWith({
    double? montoPendiente,
    String? proximaCuotaStr,
    String? estado,
    TiendaMostrarAppVentaDTO? tienda,
  }) {
    return CreditoMostrarDTO(
      id: this.id,
      montoTotal: this.montoTotal,
      montoPendiente: montoPendiente ?? this.montoPendiente,
      proximaCuotaStr: proximaCuotaStr ?? this.proximaCuotaStr,
      entrada: this.entrada,
      plazoCuotas: this.plazoCuotas,
      valorPorCuota: this.valorPorCuota,
      estado: estado ?? this.estado,
      clienteId: this.clienteId,
       tiendaId: tiendaId ?? this.tiendaId, 
      tienda: tienda ?? this.tienda,
      marca: this.marca,
      modelo: this.modelo,
      abonadoTotal: this.abonadoTotal,
      abonadoCuota: this.abonadoCuota,
      estadoCuota: this.estadoCuota,
      fechaCreditoStr: this.fechaCreditoStr,
    );
  }

}
