import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/register_provider.dart';
import '../../models/detalle_cliente_dto.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart';
import '../../services/UsuarioRegistroData.dart';
import '../../services/firebase_service.dart';
import '../../models/cliente_dto.dart';

class ClientDataScreen extends StatefulWidget {
  const ClientDataScreen({super.key});

  @override
  State<ClientDataScreen> createState() => _ClientDataScreenState();
}

class _ClientDataScreenState extends State<ClientDataScreen> {
  bool _isUploading = false;
  UsuarioRegistroData registroData = UsuarioRegistroData();
  final _formKey = GlobalKey<FormState>();

  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  // NUEVO: Controlador
  //final _propietarioCreditoCtrl = TextEditingController();

  // File? _fotoCliente; //  COMENTADO

  @override
  void initState() {
    super.initState();
    final nombreRegistrado = context.read<RegisterProvider>().usuario.nombreApellidos;
    _nombreCtrl.text = nombreRegistrado ?? '';
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    //_propietarioCreditoCtrl.dispose(); // NUEVO: Dispose
    super.dispose();
  }

  void _onNextPressed() async {
    // 1. Validar Inputs
    if (!_formKey.currentState!.validate()) {
      return;
    }

    /*  VALIDACIÓN DE FOTO COMENTADA
    // 2. Validar Foto Cliente (Única obligatoria aquí)
    if (_fotoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes subir la foto del Cliente (Selfie)'),
            backgroundColor: Colors.red
        ),
      );
      return;
    }
    */

    /*
    // 3. Mostrar diálogo de carga
    setState(() => _isUploading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  "Guardando datos...", // Texto ajustado
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );


     */

    try {
      // final firebaseService = FirebaseService(); //  COMENTADO

      // 4. Subir SOLO foto cliente
      // final String? urlCliente = await firebaseService.uploadImage(_fotoCliente!, 'clientes'); //  COMENTADO


      //await Future.delayed(const Duration(seconds: 0)); // Simulación

      // Cerrar diálogo
      //if (mounted) Navigator.pop(context);
      //setState(() => _isUploading = false);

      /*  VALIDACIÓN URL COMENTADA
      if (urlCliente == null) {
        throw Exception("Error al subir la imagen.");
      }
      */

      // 5. Crear DTO Limpio
      final detalle = DetalleClienteDTO(
        numeroCedula: _cedulaCtrl.text,
        nombreApellidos: _nombreCtrl.text,
        telefono: _telefonoCtrl.text,
        direccion: _direccionCtrl.text,
        //propietarioCredito: _propietarioCreditoCtrl.text, // NUEVO: Asignación
        fotoClienteUrl: null,
      );

      // 6. Guardar en Provider
      final registerProvider = context.read<RegisterProvider>();
      registerProvider.setDetalleCliente(detalle);

      // 7. Guardar local
      registroData.cliente ??= ClienteDTO();
      registroData.cliente!.detalleCliente = detalle;

      // 8. Navegar
      if (mounted) context.push('/store-data');

    }
    catch (e) {
      // Manejo de errores
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
                // FONDO SECCIONADO CON GRADIENTES RADIALES (Mismo lenguaje visual)
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
                                  'Paso 2 de 4',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Datos del cliente',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completa la información personal del titular',
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
                                    label: 'Número de cédula',
                                    controller: _cedulaCtrl,
                                    keyboardType: TextInputType.number,
                                    icon: Icons.badge_outlined,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (v) => (v!.isEmpty || v.length != 10) ? 'Debe tener 10 dígitos' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: 'Nombres y apellidos',
                                    controller: _nombreCtrl,
                                    icon: Icons.person_outline,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: 'Teléfono',
                                    controller: _telefonoCtrl,
                                    keyboardType: TextInputType.phone,
                                    icon: Icons.phone_outlined,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (v) => (v!.isEmpty || v.length != 10) ? 'Debe ingresar 10 dígitos' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: 'Dirección / sector',
                                    controller: _direccionCtrl,
                                    icon: Icons.location_on_outlined,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 28),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _onNextPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        elevation: 6,
                                        shadowColor: const Color(0xFF10B981).withOpacity(0.35),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Datos tienda',
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
