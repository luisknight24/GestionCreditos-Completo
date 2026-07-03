import 'dart:io'; // Necesario para File
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart'; // Si necesitas providers
import '../../models/credito_dto.dart';
//import '../../data/services/firebase_service.dart'; // Asegúrate de tener este servicio
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart'; // Tu widget de fotos

class NewCreditRequestScreen extends StatefulWidget {
  final int clienteId;
  const NewCreditRequestScreen({super.key, required this.clienteId});

  @override
  State<NewCreditRequestScreen> createState() => _NewCreditRequestScreenState();
}

class _NewCreditRequestScreenState extends State<NewCreditRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLADORES CRÉDITO ---
  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();

  // --- CONTROLADORES TIENDA (Datos para el nuevo crédito) ---
  final _nombreTiendaCtrl = TextEditingController();
  final _codigoTiendaCtrl = TextEditingController();
  final _encargadoCtrl = TextEditingController();

  // --- VARIABLES DE ESTADO ---
  String? _frecuenciaSeleccionada;
  bool _isLoading = false;
  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];

  // --- VARIABLES PARA FOTOS ---
  File? _fotoContrato;
  File? _fotoCelular;
  File? _fotoCliente; // Opcional si quieres validar identidad de nuevo

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _plazoCtrl.dispose();
    _nombreTiendaCtrl.dispose();
    _codigoTiendaCtrl.dispose();
    _encargadoCtrl.dispose();
    super.dispose();
  }

  void _enviarSolicitud() async {
    // 1. Validaciones Básicas
    if (!_formKey.currentState!.validate()) return;

    if (_frecuenciaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia de pago')));
      return;
    }

    // 2. Validación de Evidencias (Obligatorias para un nuevo crédito)
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes subir la foto del Contrato y del Nuevo Celular'), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. SUBIDA DE IMÁGENES A FIREBASE (Integración real o simulada)
      // Descomenta las líneas del servicio cuando esté listo tu backend para recibir las URLs
      //final firebaseService = FirebaseService();

      // String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos_nuevos');
      // String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares_nuevos');

      // Simulación de espera de subida
      await Future.delayed(const Duration(seconds: 2));

      // 4. PREPARACIÓN DEL DTO (Datos Financieros)

      // NOTA PARA IMPLEMENTACIÓN DEL BACKEND:
      // Aquí tienes dos opciones:
      // A. Tu endpoint 'CrearCredito' acepta solo CreditoDTO. En ese caso, las fotos y datos de tienda
      //    deben ir en otro endpoint o el CreditoDTO necesita actualizarse.
      // B. Creas un objeto anónimo aquí con todo para enviar al backend:

      /*
      final payloadCompleto = {
        'Credito': solicitudCredito.toJson(),
        'Tienda': {
           'Nombre': _nombreTiendaCtrl.text,
           'Codigo': _codigoTiendaCtrl.text,
           'Encargado': _encargadoCtrl.text
        },
        'Evidencias': {
           'UrlContrato': urlContrato,
           'UrlCelular': urlCelular
        }
      };
      await apiService.enviarSolicitudCompleta(payloadCompleto);
      */

      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarDialogoExito(double.parse(_montoCtrl.text));
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _mostrarDialogoExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text('¡Solicitud Enviada!'),
          ],
        ),
        content: Text(
          'Se ha generado la solicitud por \$$monto.\n\n'
              'Tus documentos y datos de la tienda han sido enviados a revisión.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context.go('/home');
            },
            child: const Text('VOLVER AL INICIO'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Crédito', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN 1: DATOS FINANCIEROS ---
              _buildSectionTitle(theme, '1. Configuración del Crédito', Icons.calculate),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Monto del Equipo (\$)',
                controller: _montoCtrl,
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                label: 'Entrada Inicial (\$)',
                controller: _entradaCtrl,
                icon: Icons.money_off,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Plazo (Cuotas)',
                      controller: _plazoCtrl,
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Frecuencia',
                        prefixIcon: const Icon(Icons.repeat),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      value: _frecuenciaSeleccionada,
                      items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) => setState(() => _frecuenciaSeleccionada = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // --- SECCIÓN 2: DATOS DE LA TIENDA ---
              _buildSectionTitle(theme, '2. Datos de la Tienda', Icons.store),
              const SizedBox(height: 10),
              const Text('Indica dónde estás realizando esta nueva compra.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Nombre de la Tienda',
                controller: _nombreTiendaCtrl,
                icon: Icons.storefront,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Código Tienda',
                      controller: _codigoTiendaCtrl,
                      icon: Icons.qr_code,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      label: 'Vendedor',
                      controller: _encargadoCtrl,
                      icon: Icons.person_pin,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // --- SECCIÓN 3: EVIDENCIA DIGITAL ---
              _buildSectionTitle(theme, '3. Evidencia Digital', Icons.camera_alt),
              const SizedBox(height: 10),
              const Text('Sube las fotos del nuevo equipo y contrato.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PhotoUploadCard(
                      label: 'Foto contrato',
                      onImageSelected: (file) => _fotoContrato = file,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: PhotoUploadCard(
                      label: 'Foto celular',
                      onImageSelected: (file) => _fotoCelular = file,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Foto Cliente es opcional en re-crédito, pero buena práctica
              Center(
                child: SizedBox(
                  width: 160,
                  child: PhotoUploadCard(
                    label: 'Foto con equipo',
                    onImageSelected: (file) => _fotoCliente = file,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // --- BOTÓN DE ENVÍO ---
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enviarSolicitud,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 15),
                        Text("Procesando...", style: TextStyle(color: Colors.white))
                      ],
                    )
                        : const Text('ENVIAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para títulos de sección
  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return FadeInLeft(
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor
            ),
          ),
        ],
      ),
    );
  }
}