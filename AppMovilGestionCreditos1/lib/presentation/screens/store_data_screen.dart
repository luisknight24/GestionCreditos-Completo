import 'dart:io';
import 'package:flutter/material.dart';
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

  // Variable para el estado de la comisión
  String _estadoComision = 'Pendiente'; // Valor por defecto
  final List<String> _opcionesComision = ['Pendiente', 'Cobrado'];

  bool _isValidating = false; // Para mostrar loading mientras valida

  @override
  void dispose() {
    _cedulaEncargadoCtrl.dispose();
    super.dispose();
  }

  // --- MAQUETACIÓN DE LLAMADA A LA API ---
  Future<bool> _validarEncargadoEnBackend(String cedula) async {
    // Aquí iría tu llamada real: await apiService.checkEncargado(cedula);

    debugPrint("🔍 Validando encargado en servidor: $cedula");

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
      return; // ⛔ NO AVANZAR
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

    debugPrint("✅ Tienda configurada: Encargado ${_cedulaEncargadoCtrl.text} - Comisión $_estadoComision");

    if (mounted) {
      context.push('/credit-data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 3: Datos de Tienda'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Validación de Encargado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // --- CAMPO CÉDULA ENCARGADO ---
              CustomTextField(
                label: 'Cédula del Encargado',
                controller: _cedulaEncargadoCtrl,
                icon: Icons.badge,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (v.length < 10) return 'Ingrese 10 dígitos';
                  if (v.length > 10) return 'Ingrese 10 dígitos';
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // --- SECCIÓN COMISIÓN ---
              const Text(
                'Estado de la Comisión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _estadoComision,
                    isExpanded: true,
                    icon: const Icon(Icons.monetization_on, color: Colors.green),
                    items: _opcionesComision.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: value == 'Recibida' ? Colors.green : Colors.orange,
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
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 5),
                child: Text(
                  'Indica si la comisión por esta venta ya fue entregada.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 40),

              // --- BOTÓN DE ACCIÓN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isValidating ? null : _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isValidating
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Validando Encargado...', style: TextStyle(color: Colors.white)),
                    ],
                  )
                      : const Text('VALIDAR Y CONTINUAR', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}