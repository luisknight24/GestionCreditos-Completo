/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../models/credito_dto.dart';
import '../../../services/creditoMostrarHome.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../models/CreditoMostrarDTO.dart';
import '../../../presentation/widgets/photo_upload_card.dart'; // Importar
import '../../../services/firebase_service.dart'; // Importar

class NewCreditFinancialScreen extends StatefulWidget {
  //final int clienteId;
  final int tiendaAppId;

  const NewCreditFinancialScreen({super.key, required this.tiendaAppId});

  @override
  State<NewCreditFinancialScreen> createState() => _NewCreditFinancialScreenState();
}

class _NewCreditFinancialScreenState extends State<NewCreditFinancialScreen> {

  final creditoMostrarHome creditoHomeService = creditoMostrarHome();

  final _formKey = GlobalKey<FormState>();

  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  // NUEVO: Controlador IMEI
  final _imeiCtrl = TextEditingController();

  final _propietarioCreditoCtrl = TextEditingController();

  final _capacidadCtrl = TextEditingController();

  DateTime _proximaCuota = DateTime.now();
  String? _frecuenciaSeleccionada;

  // NUEVO: Variable para Tipo de Producto
  String _tipoProducto = 'Teléfono';
  final List<String> _tiposProducto = ['Teléfono', 'Televisor'];

  // VARIABLES DE EVIDENCIA (Contrato y Celular)
  // File? _fotoContrato; // 📸 COMENTADO
  // File? _fotoCelular;  // 📸 COMENTADO

  bool _isLoading = false;

  // Variables calculadas
  double _valorCuota = 0.0;
  double _totalPagar = 0.0;

  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];
//final creditoServicio = creditoMostrarHome();
  //late final creditoMostrarHome creditoServicio;

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _plazoCtrl.addListener(_calcularValores);

    debugPrint("🟠 [NEW CREDIT] usando instancia → hash: ${creditoHomeService.hashCode}");
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _plazoCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _imeiCtrl.dispose(); // Dispose IMEI
    _propietarioCreditoCtrl.dispose();
    _capacidadCtrl.dispose();
    super.dispose();
  }
  // NUEVO: Variable para el combo de cuotas
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];

  // --- LÓGICA DE CALCULADORA ---
  void _calcularValores() {
    double monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    double entrada = double.tryParse(_entradaCtrl.text) ?? 0.0;
    int plazo = int.tryParse(_plazoCtrl.text) ?? 0;

    if (monto > 0 && plazo > 0) {
      double saldoFinanciar = monto - entrada;

      // CAMBIO: Se eliminó el factor de interés. Ahora es directo.
      double totalSinInteres = saldoFinanciar;

      setState(() {
        _totalPagar = totalSinInteres;
        _valorCuota = totalSinInteres / plazo;
      });
    } else {
      setState(() {
        _valorCuota = 0.0;
        _totalPagar = 0.0;
      });
    }
  }

  void _finalizarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frecuenciaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia')));
      return;
    }

    // VALIDAR IMEI SI ES TELÉFONO
    if (_tipoProducto == 'Teléfono' && _imeiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El IMEI es requerido para teléfonos'), backgroundColor: Colors.red));
      return;
    }

    /* 📸 VALIDACIÓN DE FOTOS COMENTADA
    // VALIDACIÓN DE EVIDENCIAS (NUEVO)
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes subir fotos de Contrato y Celular'), backgroundColor: Colors.red)
      );
      return;
    }
    */

    setState(() => _isLoading = true);

    // ✅ VALIDAR PROPIETARIO
    if (_propietarioCreditoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El propietario del crédito es requerido'), backgroundColor: Colors.red));
      return;
    }

    if (_capacidadCtrl.text.isNotEmpty) {
      final cap = int.tryParse(_capacidadCtrl.text);
      if (cap == null || cap > 2000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La capacidad máxima es 2000 GB'), backgroundColor: Colors.red));
        return;
      }
    }

    // Dialogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Procesando solicitud...", style: TextStyle(fontWeight: FontWeight.bold))
          ]),
        ),
      ),
    );

    try {
      // final firebaseService = FirebaseService(); // 📸 COMENTADO

      // 1. SUBIR EVIDENCIAS
      // String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos_nuevos'); // 📸 COMENTADO
      // String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares_nuevos');   // 📸 COMENTADO

      // Simulación
      await Future.delayed(const Duration(seconds: 2));


      // 🚨 CAMBIO: ELIMINADO EL Navigator.pop(context) TEMPRANO
      // if (mounted && Navigator.canPop(context)) { ... }

      // 2. CREAR DTO
      final credito = CreditoDTO(
        id: 0,
        // clienteId: widget.clienteId,
        montoTotal: double.parse(_montoCtrl.text),
        entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),
        plazoCuotas: int.parse(_plazoCtrl.text),//int.parse(_plazoCtrl.text) _plazoSeleccionado!,
        frecuenciaPago: _frecuenciaSeleccionada!,
        valorPorCuota: _valorCuota,
        montoPendiente: _totalPagar,
        diaPago: DateTime.now(),
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: "Pendiente",
        tiendaAppId: widget.tiendaAppId,
        fechaCreacion: DateTime.now().toUtc(),
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        estadoCuota: "Pendiente",
        abonadoTotal: 0.0,
        // Nuevos campos Foto
        fotoContratoUrl: null, // urlContrato, // 📸 URL COMENTADA
        fotoCelularUrl: null,  // urlCelular,  // 📸 URL COMENTADA

        // NUEVOS CAMPOS PRODUCTO
        tipoProducto: _tipoProducto,
        imei: (_tipoProducto == 'Teléfono') ? _imeiCtrl.text : null,
        nombrePropietario: _propietarioCreditoCtrl.text,
        capacidad: int.tryParse(_capacidadCtrl.text),
      );
      //final CreditoServicio = creditoMostrarHome();

      final response=await creditoHomeService.guardarCredito(credito);

      debugPrint("✅ [NEW CREDIT] Crédito creado en backend:");
      debugPrint("id: ${response.id}");
      debugPrint("montoPendiente: ${response.montoPendiente}");
      debugPrint("estado: ${response.estado}");
      debugPrint("proximaCuotaStr: ${response.proximaCuotaStr}");


      // LLAMADA AL BACKEND:

      // 2️⃣ Refrescar la lista completa desde backend
      await creditoHomeService.getCreditos(forceRefresh: true);
      debugPrint("🟠 [NEW CREDIT] notifier → ${creditoHomeService.creditosNotifier.value?.length}");

      debugPrint("🔄 ValueNotifier después de actualizar:");
      debugPrint(creditoHomeService.creditosNotifier.value.toString());
      await Future.delayed(const Duration(seconds: 2)); // Simulación

      // 🚨 CAMBIO: AHORA CERRAMOS EL LOADING AQUÍ, AL FINAL
      if (mounted) Navigator.pop(context);

      if (mounted) {
        debugPrint('🟢 BEFORE setState éxito');
        setState(() => _isLoading = false);

        debugPrint('🟢 BEFORE _mostrarExito');
        _mostrarExito(credito.montoTotal);
        debugPrint('🟢 AFTER _mostrarExito');
      }

    } catch (e, stackTrace) {
      debugPrint('❌❌❌ ERROR AL ENVIAR SOLICITUD ❌❌❌');
      debugPrint('🧨 Tipo: ${e.runtimeType}');
      debugPrint('🧨 Mensaje: $e');
      debugPrint('📍 StackTrace:\n$stackTrace');

      if (mounted) {
        debugPrint('↩️ Navigator.pop en catch');
        Navigator.pop(context); // Cierra loading si hay error
      } else {
        debugPrint('⚠️ Widget no montado, no pop');
      }

      if (mounted) {
        debugPrint('🔄 setState(_isLoading = false) en catch');
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar solicitud')),
        );
      }
    }

  }

  void _mostrarExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('¡Solicitud Exitosa!'),
          ],
        ),
        content: Text('Tu crédito ha sido registrado correctamente.', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              //            context.go('/home');
              context.go('/home', extra: true);
              // cerrar diálogo
              // context.go('/home', extra: true);
              debugPrint("✅ [NEW CREDIT] Crédito creado, haciendo pop()");
//context.pop(true);
              // context.pop(true);      // Volver al inicio
            },
            child: const Text('FINALIZAR'),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 🟢 NUEVO: WIDGET CALCULADORA VISUAL (Misma lógica, adaptada a variables locales)
  // ----------------------------------------------------------------------
  Widget _buildCalculatorVisualizer(ThemeData theme) {
    if (_totalPagar <= 0) return const SizedBox.shrink();

    final TextStyle valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor);
    final TextStyle labelStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);
    String freqLabel = _frecuenciaSeleccionada ?? 'Cuotas';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate, size: 20, color: Colors.grey),
              const SizedBox(width: 5),
              Text("Desglose del Cálculo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 15),
          // OPERACIÓN 1: RESTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_montoCtrl.text.isEmpty ? '0' : _montoCtrl.text}", style: valueStyle), Text("Precio", style: labelStyle)]),
              const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
              Column(children: [Text("\$${_entradaCtrl.text.isEmpty ? '0' : _entradaCtrl.text}", style: valueStyle), Text("Entrada", style: labelStyle)]),
              const Icon(Icons.drag_handle, size: 20, color: Colors.grey), // Igual
              Column(children: [Text("\$${_totalPagar.toStringAsFixed(2)}", style: valueStyle), Text("A Financiar", style: labelStyle)]),
            ],
          ),
          const Divider(height: 25),
          // OPERACIÓN 2: DIVISIÓN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_totalPagar.toStringAsFixed(2)}", style: valueStyle), Text("Saldo", style: labelStyle)]),
              const Icon(Icons.percent, size: 20, color: Colors.orangeAccent), // División visual
              Column(children: [Text(_plazoCtrl.text.isEmpty ? '1' : _plazoCtrl.text, style: valueStyle), Text("Pagos ($freqLabel)", style: labelStyle)]),
              const Icon(Icons.arrow_right_alt, size: 30, color: Colors.green), // Flecha resultado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                child: Column(children: [Text("\$${_valorCuota.toStringAsFixed(2)}", style: valueStyle.copyWith(color: Colors.green[800])), Text("Cuota Final", style: labelStyle)]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String etiquetaCuota = _frecuenciaSeleccionada != null ? "Cuota $_frecuenciaSeleccionada" : "Cuota Estimada";

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 3: Cotizador Final')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- CALCULADORA ---
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text('RESUMEN DE PAGOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$etiquetaCuota:', style: const TextStyle(fontSize: 16)),
                          Text('\$${_valorCuota.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total a Financiar:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('\$${_totalPagar.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ CAMPO PROPIETARIO CREDITO (PRIMERA OPCIÓN DE INPUT)
              CustomTextField(
                label: 'Propietario del Crédito',
                controller: _propietarioCreditoCtrl,
                icon: Icons.person_pin,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              // --- NUEVO: TIPO PRODUCTO Y MARCA ---
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tipo Producto', border: OutlineInputBorder()),
                      value: _tipoProducto,
                      items: _tiposProducto.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        setState(() => _tipoProducto = val!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(label: 'Marca', controller: _marcaCtrl, icon: Icons.branding_watermark)),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(flex: 2, child: CustomTextField(label: 'Modelo', controller: _modeloCtrl, icon: Icons.devices)),
                  const SizedBox(width: 10),

                  // ✅ CAMPO CAPACIDAD
                  Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: 'Cap.',
                        controller: _capacidadCtrl,
                        keyboardType: TextInputType.number,
                        suffixText: 'GB',
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final n = int.tryParse(v);
                            if (n == null || n > 1000) return 'Max 1TB';
                          }
                          return null;
                        },
                      )
                  ),
                ],
              ),

              if (_tipoProducto == 'Teléfono') ...[
                const SizedBox(height: 15),
                CustomTextField(label: 'IMEI', controller: _imeiCtrl, icon: Icons.qr_code),
              ],

              const SizedBox(height: 15),
              // --- CAMPOS ---
              // ✏️ CAMBIO ESTÉTICO: Ícono más general
              CustomTextField(
                label: 'Precio Equipo (\$)',
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.monetization_on_outlined,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                  label: 'Entrada Inicial (\$)',
                  controller: _entradaCtrl,
                  keyboardType: TextInputType.number,
                  icon: Icons.money_off
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Cuotas',
                      controller: _plazoCtrl,
                      keyboardType: TextInputType.number,
                      icon: Icons.calendar_today,
                      // --- VALIDACIÓN DE CUOTAS DINÁMICA ---
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        final val = int.tryParse(v);
                        if (val == null) return 'Inválido';

                        int max = 24; // Default Mensual
                        if (_frecuenciaSeleccionada == 'Semanal') max = 52;
                        if (_frecuenciaSeleccionada == 'Quincenal') max = 48;
                        if (_frecuenciaSeleccionada == 'Mensual') max = 24;

                        if (val > max) return 'Máx $max cuotas';
                        return null;
                      },
                      // ------------------------------------
                    ),

// 4. CAMBIO: DROPDOWN DE CUOTAS


                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
                      value: _frecuenciaSeleccionada,
                      items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) {
                        setState(() => _frecuenciaSeleccionada = v);
                        _calcularValores();
                      },
                    ),
                  ),
                ],
              ),

              // 🟢 AQUÍ INSERTAMOS LA CALCULADORA VISUAL
              _buildCalculatorVisualizer(theme),

              const SizedBox(height: 30),

              /* 📸 SECCIÓN EVIDENCIAS COMENTADA
              // --- SECCIÓN EVIDENCIAS (NUEVO) ---
              const Divider(),
              const Text("EVIDENCIA DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: PhotoUploadCard(label: 'Contrato Nuevo *', onImageSelected: (f) => _fotoContrato = f)),
                  const SizedBox(width: 10),
                  Expanded(child: PhotoUploadCard(label: 'Celular Nuevo *', onImageSelected: (f) => _fotoCelular = f)),
                ],
              ),
              */

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finalizarSolicitud,
                  style: ElevatedButton.styleFrom(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _isLoading
                      ? const Text('Procesando...', style: TextStyle(color: Colors.white))
                      : const Text('FINALIZAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../models/credito_dto.dart';
import '../../../services/creditoMostrarHome.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../models/CreditoMostrarDTO.dart';
// import '../../../presentation/widgets/photo_upload_card.dart'; // Descomentar si usas fotos
// import '../../../services/firebase_service.dart'; // Descomentar si usas fotos

class NewCreditFinancialScreen extends StatefulWidget {
  final int tiendaAppId;

  const NewCreditFinancialScreen({super.key, required this.tiendaAppId});

  @override
  State<NewCreditFinancialScreen> createState() => _NewCreditFinancialScreenState();
}

class _NewCreditFinancialScreenState extends State<NewCreditFinancialScreen> {
  // LÓGICA EXISTENTE: Instancia del servicio
  final creditoMostrarHome creditoHomeService = creditoMostrarHome();

  final _formKey = GlobalKey<FormState>();

  // LÓGICA EXISTENTE: Controladores
  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _imeiCtrl = TextEditingController();
  final _propietarioCreditoCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();

  // 🔥 NUEVO: Variables para controlar Crédito vs Contado
  String _tipoVenta = 'Crédito';
  final List<String> _tiposVenta = ['Crédito', 'Contado'];
  bool get _esContado => _tipoVenta == 'Contado';

  DateTime _proximaCuota = DateTime.now();
  String? _frecuenciaSeleccionada;
  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];

  String _tipoProducto = 'Teléfono';
  final List<String> _tiposProducto = ['Teléfono', 'Televisor'];

  bool _isLoading = false;

  // Variables calculadas
  double _valorCuota = 0.0;
  double _totalPagar = 0.0;

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _plazoCtrl.addListener(_calcularValores);
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _plazoCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _imeiCtrl.dispose();
    _propietarioCreditoCtrl.dispose();
    _capacidadCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CÁLCULO ---
  void _calcularValores() {
    // 1. Obtener valores base
    double monto = double.tryParse(_montoCtrl.text) ?? 0.0;

    // 🔥 NUEVO: Si es contado, forzamos valores a cero deuda
    if (_esContado) {
      setState(() {
        _totalPagar = 0.0; // No hay deuda pendiente
        _valorCuota = 0.0; // No hay cuotas
      });
      return;
    }

    // LÓGICA EXISTENTE: Cálculo de crédito normal
    double entrada = double.tryParse(_entradaCtrl.text) ?? 0.0;
    int plazo = int.tryParse(_plazoCtrl.text) ?? 0;

    if (monto > 0 && plazo > 0) {
      double saldoFinanciar = monto - entrada;
      // Lógica simple que ya tenías: Saldo / Plazo
      double totalSinInteres = saldoFinanciar;

      setState(() {
        _totalPagar = totalSinInteres;
        _valorCuota = totalSinInteres / plazo;
      });
    } else {
      setState(() {
        _valorCuota = 0.0;
        _totalPagar = 0.0;
      });
    }
  }

  void _finalizarSolicitud() async {
    // LÓGICA EXISTENTE: Validaciones base
    // Validar propietario
    if (_propietarioCreditoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El propietario del crédito es requerido'), backgroundColor: Colors.red));
      return;
    }

    // Validar IMEI
    if (_tipoProducto == 'Teléfono' && _imeiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El IMEI es requerido para teléfonos'), backgroundColor: Colors.red));
      return;
    }

    // Validar Capacidad
    if (_capacidadCtrl.text.isNotEmpty) {
      final cap = int.tryParse(_capacidadCtrl.text);
      if (cap == null || cap > 2000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La capacidad máxima es 2000 GB'), backgroundColor: Colors.red));
        return;
      }
    }

    // 🔥 NUEVO: Validaciones condicionales
    if (!_esContado) {
      // Si es crédito, validamos el formulario completo (entrada, cuotas, frecuencia)
      if (!_formKey.currentState!.validate()) return;

      if (_frecuenciaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia')));
        return;
      }
    } else {
      // Si es contado, solo validamos que haya precio
      if (_montoCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese el valor pagado')));
        return;
      }
    }

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Procesando solicitud...", style: TextStyle(fontWeight: FontWeight.bold))
          ]),
        ),
      ),
    );

    try {
      // LÓGICA EXISTENTE: Preparación de variables para el DTO
      final double precioTotal = double.parse(_montoCtrl.text);

      // 🔥 NUEVO: Ajuste de valores según tipo de venta
      final double entradaFinal = _esContado ? precioTotal : (double.tryParse(_entradaCtrl.text) ?? 0);
      final double montoPendienteFinal = _esContado ? 0 : _totalPagar;
      final int plazoFinal = _esContado ? 1 : int.parse(_plazoCtrl.text);
      final String frecuenciaFinal = _esContado ? 'Unico' : _frecuenciaSeleccionada!;
      final double valorCuotaFinal = _esContado ? 0 : _valorCuota;
      final String estadoFinal = _esContado ? 'Pagado' : 'Pendiente';
      final String estadoCuotaFinal = _esContado ? 'Pagado' : 'Pendiente';
      final double abonadoTotalFinal = _esContado ? precioTotal : 0.0;

      // LÓGICA EXISTENTE: Creación del DTO
      final credito = CreditoDTO(
        id: 0,
        esVentaContado: _esContado, // 🔥 Enviamos el flag al backend
        montoTotal: precioTotal,
        entrada: entradaFinal,
        plazoCuotas: plazoFinal,
        frecuenciaPago: frecuenciaFinal,
        valorPorCuota: valorCuotaFinal,
        montoPendiente: montoPendienteFinal,
        estado: estadoFinal,
        estadoCuota: estadoCuotaFinal,
        abonadoTotal: abonadoTotalFinal,

        // Campos fijos o calculados
        diaPago: DateTime.now(),
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        tiendaAppId: widget.tiendaAppId,
        fechaCreacion: DateTime.now().toUtc(),
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        fotoContratoUrl: null, // urlContrato
        fotoCelularUrl: null,  // urlCelular
        tipoProducto: _tipoProducto,
        imei: (_tipoProducto == 'Teléfono') ? _imeiCtrl.text : null,
        nombrePropietario: _propietarioCreditoCtrl.text,
        capacidad: int.tryParse(_capacidadCtrl.text),
      );

      // LÓGICA EXISTENTE: Llamada al servicio
      final response = await creditoHomeService.guardarCredito(credito);

      debugPrint("✅ Crédito creado: ID ${response.id}");

      // Refrescar lista
      await creditoHomeService.getCreditos(forceRefresh: true);

      if (mounted) Navigator.pop(context); // Cerrar loading

      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarExito(credito.montoTotal);
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar solicitud')));
    }
  }

  void _mostrarExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('¡Solicitud Exitosa!'),
          ],
        ),
        content: const Text('La operación ha sido registrada correctamente.', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context.go('/home', extra: true);
            },
            child: const Text('FINALIZAR'),
          )
        ],
      ),
    );
  }

  // Widget Calculadora Visual (EXISTENTE)
  Widget _buildCalculatorVisualizer(ThemeData theme) {
    if (_totalPagar <= 0) return const SizedBox.shrink();

    final TextStyle valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor);
    final TextStyle labelStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);
    String freqLabel = _frecuenciaSeleccionada ?? 'Cuotas';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate, size: 20, color: Colors.grey),
              const SizedBox(width: 5),
              Text("Desglose del Cálculo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 15),
          // OPERACIÓN 1: RESTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_montoCtrl.text.isEmpty ? '0' : _montoCtrl.text}", style: valueStyle), Text("Precio", style: labelStyle)]),
              const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
              Column(children: [Text("\$${_entradaCtrl.text.isEmpty ? '0' : _entradaCtrl.text}", style: valueStyle), Text("Entrada", style: labelStyle)]),
              const Icon(Icons.drag_handle, size: 20, color: Colors.grey), // Igual
              Column(children: [Text("\$${_totalPagar.toStringAsFixed(2)}", style: valueStyle), Text("Saldo", style: labelStyle)]),
            ],
          ),
          const Divider(height: 25),
          // OPERACIÓN 2: DIVISIÓN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_totalPagar.toStringAsFixed(2)}", style: valueStyle), Text("Saldo", style: labelStyle)]),
              const Icon(Icons.percent, size: 20, color: Colors.orangeAccent), // División visual
              Column(children: [Text(_plazoCtrl.text.isEmpty ? '1' : _plazoCtrl.text, style: valueStyle), Text("Pagos ($freqLabel)", style: labelStyle)]),
              const Icon(Icons.arrow_right_alt, size: 30, color: Colors.green), // Flecha resultado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                child: Column(children: [Text("\$${_valorCuota.toStringAsFixed(2)}", style: valueStyle.copyWith(color: Colors.green[800])), Text("Cuota", style: labelStyle)]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String etiquetaCuota = _frecuenciaSeleccionada != null ? "Cuota $_frecuenciaSeleccionada" : "Cuota Estimada";

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // 🔥 NUEVO: TOGGLE CRÉDITO / CONTADO
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: [_tipoVenta == 'Crédito', _tipoVenta == 'Contado'],
                fillColor: theme.primaryColor,
                selectedColor: Colors.white,
                color: Colors.grey,
                constraints: BoxConstraints(minWidth: (MediaQuery.of(context).size.width - 50) / 2, minHeight: 45),
                onPressed: (index) {
                  setState(() {
                    _tipoVenta = index == 0 ? 'Crédito' : 'Contado';
                    _calcularValores(); // Recalcula (pone deuda en 0 si es contado)
                  });
                },
                children: const [
                  Text("CRÉDITO", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("CONTADO", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // RESUMEN (EXISTENTE): Solo lo mostramos si es Crédito para no confundir
              if (!_esContado)
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('RESUMEN DE PAGOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$etiquetaCuota:', style: const TextStyle(fontSize: 16)),
                            Text('\$${_valorCuota.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total a Financiar:', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('\$${_totalPagar.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // --- CAMPOS COMUNES ---
              CustomTextField(
                label: 'Propietario del Crédito',
                controller: _propietarioCreditoCtrl,
                icon: Icons.person_pin,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tipo Producto', border: OutlineInputBorder()),
                      value: _tipoProducto,
                      items: _tiposProducto.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        setState(() => _tipoProducto = val!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(label: 'Marca', controller: _marcaCtrl, icon: Icons.branding_watermark)),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(flex: 2, child: CustomTextField(label: 'Modelo', controller: _modeloCtrl, icon: Icons.devices)),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: 'Cap.',
                        controller: _capacidadCtrl,
                        keyboardType: TextInputType.number,
                        suffixText: 'GB',
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final n = int.tryParse(v);
                            if (n == null || n > 1000) return 'Max 1TB';
                          }
                          return null;
                        },
                      )
                  ),
                ],
              ),

              if (_tipoProducto == 'Teléfono') ...[
                const SizedBox(height: 15),
                CustomTextField(label: 'IMEI', controller: _imeiCtrl, icon: Icons.qr_code),
              ],

              const SizedBox(height: 15),

              // CAMPO PRECIO (Siempre visible, cambia etiqueta según modo)
              CustomTextField(
                label: _esContado ? 'Valor Pagado (Total)' : 'Precio Equipo (\$)',
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.monetization_on_outlined,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              // 🔥 CONDICIONAL: CAMPOS DE CRÉDITO
              if (!_esContado) ...[
                const SizedBox(height: 15),
                CustomTextField(
                    label: 'Entrada Inicial (\$)',
                    controller: _entradaCtrl,
                    keyboardType: TextInputType.number,
                    icon: Icons.money_off
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Cuotas',
                        controller: _plazoCtrl,
                        keyboardType: TextInputType.number,
                        icon: Icons.calendar_today,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          // Tu validación de máximos existente
                          final val = int.tryParse(v);
                          int max = 24;
                          if (_frecuenciaSeleccionada == 'Semanal') max = 52;
                          if (_frecuenciaSeleccionada == 'Quincenal') max = 48;
                          if (_frecuenciaSeleccionada == 'Mensual') max = 24;
                          if (val != null && val > max) return 'Máx $max';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
                        value: _frecuenciaSeleccionada,
                        items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (v) {
                          setState(() => _frecuenciaSeleccionada = v);
                          _calcularValores();
                        },
                      ),
                    ),
                  ],
                ),

                _buildCalculatorVisualizer(theme),
              ] else ...[
                // Feedback visual para Contado
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
                  child: const Row(children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(child: Text("Registro de venta directa. El equipo quedará marcado como pagado.", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))
                  ]),
                )
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finalizarSolicitud,
                  style: ElevatedButton.styleFrom(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _isLoading
                      ? const Text('Procesando...', style: TextStyle(color: Colors.white))
                      : const Text('FINALIZAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}