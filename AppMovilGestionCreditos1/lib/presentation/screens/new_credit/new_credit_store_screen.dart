/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
// import '../../../models/tienda_crear_dto.dart'; // YA NO USAMOS ESTE
import '../../../models/tienda_dto.dart'; // USAMOS ESTE AHORA
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../services/tiendaService.dart';

class NewCreditStoreScreen extends StatefulWidget {
  //final int tiendaId;
  //final int clienteId;
  const NewCreditStoreScreen({super.key,/* required this.tiendaId*/});

  @override
  State<NewCreditStoreScreen> createState() => _NewCreditStoreScreenState();
}

class _NewCreditStoreScreenState extends State<NewCreditStoreScreen> {
  final _formKey = GlobalKey<FormState>();

  // CAMBIO: Solo necesitamos controlador de Cédula
  final _cedulaEncargadoCtrl = TextEditingController();

  // CAMBIO: Variable para comisión
  String _estadoComision = 'Pendiente';
  final List<String> _opcionesComision = ['Pendiente', 'Recibida'];

  bool _isLoading = false;

  @override
  void dispose() {
    _cedulaEncargadoCtrl.dispose();
    super.dispose();
  }

  // --- MAQUETACIÓN DE VALIDACIÓN (Igual que en StoreDataScreen) ---
  Future<bool> _validarEncargadoEnBackend(String cedula) async {
    // Simulación de llamada al API
    await Future.delayed(const Duration(seconds: 1));
    // Lógica Mock: Solo acepta cédulas de 10 dígitos
    return cedula.length == 10;
  }

  void _guardarTienda() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. VALIDAR CÉDULA PRIMERO
    final bool existe = await _validarEncargadoEnBackend(_cedulaEncargadoCtrl.text);

    if (!existe) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Encargado no encontrado'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 2. Crear DTO Tienda (Con los nuevos campos)
    final tienda = TiendaAppDTO(
      cedulaEncargado: _cedulaEncargadoCtrl.text,
      estadoDeComision: _estadoComision,
      fechaRegistro: DateTime.now(), // Se asigna al crear
      // Id se genera en backend
    );

    final tiendaServicio = TiendaService();

    // 3. LLAMADA AL BACKEND
    // Nota: Asegúrate de que GuardarTienda acepte TiendaDTO ahora
    final tiendaCreada = await tiendaServicio.GuardarTienda(tienda);

    // await Future.delayed(const Duration(seconds: 1)); // Simulación ya no necesaria si el servicio responde

    // Refrescar lista de tiendas (opcional si se usa en el home)
    await tiendaServicio.getTienda(forceRefresh: true);
    debugPrint("🟠 [NEW Tienda] notifier → ${tiendaServicio.tiendasNotifier.value?.length}");

    debugPrint("🔄 ValueNotifier después de actualizar:");
    debugPrint(tiendaServicio.tiendasNotifier.value.toString());

    await Future.delayed(const Duration(seconds: 1)); // Pequeña pausa UX

    if (mounted) {
      setState(() => _isLoading = false);
      // Avanzar al paso final: CRÉDITO + CALCULADORA
      // Pasamos el ID de la tienda recién creada/validada
      context.push('/new-credit-financial',
        extra: tiendaCreada.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Datos de Compra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(child: const Text('Validación del Vendedor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),

              // --- CAMPO CÉDULA ---
              CustomTextField(
                label: 'Cédula del Encargado/Vendedor',
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

              // --- DROPDOWN COMISIÓN ---
              const Text('Estado de la Comisión', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
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
                padding: EdgeInsets.only(top: 5, left: 5),
                child: Text('Indique el estado de la comisión.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarTienda,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('CONTINUAR A COTIZACIÓN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
// import '../../../models/tienda_crear_dto.dart'; // YA NO USAMOS ESTE
import '../../../models/tienda_dto.dart'; // USAMOS ESTE AHORA
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../services/tiendaService.dart';

class NewCreditStoreScreen extends StatefulWidget {
  //final int tiendaId;
  //final int clienteId;
  const NewCreditStoreScreen({super.key,/* required this.tiendaId*/});

  @override
  State<NewCreditStoreScreen> createState() => _NewCreditStoreScreenState();
}

class _NewCreditStoreScreenState extends State<NewCreditStoreScreen> {
  final _formKey = GlobalKey<FormState>();

  // CAMBIO: Solo necesitamos controlador de Cédula
  final _cedulaEncargadoCtrl = TextEditingController();

  // CAMBIO: Variable para comisión
  String _estadoComision = 'Pendiente';
  final List<String> _opcionesComision = ['Pendiente', 'Recibida'];

  bool _isLoading = false;

  @override
  void dispose() {
    _cedulaEncargadoCtrl.dispose();
    super.dispose();
  }

  // --- MAQUETACIÓN DE VALIDACIÓN (Igual que en StoreDataScreen) ---
  Future<bool> _validarEncargadoEnBackend(String cedula) async {
    // Simulación de llamada al API
    // En producción: return await tiendaService.validarEncargado(cedula);
    await Future.delayed(const Duration(seconds: 1));

    // Lógica Mock: Solo acepta cédulas de 10 dígitos para la prueba
    return cedula.length == 10;
  }

  void _guardarTienda() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. VALIDAR CÉDULA PRIMERO
    final bool existe = await _validarEncargadoEnBackend(_cedulaEncargadoCtrl.text);

    if (!existe) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Error: El encargado con esa cédula no existe.')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return; // ⛔ DETENER EL PROCESO
    }

    // 2. Crear DTO Tienda (Con los nuevos campos)
    final tienda = TiendaAppDTO(
      cedulaEncargado: _cedulaEncargadoCtrl.text,
      estadoDeComision: _estadoComision,
      fechaRegistro: DateTime.now(), // Se asigna al crear
      // Id se genera en backend
    );

    final tiendaServicio = TiendaService();

    try {
      // 3. LLAMADA AL BACKEND
      // Nota: Asegúrate de que GuardarTienda acepte TiendaDTO ahora
      final tiendaCreada = await tiendaServicio.GuardarTienda(tienda);

      // Refrescar lista de tiendas (opcional si se usa en el home)
      await tiendaServicio.getTienda(forceRefresh: true);
      debugPrint("🟠 [NEW Tienda] guardada ID: ${tiendaCreada.id}");

      if (mounted) {
        setState(() => _isLoading = false);
        // Avanzar al paso final: CRÉDITO + CALCULADORA
        // Pasamos el ID de la tienda recién creada/validada
        context.push('/new-credit-financial',
          extra: tiendaCreada.id,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar tienda: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Datos de Compra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(child: const Text('Validación del Vendedor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),

              // --- CAMPO CÉDULA ---
              CustomTextField(
                label: 'Cédula del Encargado/Vendedor',
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

              // --- DROPDOWN COMISIÓN ---
              const Text('Estado de la Comisión', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
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
                padding: EdgeInsets.only(top: 5, left: 5),
                child: Text('Indique el estado de la comisión.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarTienda,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CONTINUAR A COTIZACIÓN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}