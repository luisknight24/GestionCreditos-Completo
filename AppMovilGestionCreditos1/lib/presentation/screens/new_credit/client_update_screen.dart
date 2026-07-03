/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
// import '../../../providers/register_provider.dart'; // YA NO LO NECESITAMOS AQUÍ
import '../../../models/detalle_cliente_dto.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../presentation/widgets/photo_upload_card.dart';
import '../../../services/firebase_service.dart';
import '../../../services/usuario_service.dart';
import '../../../models/DetalleCLientePostDTO.dart';

class ClientUpdateScreen extends StatefulWidget {
  const ClientUpdateScreen({super.key});

  @override
  State<ClientUpdateScreen> createState() => _ClientUpdateScreenState();
}

class _ClientUpdateScreenState extends State<ClientUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  // File? _fotoCliente; // 📸 COMENTADO
  bool _isLoading = false;

  // Servicio para cargar datos
  final UsuarioService _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    // En lugar de leer del provider, cargamos del API
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    try {
      // Obtenemos los datos completos (incluida la cédula que agregamos al DTO)
      final cliente = await _usuarioService.getCliente(forceRefresh: true);

      if (mounted) {
        setState(() {
          _nombreCtrl.text = cliente.nombreApellidos;
          //_cedulaCtrl.text = cliente.cedula; // Asumiendo que traes la cédula
          //_telefonoCtrl.text = cliente.telefono;
          //_direccionCtrl.text = cliente.direccion;
        });
      }
    } catch (e) {
      debugPrint("Error cargando datos: $e");
    }
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _actualizarDatos() async {
    if (!_formKey.currentState!.validate()) return;

    /* 📸 VALIDACIÓN DE FOTO COMENTADA
    if (_fotoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Debes subir tu Foto (Selfie) actualizada'),
          backgroundColor: Colors.orange
      ));
      return;
    }
    */

    setState(() => _isLoading = true);

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
              Text("Actualizando perfil...", style: TextStyle(fontWeight: FontWeight.bold)), // Texto ajustado
            ],
          ),
        ),
      ),
    );

    try {
      // final firebaseService = FirebaseService(); // 📸 COMENTADO
      // 1. SUBIR FOTO
      // String? urlCliente = await firebaseService.uploadImage(_fotoCliente!, 'clientes'); // 📸 COMENTADO

      // Simulación de tiempo si es necesario
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) Navigator.pop(context); // Cerrar diálogo

      // 2. CREAR DTO
      final detalleUpdate = DetalleClientePostDTO(
        numeroCedula: _cedulaCtrl.text,
        nombreApellidos: _nombreCtrl.text,
        telefono: _telefonoCtrl.text,
        direccion: _direccionCtrl.text,
        fotoClienteUrl: null, // urlCliente, // 📸 URL COMENTADA, PASAMOS NULL
      );

      // 3. ACTUALIZAR
      await _usuarioService.actualizarDetalleClienteFotos(detalleUpdate);

      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/new-credit-store');
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar datos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 1: Validar Datos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 20),

              // --- CAMPOS BLOQUEADOS ---
              CustomTextField(
                label: 'Cédula',
                controller: _cedulaCtrl,
                keyboardType: TextInputType.number,
                //readOnly: true,
                // ✅ VALIDACIÓN AGREGADA
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (value.length != 10) return 'Debe tener 10 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              CustomTextField(
                label: 'Nombre Completo',
                controller: _nombreCtrl,
                icon: Icons.person,
                readOnly: true, // Bloqueado
              ),
              const SizedBox(height: 15),

              // --- CAMPOS EDITABLES ---
              CustomTextField(
                label: 'Teléfono',
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
                // ✅ VALIDACIÓN AGREGADA
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (value.length != 10) return 'Debe tener 10 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(label: 'Dirección', controller: _direccionCtrl, icon: Icons.location_on),

              /* 📸 SECCIÓN FOTO COMENTADA
              const SizedBox(height: 30),
              FadeInDown(child: const Text('Evidencia de Identidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 15),

              Center(
                child: SizedBox(
                  width: 200,
                  child: PhotoUploadCard(label: 'Foto Cliente (Selfie) *', onImageSelected: (f) => _fotoCliente = f),
                ),
              ),
              */

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _actualizarDatos,
                  child: const Text('SIGUIENTE: DATOS TIENDA'),
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
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/detalle_cliente_dto.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../presentation/widgets/photo_upload_card.dart';
import '../../../services/firebase_service.dart';
import '../../../services/usuario_service.dart';
import '../../../models/DetalleCLientePostDTO.dart';

class ClientUpdateScreen extends StatefulWidget {
  const ClientUpdateScreen({super.key});

  @override
  State<ClientUpdateScreen> createState() => _ClientUpdateScreenState();
}

class _ClientUpdateScreenState extends State<ClientUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  // NUEVO: Controlador
  //final _propietarioCreditoCtrl = TextEditingController();

  // File? _fotoCliente; // 📸 COMENTADO
  bool _isLoading = false;

  // Servicio para cargar datos
  final UsuarioService _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    // En lugar de leer del provider, cargamos del API
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    try {
      // Obtenemos los datos completos
      final cliente = await _usuarioService.getCliente(forceRefresh: true);

      if (mounted) {
        setState(() {
          _nombreCtrl.text = cliente.nombreApellidos;
          // Asumiendo que el cliente trae el detalle y dentro el propietarioCredito
          // Si el objeto cliente directamente no lo tiene, ajusta esta línea según tu estructura
          //_propietarioCreditoCtrl.text = cliente.detalleCliente?.propietarioCredito ?? '';

          //_cedulaCtrl.text = cliente.cedula;
          //_telefonoCtrl.text = cliente.telefono;
          //_direccionCtrl.text = cliente.direccion;
        });
      }
    } catch (e) {
      debugPrint("Error cargando datos: $e");
    }
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

  void _actualizarDatos() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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
              Text("Actualizando perfil...", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    try {
      // Simulación de tiempo si es necesario
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) Navigator.pop(context); // Cerrar diálogo

      // 2. CREAR DTO
      final detalleUpdate = DetalleClientePostDTO(
        numeroCedula: _cedulaCtrl.text,
        nombreApellidos: _nombreCtrl.text,
        telefono: _telefonoCtrl.text,
        direccion: _direccionCtrl.text,
        //propietarioCredito: _propietarioCreditoCtrl.text, // NUEVO: Asignación
        fotoClienteUrl: null,
      );

      // 3. ACTUALIZAR
      await _usuarioService.actualizarDetalleClienteFotos(detalleUpdate);

      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/new-credit-store');
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar datos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 1: Validar Datos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 20),

              // NUEVO: Campo de texto
              //CustomTextField(
              //  label: 'Propietario del Crédito',
              //  controller: _propietarioCreditoCtrl,
              //  icon: Icons.assignment_ind,
              //),
              //const SizedBox(height: 15),

              // --- CAMPOS BLOQUEADOS ---
              CustomTextField(
                label: 'Cédula',
                controller: _cedulaCtrl,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (value.length != 10) return 'Debe tener 10 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              CustomTextField(
                label: 'Nombre Completo',
                controller: _nombreCtrl,
                icon: Icons.person,
                readOnly: true,
              ),
              const SizedBox(height: 15),

              // --- CAMPOS EDITABLES ---
              CustomTextField(
                label: 'Teléfono',
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (value.length != 10) return 'Debe tener 10 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              CustomTextField(label: 'Dirección', controller: _direccionCtrl, icon: Icons.location_on),
              const SizedBox(height: 15),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _actualizarDatos,
                  child: const Text('SIGUIENTE: DATOS TIENDA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}