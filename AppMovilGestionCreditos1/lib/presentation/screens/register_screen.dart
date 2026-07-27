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
  // print("=== Datos del cliente Registrado ===");
  print("Cédula: ${usuario.nombreApellidos}");
  print("Nombre: ${usuario.nombreApellidos}");
  print("Teléfono: ${usuario.correo}");
  print("Dirección: ${usuario.clave}");
  print("Foto Cliente URL: ${usuario.rolId}");
 
   context.push('/client-data');
    
    
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
                                  'Paso 1 de 4',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ingresa tus datos básicos para iniciar tu registro',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

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
                                children: [
                                  CustomTextField(
                                    label: 'Nombre y apellidos',
                                    icon: Icons.person_outline,
                                    controller: _nameController,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (v) => (v == null || v.trim().length < 5) ? 'Nombre completo requerido' : null,
                                  ),
                                  const SizedBox(height: 18),
                                  CustomTextField(
                                    label: 'Correo electrónico',
                                    icon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (v) => (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v ?? '')) ? 'Correo inválido' : null,
                                  ),
                                  const SizedBox(height: 18),
                                  CustomTextField(
                                    label: 'Contraseña',
                                    icon: Icons.lock_open_outlined,
                                    isPassword: true,
                                    controller: _passController,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'La Contraseña es obligatoria';
                                      if (value.length < 12) return 'Mínimo 12 caracteres';
                                      if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe tener al menos una mayúscula';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 30),
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
                                            'Datos cliente',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
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
