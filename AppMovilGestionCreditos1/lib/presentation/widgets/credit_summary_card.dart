/*
import 'package:flutter/material.dart';
import '../../models/CreditoMostrarDTO.dart';

class CreditSummaryCard extends StatelessWidget {
  final CreditoMostrarDTO credito;

  const CreditSummaryCard({super.key, required this.credito});

  @override
  Widget build(BuildContext context) {
    // Cálculo visual de progreso (Monto Total estimado = Pendiente + Abonado)
    final double totalEstimado = credito.montoPendiente + credito.abonadoTotal;
    final double porcentajePagado = totalEstimado > 0
        ? (credito.abonadoTotal / totalEstimado).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradiente elegante para destacar la tarjeta
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CABECERA: Marca/Modelo y Estado General
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TU DISPOSITIVO', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(
                      '${credito.marca} ${credito.modelo}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _EstadoBadge(estado: credito.estado),
            ],
          ),

          const SizedBox(height: 20),

          // 2. DATOS PRINCIPALES: Cuota y Vencimiento
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(
                label: 'Valor cuota',
                value: '\$${credito.valorPorCuota.toStringAsFixed(2)}',
                icon: Icons.monetization_on_outlined,
              ),
              _InfoItem(
                label: 'Próximo pago',
                value: credito.proximaCuotaStr,
                icon: Icons.calendar_month_outlined,
                alignRight: true,
              ),
            ],
          ),

          const SizedBox(height: 15),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 10),

          // 3. NUEVOS DATOS: Abonado y Estado Cuota
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Abonado Total', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '\$${credito.abonadoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Estado Cuota', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    credito.estadoCuota.toUpperCase(),
                    style: TextStyle(
                        color: _getColorEstadoCuota(credito.estadoCuota),
                        fontSize: 14,
                        fontWeight: FontWeight.w800
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // 4. BARRA DE PROGRESO
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progreso del crédito', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                  Text('${(porcentajePagado * 100).toInt()}%', style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: porcentajePagado,
                  backgroundColor: Colors.black26,
                  color: Colors.greenAccent,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorEstadoCuota(String estado) {
    if (estado.toLowerCase().contains('venc')) return Colors.redAccent;
    if (estado.toLowerCase().contains('pagad')) return Colors.greenAccent;
    return Colors.orangeAccent; // Pendiente o Al día
  }
}

// Widget auxiliar interno para items de información
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alignRight;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!alignRight) ...[
          _IconBox(icon: icon),
          const SizedBox(width: 12),
        ],
        Column(
          crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        if (alignRight) ...[
          const SizedBox(width: 12),
          _IconBox(icon: icon),
        ],
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (estado == 'Aprobado' || estado == 'Activo') bg = Colors.green;
    else if (estado == 'Pendiente') bg = Colors.orange;
    else bg = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withOpacity(0.5)),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(color: bg.withOpacity(1.0), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import '../../models/CreditoMostrarDTO.dart';

class CreditSummaryCard extends StatelessWidget {
  final CreditoMostrarDTO credito;

  const CreditSummaryCard({super.key, required this.credito});

  @override
  Widget build(BuildContext context) {
    // Cálculo visual de progreso (Monto Total estimado = Pendiente + Abonado)
    final double totalEstimado = credito.montoPendiente + credito.abonadoTotal;
    final double porcentajePagado = totalEstimado > 0
        ? (credito.abonadoTotal / totalEstimado).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CABECERA: Fecha de venta y Dispositivo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FECHA DE VENTA', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(
                      credito.fechaCreditoStr ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    const Text('TU DISPOSITIVO', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(
                      '${credito.marca} ${credito.modelo}',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    const Text('Cuotas pagadas / Total cuotas', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(
                      credito.progresoCuotas,
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              _EstadoBadge(estado: credito.estado),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),

          // 2. FILA: Valor cuota y Próximo pago
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(
                label: 'Valor cuota',
                value: '\$${credito.valorPorCuota.toStringAsFixed(2)}',
                icon: Icons.monetization_on_outlined,
              ),
              _InfoItem(
                label: 'Próximo pago',
                value: credito.proximaCuotaStr,
                icon: Icons.calendar_month_outlined,
                alignRight: true,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 3. BARRA DE PROGRESO DE CRÉDITO
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progreso del crédito', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                  Text('${(porcentajePagado * 100).toInt()}%', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: porcentajePagado,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: const Color(0xFF10B981),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorEstadoCuota(String estado) {
    if (estado.toLowerCase().contains('venc')) return Colors.redAccent;
    if (estado.toLowerCase().contains('pagad')) return Colors.greenAccent;
    return Colors.orangeAccent; // Pendiente o Al día
  }
}

// Widget auxiliar interno para items de información
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alignRight;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!alignRight) ...[
          _IconBox(icon: icon),
          const SizedBox(width: 12),
        ],
        Column(
          crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        if (alignRight) ...[
          const SizedBox(width: 12),
          _IconBox(icon: icon),
        ],
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bg;
    // Normalizamos el texto para comparaciones más seguras
    String estadoLower = estado.toLowerCase();

    if (estadoLower.contains('aprobado') || estadoLower.contains('activo')) {
      bg = Colors.green;
    } else if (estadoLower.contains('pendiente')) {
      bg = Colors.orange;
    } else {
      bg = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withOpacity(0.5)),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(color: bg.withOpacity(1.0), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
