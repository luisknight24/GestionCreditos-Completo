import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../providers/register_provider.dart';

import '../widgets/custom_text_field.dart';
import '../../services/UsuarioRegistroData.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  UsuarioRegistroData registroData = UsuarioRegistroData();
  
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }


  void _onNextPressed() {
    if (!_formKey.currentState!.validate()) return;

  
    final registerProvider = context.read<RegisterProvider>();
registerProvider.setUsuarioBasico(
  _nameController.text,
  _emailController.text,
  _passController.text,
);
    final usuario = registerProvider.usuario;
  // print("=== Datos del Cliente Registrado ===");
  print("Cédula: ${usuario.nombreApellidos}");
  print("Nombre: ${usuario.nombreApellidos}");
  print("Teléfono: ${usuario.correo}");
  print("Dirección: ${usuario.clave}");
  print("Foto Cliente URL: ${usuario.rolId}");
 
   context.push('/client-data');
    // --- CAMBIO AQUÍ: Usamos el nuevo método del Provider ---
    
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: size.height * 0.25,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(60)),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(height: 10),
                        FadeInDown(child: const Text('Paso 1', style: TextStyle(color: Colors.white70, fontSize: 18))),
                        FadeInDown(child: const Text('Crear Cuenta', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ... (El código de la foto se mantiene igual que antes) ...
/*                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 110, height: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                              border: Border.all(color: theme.primaryColor, width: 2),
                            ),
                            child: _selectedImage == null ? Icon(Icons.person, size: 50, color: Colors.grey[400]) : null,
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceModal,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: theme.colorScheme.secondary, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),*/

                    CustomTextField(
                      label: 'Nombre y Apellidos', icon: Icons.person_outline, controller: _nameController,
                      validator: (v) => (v == null || v.trim().length < 5) ? 'Nombre completo requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Correo Electrónico', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, controller: _emailController,
                      validator: (v) => (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v ?? '')) ? 'Correo inválido' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
                        if (value.length < 12) return 'Mínimo 12 caracteres';
                        if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe tener al menos una mayúscula';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(onPressed: _onNextPressed, child: const Text('SIGUIENTE', style: TextStyle(fontSize: 18))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón auxiliar (mismo de siempre)
class _OptionBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _OptionBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [CircleAvatar(radius: 30, backgroundColor: Colors.grey[200], child: Icon(icon, color: Theme.of(context).primaryColor)), const SizedBox(height: 5), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}