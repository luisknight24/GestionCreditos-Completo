import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/register_provider.dart';
// import '../../models/tienda_crear_dto.dart'; // Ya no usamos el CrearDTO antiguo si no se ajusta, usamos TiendaDTO directo
import '../../models/tienda_dto.dart';
import '../widgets/custom_text_field.dart';
import '../../services/UsuarioRegistroData.dart';

class StoreDataScreen extends StatefulWidget {
  const StoreDataScreen({super.key});

  @override
  State<StoreDataScreen> createState() => _StoreDataScreenState();
}

class _StoreDataScreenState extends State<StoreDataScreen> {
  final _formKey = GlobalKey<FormState>();
  UsuarioRegistroData registroData = UsuarioRegistroData();

  // Controladores
  final _cedulaEncargadoCtrl = TextEditingController();

  // Variable para el Estado de la comisión
  String _estadoComision = 'Pendiente'; // Valor por defecto
  final List<String> _opcionesComision = ['Pendiente', 'Cobrado'];

  bool _isValidating = false; // Para mostrar loading mientras valida

  @override
  void dispose() {
    _cedulaEncargadoCtrl.dispose();
    super.dispose();
  }

  
  Future<bool> _validarEncargadoEnBackend(String cedula) async {
    // Aquí iría tu llamada real: await apiService.checkEncargado(cedula);

    debugPrint(" Validando encargado en servidor: $cedula");

    // Simulación de delay de red
    await Future.delayed(const Duration(seconds: 2));

    // LÓGICA MOCK:
    // Digamos que solo la cédula "1234567890" o cualquiera que empiece con "09" es válida para probar.
    // Cambia esta condición según tus pruebas.
    if (cedula.length == 10) {
      return true; // Simula que SÍ existe
    } else {
      return false; // Simula que NO existe
    }
  }

  void _onNextPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isValidating = true);

    // 1. VALIDAR CONTRA EL SERVIDOR
    final bool existeEncargado = await _validarEncargadoEnBackend(_cedulaEncargadoCtrl.text);

    setState(() => _isValidating = false);

    if (!existeEncargado) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Error: El encargado con esa cédula no existe en el sistema.')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return; //  NO AVANZAR
    }

    // 2. SI EXISTE, CREAR DTO Y AVANZAR
    final tienda = TiendaAppDTO(
      cedulaEncargado: _cedulaEncargadoCtrl.text,
      estadoDeComision: _estadoComision,
      fechaRegistro: DateTime.now(), // Se enviará al crear
      // Id se genera en backend usualmente
    );

    // 3. GUARDAR EN PROVIDER
    final registerProvider = context.read<RegisterProvider>();
    registerProvider.setTienda(tienda);

    debugPrint(" Tienda configurada: Encargado ${_cedulaEncargadoCtrl.text} - Comisión $_estadoComision");

    if (mounted) {
      context.push('/credit-data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                // FONDO SECCIONADO CON GRADIENTES RADIALES
                Positioned.fill(
                  child: Container(color: const Color(0xFF090D16)),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.95, -0.95),
                        radius: 0.85,
                        colors: [
                          const Color(0xFF0284C7).withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.95, 0.2),
                        radius: 1.55,
                        colors: [
                          const Color(0xFFFACC15).withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(height: 10),

                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                                ),
                                child: const Text(
                                  'Paso 3 de 4',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Datos de tienda',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Valida la Cédula del encargado de la tienda',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xEE0F172A),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    label: 'Cédula del encargado',
                                    controller: _cedulaEncargadoCtrl,
                                    icon: Icons.badge_outlined,
                                    keyboardType: TextInputType.number,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Requerido';
                                      if (v.length != 10) return 'Ingrese 10 dígitos';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  const Text(
                                    'Estado de la comisión',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(height: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0x991E293B),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _estadoComision,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        icon: const Icon(Icons.monetization_on_outlined, color: Color(0xFF10B981)),
                                        items: _opcionesComision.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: value == 'Cobrado' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            _estadoComision = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, left: 4),
                                    child: Text(
                                      'Indica si la comisión por esta venta ya fue entregada.',
                                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isValidating ? null : _onNextPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        elevation: 6,
                                        shadowColor: const Color(0xFF10B981).withOpacity(0.35),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _isValidating
                                          ? const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                ),
                                                SizedBox(width: 10),
                                                Text('Validando Encargado...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              ],
                                            )
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Validar y continuar',
                                                  style: TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(Icons.arrow_forward_rounded, size: 20),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
