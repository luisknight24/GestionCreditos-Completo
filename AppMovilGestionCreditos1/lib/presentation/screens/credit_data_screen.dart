/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/register_provider.dart';
import '../../models/credito_dto.dart';
import '../../data/services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart'; // IMPORTANTE
import '../../services/UsuarioRegistroData.dart';
import '../../models/cliente_dto.dart';
import '../../models/enviar_codigo_dto.dart';
import '../../services/ValidarCuenta.dart';
import '../../services/firebase_service.dart'; // IMPORTANTE

class CreditDataScreen extends StatefulWidget {
  const CreditDataScreen({super.key
  });
  @override
  State<CreditDataScreen> createState() => _CreditDataScreenState();
}

class _CreditDataScreenState extends State<CreditDataScreen> {
  UsuarioRegistroData registroData = UsuarioRegistroData();
  final _precioCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _cuotasCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  // NUEVO: Controlador IMEI
  final _imeiCtrl = TextEditingController();

  // ✅ NUEVO CONTROLADOR PARA CRÉDITO
  final _propietarioCreditoCtrl = TextEditingController();

  String _frecuencia = 'Semanal';
  DateTime _fechaPago = DateTime.now();

  double _montoFinanciar = 0;
  double _valorCuota = 0;
  DateTime _proximaCuota = DateTime.now();

  // NUEVO: Variable para Tipo de Producto
  String _tipoProducto = 'Teléfono';
  final List<String> _tiposProducto = ['Teléfono', 'Televisor'];
  final _capacidadCtrl = TextEditingController();

  // VARIABLES PARA LAS FOTOS
  // File? _fotoContrato; // 📸 COMENTADO
  // File? _fotoCelular;  // 📸 COMENTADO
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _precioCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _cuotasCtrl.addListener(_calcularValores);
  }

  // NUEVO: Variable para el combo de cuotas
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];


  @override
  void dispose() {
    _precioCtrl.dispose(); _entradaCtrl.dispose(); _cuotasCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _imeiCtrl.dispose(); // Dispose IMEI
    _propietarioCreditoCtrl.dispose();
    _capacidadCtrl.dispose();
    super.dispose();
  }

  void _calcularValores() {
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    final entrada = double.tryParse(_entradaCtrl.text) ?? 0;
    final cuotas = int.tryParse(_cuotasCtrl.text) ?? 1;

    setState(() {
      _montoFinanciar = precio - entrada;
      if (_montoFinanciar < 0) _montoFinanciar = 0;
      _valorCuota = (cuotas > 0) ? _montoFinanciar / cuotas : 0;
      _proximaCuota = _calcularProximaFecha(_fechaPago, _frecuencia);
    });
  }

  DateTime _calcularProximaFecha(DateTime fechaBase, String frecuencia) {
    switch (frecuencia) {
      case 'Semanal': return fechaBase.add(const Duration(days: 7));
      case 'Quincenal': return fechaBase.add(const Duration(days: 15));
      case 'Mensual': return DateTime(fechaBase.year, fechaBase.month + 1, fechaBase.day);
      default: return fechaBase.add(const Duration(days: 7));
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context, initialDate: _fechaPago, firstDate: DateTime.now().toUtc(), lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() { _fechaPago = picked; _calcularValores(); });
    }
  }

  void _finalizarRegistro() async {
    if (_precioCtrl.text.isEmpty || _cuotasCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Define precio y cuotas')));
      return;
    }

    // ✅ VALIDAR PROPIETARIO
    if (_propietarioCreditoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El propietario del crédito es requerido'), backgroundColor: Colors.red));
      return;
    }

    // --- VALIDACIÓN DE CUOTAS DINÁMICA ---
    final int cuotasIngresadas = int.tryParse(_cuotasCtrl.text) ?? 0;
    int maxCuotas = 24; // Default Mensual

    if (_frecuencia == 'Semanal') maxCuotas = 52;
    if (_frecuencia == 'Quincenal') maxCuotas = 48;
    if (_frecuencia == 'Mensual') maxCuotas = 24;

    if (cuotasIngresadas > maxCuotas) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Para $_frecuencia el máximo es $maxCuotas cuotas'), backgroundColor: Colors.red)
      );
      return;
    }
    // ------------------------------------

    // VALIDAR IMEI SI ES TELÉFONO
    if (_tipoProducto == 'Teléfono' && _imeiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El IMEI es requerido para teléfonos'), backgroundColor: Colors.red));
      return;
    }

    // ✅ VALIDAR CAPACIDAD SI ES TELÉFONO (Opcional, o siempre)
    if (_capacidadCtrl.text.isNotEmpty) {
      final cap = int.tryParse(_capacidadCtrl.text);
      if (cap == null || cap > 2000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La capacidad máxima es 2000 GB'), backgroundColor: Colors.red));
        return;
      }
    }

    // ------------------------------------

    /* 📸 VALIDACIÓN DE FOTOS COMENTADA
    // 1. VALIDAR FOTOS
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes subir fotos de Contrato y Celular'), backgroundColor: Colors.red));
      return;
    }
    */

    // Guardar crédito en Provider

    setState(() => _isUploading = true);

    // Dialogo de Carga
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                // ✅ CAMBIO: TEXTO SOLICITADO
                Text("Procesando solicitud...", style: TextStyle(fontWeight: FontWeight.bold))
              ]
          ),
        ),
      ),
    );

    try {
      // final firebaseService = FirebaseService(); // 📸 COMENTADO

      // 2. SUBIR EVIDENCIAS
      // String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos'); // 📸 COMENTADO
      // String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares');   // 📸 COMENTADO

      /* 📸 VALIDACIÓN URL COMENTADA
      if (urlContrato == null || urlCelular == null) throw Exception("Error al subir evidencias");
      */

      // ⚠️ ELIMINADO: if (mounted) Navigator.pop(context); (ESTO CERRABA EL DIALOGO MUY RÁPIDO)

      // 3. CREAR DTO
      final credito = CreditoDTO(
        montoTotal: double.parse(_precioCtrl.text),
        entrada: double.tryParse(_entradaCtrl.text) ?? 0,
        plazoCuotas: int.parse(_cuotasCtrl.text) ,//_plazoSeleccionado!,
        frecuenciaPago: _frecuencia,
        diaPago: _fechaPago,
        valorPorCuota: _valorCuota,
        montoPendiente: _montoFinanciar,
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: 'Pendiente',
        fechaCreacion: DateTime.now().toUtc(),
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        estadoCuota: "Pendiente",
        abonadoTotal: 0.0,
        // ASIGNAMOS LAS URLS
        fotoContratoUrl: null, // urlContrato, // 📸 URL COMENTADA
        fotoCelularUrl: null,  // urlCelular,  // 📸 URL COMENTADA

        // NUEVOS CAMPOS PRODUCTO
        tipoProducto: _tipoProducto,
        imei: (_tipoProducto == 'Teléfono') ? _imeiCtrl.text : null,
        // ✅ ASIGNACIÓN AL DTO
        nombrePropietario: _propietarioCreditoCtrl.text,
        capacidad: int.tryParse(_capacidadCtrl.text),
      );

      final registerProvider = context.read<RegisterProvider>();
      registerProvider.setCredito(credito);

      // 4. ENVIAR CODIGO DE VERIFICACIÓN
      final usuarioFinal = registerProvider.getUsuarioFinal();
      final correoUser = usuarioFinal.correo;

      if (correoUser == null || correoUser.isEmpty) {
        if (mounted) Navigator.pop(context); // CERRAR SI HAY ERROR
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo no disponible')));
        return;
      }

      final resultado = await validarCuenta.enviarCodigoCompleto(usuarioFinal);

      // ✅ CAMBIO: AHORA SÍ CERRAMOS EL DIALOGO, JUSTO ANTES DE CAMBIAR DE PANTALLA
      if (mounted) Navigator.pop(context);

      setState(() => _isUploading = false);

      if (resultado['exito'] == true) {
        context.push('/verify-otp', extra: correoUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['msg'] ?? 'El correo o número de cédula ya se encuentra registrado.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

    } catch (e) {
      if (mounted) Navigator.pop(context); // CERRAR SI HAY EXCEPCIÓN
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ----------------------------------------------------------------------
  // 🟢 WIDGET CALCULADORA VISUAL
  // ----------------------------------------------------------------------
  Widget _buildCalculatorVisualizer(ThemeData theme) {
    if (_montoFinanciar <= 0) return const SizedBox.shrink();

    final TextStyle valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor);
    final TextStyle labelStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);

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
              Column(children: [Text("\$${_precioCtrl.text}", style: valueStyle), Text("Precio", style: labelStyle)]),
              const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
              Column(children: [Text("\$${_entradaCtrl.text.isEmpty ? '0' : _entradaCtrl.text}", style: valueStyle), Text("Entrada", style: labelStyle)]),
              const Icon(Icons.drag_handle, size: 20, color: Colors.grey), // Igual
              Column(children: [Text("\$${_montoFinanciar.toStringAsFixed(2)}", style: valueStyle), Text("A Financiar", style: labelStyle)]),
            ],
          ),
          const Divider(height: 25),
          // OPERACIÓN 2: DIVISIÓN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_montoFinanciar.toStringAsFixed(2)}", style: valueStyle), Text("Saldo", style: labelStyle)]),
              const Icon(Icons.percent, size: 20, color: Colors.orangeAccent), // División visual
              Column(children: [Text(_cuotasCtrl.text.isEmpty ? '1' : _cuotasCtrl.text, style: valueStyle), Text("Pagos ($_frecuencia)", style: labelStyle)]),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 4: Configuración de crédito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- RESUMEN ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Text('Saldo a Financiar', style: TextStyle(color: Colors.white70)),
                  Text('\$${_montoFinanciar.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Cuota: \$${_valorCuota.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Text('Prox: ${DateFormat('dd/MM').format(_proximaCuota)}', style: const TextStyle(color: Colors.greenAccent)),
                  ])
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ CAMPO PROPIETARIO CREDITO (PRIMERA OPCIÓN)
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

            // --- FILA 1: MODELO y CAPACIDAD ---
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

            // --- FILA 2: IMEI (Si es teléfono, abajo) ---
            if (_tipoProducto == 'Teléfono') ...[
              const SizedBox(height: 15),
              CustomTextField(label: 'IMEI', controller: _imeiCtrl, icon: Icons.qr_code),
            ],

            const SizedBox(height: 15),

            // --- CAMPOS ---
            // ✏️ CAMBIO ESTÉTICO: Ícono más general
            CustomTextField(label: 'Precio Equipo (Total)', controller: _precioCtrl, keyboardType: TextInputType.number, icon: Icons.monetization_on_outlined),
            const SizedBox(height: 15),
            CustomTextField(label: 'Entrada (Pago Inicial)', controller: _entradaCtrl, keyboardType: TextInputType.number, icon: Icons.monetization_on),
            const SizedBox(height: 15),


            CustomTextField(label: 'Plazo (Cuotas)', controller: _cuotasCtrl, keyboardType: TextInputType.number, icon: Icons.calendar_view_week),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _frecuencia,
              decoration: InputDecoration(labelText: 'Frecuencia de Pago', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: ['Semanal', 'Quincenal', 'Mensual'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (val) { setState(() { _frecuencia = val!; _calcularValores(); }); },
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Fecha de Inicio / Pago'), subtitle: Text(DateFormat('dd MMMM yyyy').format(_fechaPago)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.5))),
              onTap: _seleccionarFecha,
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
                Expanded(child: PhotoUploadCard(label: 'Foto Contrato *', onImageSelected: (f) => _fotoContrato = f)),
                const SizedBox(width: 10),
                Expanded(child: PhotoUploadCard(label: 'Foto Celular *', onImageSelected: (f) => _fotoCelular = f)),
              ],
            ),
            */

            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _finalizarRegistro,
                    child: const Text('FINALIZAR Y VERIFICAR', style: TextStyle(fontSize: 16))
                )
            ),
          ],
        ),
      ),
    );
  }
}
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/register_provider.dart';
import '../../models/credito_dto.dart';
import '../../data/services/auth_service.dart';
import '../widgets/custom_text_field.dart';
// import '../widgets/photo_upload_card.dart'; // Descomentar si usas fotos
import '../../services/UsuarioRegistroData.dart';
import '../../models/cliente_dto.dart';
import '../../models/enviar_codigo_dto.dart';
import '../../services/ValidarCuenta.dart';
// import '../../services/firebase_service.dart'; // Descomentar si usas fotos

class CreditDataScreen extends StatefulWidget {
  const CreditDataScreen({super.key});

  @override
  State<CreditDataScreen> createState() => _CreditDataScreenState();
}

class _CreditDataScreenState extends State<CreditDataScreen> {
  UsuarioRegistroData registroData = UsuarioRegistroData();

  // Controladores
  final _precioCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _cuotasCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _imeiCtrl = TextEditingController();
  final _propietarioCreditoCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();

  // Variables de Estado
  String _tipoVenta = 'Crédito'; // Valor por defecto
  final List<String> _tiposVenta = ['Crédito', 'Contado'];
  bool get _esContado => _tipoVenta == 'Contado';

  String _frecuencia = 'Semanal';
  DateTime _fechaPago = DateTime.now();

  double _montoFinanciar = 0;
  double _valorCuota = 0;
  DateTime _proximaCuota = DateTime.now();

  String _tipoProducto = 'Teléfono';
  final List<String> _tiposProducto = ['Teléfono', 'Televisor'];

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _precioCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _cuotasCtrl.addListener(_calcularValores);
  }

  @override
  void dispose() {
    _precioCtrl.dispose();
    _entradaCtrl.dispose();
    _cuotasCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _imeiCtrl.dispose();
    _propietarioCreditoCtrl.dispose();
    _capacidadCtrl.dispose();
    super.dispose();
  }

  void _calcularValores() {
    final precio = double.tryParse(_precioCtrl.text) ?? 0;

    // 🔥 SI ES CONTADO, NO HAY DEUDA
    if (_esContado) {
      setState(() {
        _montoFinanciar = 0;
        _valorCuota = 0;
        // La fecha de pago no importa en contado, pero la mantenemos válida
      });
      return;
    }

    // 🔥 SI ES CRÉDITO, CALCULAMOS
    final entrada = double.tryParse(_entradaCtrl.text) ?? 0;
    final cuotas = int.tryParse(_cuotasCtrl.text) ?? 1;

    setState(() {
      _montoFinanciar = precio - entrada;
      if (_montoFinanciar < 0) _montoFinanciar = 0;
      _valorCuota = (cuotas > 0) ? _montoFinanciar / cuotas : 0;
      _proximaCuota = _calcularProximaFecha(_fechaPago, _frecuencia);
    });
  }

  DateTime _calcularProximaFecha(DateTime fechaBase, String frecuencia) {
    switch (frecuencia) {
      case 'Semanal': return fechaBase.add(const Duration(days: 7));
      case 'Quincenal': return fechaBase.add(const Duration(days: 15));
      case 'Mensual': return DateTime(fechaBase.year, fechaBase.month + 1, fechaBase.day);
      default: return fechaBase.add(const Duration(days: 7));
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaPago,
      firstDate: DateTime.now().toUtc(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _fechaPago = picked;
        _calcularValores();
      });
    }
  }

  void _finalizarRegistro() async {
    // 1. Validaciones Comunes
    if (_precioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Define el precio del equipo')));
      return;
    }

    if (_propietarioCreditoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El propietario es requerido'), backgroundColor: Colors.red));
      return;
    }

    if (_tipoProducto == 'Teléfono' && _imeiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El IMEI es requerido para teléfonos'), backgroundColor: Colors.red));
      return;
    }

    // 2. Validaciones Específicas de Crédito
    if (!_esContado) {
      if (_cuotasCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Define el número de cuotas')));
        return;
      }

      // Validación de máximos de cuotas
      final int cuotasIngresadas = int.tryParse(_cuotasCtrl.text) ?? 0;
      int maxCuotas = 24;
      if (_frecuencia == 'Semanal') maxCuotas = 52;
      if (_frecuencia == 'Quincenal') maxCuotas = 48;
      if (_frecuencia == 'Mensual') maxCuotas = 24;

      if (cuotasIngresadas > maxCuotas) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Para $_frecuencia el máximo es $maxCuotas cuotas'), backgroundColor: Colors.red));
        return;
      }
    }

    setState(() => _isUploading = true);

    // Dialogo de Carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Procesando solicitud...", style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );

    try {
      // AQUÍ IRÍA LA LÓGICA DE SUBIDA DE FOTOS (Firebase)

      // 3. Preparar datos finales según el tipo de venta
      final double precioTotal = double.parse(_precioCtrl.text);

      // Si es contado, entrada = total, pendiente = 0
      final double entradaFinal = _esContado ? precioTotal : (double.tryParse(_entradaCtrl.text) ?? 0);
      final double montoPendienteFinal = _esContado ? 0 : _montoFinanciar;
      final int plazoFinal = _esContado ? 1 : int.parse(_cuotasCtrl.text);
      final String frecuenciaFinal = _esContado ? 'Unico' : _frecuencia;
      final double valorCuotaFinal = _esContado ? 0 : _valorCuota;
      final String estadoFinal = _esContado ? 'Pagado' : 'Pendiente';

      // 4. Crear DTO
      final credito = CreditoDTO(
        esVentaContado: _esContado, // 🔥 Flag importante
        montoTotal: precioTotal,
        entrada: entradaFinal,
        montoPendiente: montoPendienteFinal,
        plazoCuotas: plazoFinal,
        frecuenciaPago: frecuenciaFinal,
        diaPago: _fechaPago,
        valorPorCuota: valorCuotaFinal,
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: estadoFinal,
        estadoCuota: _esContado ? 'Pagado' : 'Pendiente',
        fechaCreacion: DateTime.now().toUtc(),
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        abonadoTotal: _esContado ? precioTotal : 0.0,
        fotoContratoUrl: null,
        fotoCelularUrl: null,
        tipoProducto: _tipoProducto,
        imei: (_tipoProducto == 'Teléfono') ? _imeiCtrl.text : null,
        nombrePropietario: _propietarioCreditoCtrl.text,
        capacidad: int.tryParse(_capacidadCtrl.text),
      );

      final registerProvider = context.read<RegisterProvider>();
      registerProvider.setCredito(credito);

      // 5. Enviar código de verificación
      final usuarioFinal = registerProvider.getUsuarioFinal();
      final correoUser = usuarioFinal.correo;

      if (correoUser == null || correoUser.isEmpty) {
        if (mounted) Navigator.pop(context);
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo no disponible')));
        return;
      }

      final resultado = await validarCuenta.enviarCodigoCompleto(usuarioFinal);

      if (mounted) Navigator.pop(context); // Cerrar dialogo

      setState(() => _isUploading = false);

      if (resultado['exito'] == true) {
        context.push('/verify-otp', extra: correoUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['msg'] ?? 'El correo o número de cédula ya se encuentra registrado.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // Widget Calculadora Visual
  Widget _buildCalculatorVisualizer(ThemeData theme) {
    if (_montoFinanciar <= 0) return const SizedBox.shrink();

    final TextStyle valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor);
    final TextStyle labelStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_precioCtrl.text}", style: valueStyle), Text("Precio", style: labelStyle)]),
              const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
              Column(children: [Text("\$${_entradaCtrl.text.isEmpty ? '0' : _entradaCtrl.text}", style: valueStyle), Text("Entrada", style: labelStyle)]),
              const Icon(Icons.drag_handle, size: 20, color: Colors.grey),
              Column(children: [Text("\$${_montoFinanciar.toStringAsFixed(2)}", style: valueStyle), Text("A Financiar", style: labelStyle)]),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("\$${_montoFinanciar.toStringAsFixed(2)}", style: valueStyle), Text("Saldo", style: labelStyle)]),
              const Icon(Icons.percent, size: 20, color: Colors.orangeAccent),
              Column(children: [Text(_cuotasCtrl.text.isEmpty ? '1' : _cuotasCtrl.text, style: valueStyle), Text("Pagos ($_frecuencia)", style: labelStyle)]),
              const Icon(Icons.arrow_right_alt, size: 30, color: Colors.green),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 4: Configuración de venta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- SELECTOR DE TIPO DE VENTA ---
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                children: _tiposVenta.map((tipo) {
                  final isSelected = _tipoVenta == tipo;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _tipoVenta = tipo;
                          _calcularValores();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: isSelected ? theme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : []
                        ),
                        child: Text(
                          tipo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey[700]
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // --- RESUMEN DE FINANCIAMIENTO (Solo si es Crédito) ---
            if (!_esContado) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    const Text('Saldo a Financiar', style: TextStyle(color: Colors.white70)),
                    Text('\$${_montoFinanciar.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white24),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Cuota: \$${_valorCuota.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      Text('Prox: ${DateFormat('dd/MM').format(_proximaCuota)}', style: const TextStyle(color: Colors.greenAccent)),
                    ])
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- FORMULARIO COMÚN ---
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
                    onChanged: (val) => setState(() => _tipoProducto = val!),
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
                    )
                ),
              ],
            ),

            if (_tipoProducto == 'Teléfono') ...[
              const SizedBox(height: 15),
              CustomTextField(label: 'IMEI', controller: _imeiCtrl, icon: Icons.qr_code),
            ],

            const SizedBox(height: 15),

            // CAMPO PRECIO
            CustomTextField(
                label: _esContado ? 'Valor Pagado (Total)' : 'Precio Equipo (Total)',
                controller: _precioCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.monetization_on_outlined
            ),

            // 🔥 CAMPOS EXCLUSIVOS DE CRÉDITO
            if (!_esContado) ...[
              const SizedBox(height: 15),
              CustomTextField(label: 'Entrada (Pago Inicial)', controller: _entradaCtrl, keyboardType: TextInputType.number, icon: Icons.monetization_on),
              const SizedBox(height: 15),
              CustomTextField(label: 'Plazo (Cuotas)', controller: _cuotasCtrl, keyboardType: TextInputType.number, icon: Icons.calendar_view_week),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _frecuencia,
                decoration: InputDecoration(labelText: 'Frecuencia de Pago', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Semanal', 'Quincenal', 'Mensual'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (val) { setState(() { _frecuencia = val!; _calcularValores(); }); },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Fecha de Inicio / Pago'), subtitle: Text(DateFormat('dd MMMM yyyy').format(_fechaPago)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.5))),
                onTap: _seleccionarFecha,
              ),
              _buildCalculatorVisualizer(theme),
            ] else ...[
              // Mensaje informativo para contado
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
                child: const Row(children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(child: Text("Venta a contado. No se generará deuda pendiente."))
                ]),
              )
            ],

            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _finalizarRegistro,
                    child: const Text('FINALIZAR Y VERIFICAR', style: TextStyle(fontSize: 16))
                )
            ),
          ],
        ),
      ),
    );
  }
}