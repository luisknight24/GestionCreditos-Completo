import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/usuario_service.dart';
import '../../models/ClienteMostrarDTO.dart';
import '../widgets/custom_text_field.dart'; // Asumiendo que reutilizas tus widgets

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioService _usuarioService = UsuarioService();

  // Controladores
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _correoController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      // Simulamos carga desde backend o usamos tu servicio real
      // final usuario = await _usuarioService.getCliente();
      // Por ahora usaremos datos mock para la maqueta si falla el servicio

      // Simulación de datos (Reemplazar con llamada real)
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _nombreController.text = "Luis Usuario"; // usuario.nombreApellidos
        _correoController.text = "luis@ejemplo.com"; // usuario.correo
        _telefonoController.text = "0991234567"; // usuario.celular
        _direccionController.text = "Av. Principal 123"; // usuario.direccion
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando perfil: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // AQUÍ CONECTAS CON EL BACKEND (MOCK)
    // await _usuarioService.updatePerfil(...);
    await Future.delayed(const Duration(seconds: 1)); // Simula petición

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: const AssetImage('assets/images/cellcompay_foreground.png'), // Tu asset
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: () {
                            // Lógica para subir foto
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Campos de Texto (Usando TextFormField estándar o tu CustomTextField)
              _buildTextField("Nombre Completo", _nombreController, Icons.person),
              const SizedBox(height: 15),
              _buildTextField("Correo Electrónico", _correoController, Icons.email, readOnly: true), // Correo usualmente no se edita fácil
              const SizedBox(height: 15),
              _buildTextField("Teléfono", _telefonoController, Icons.phone, inputType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField("Dirección", _direccionController, Icons.location_on),

              const SizedBox(height: 40),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo requerido';
        return null;
      },
    );
  }
}