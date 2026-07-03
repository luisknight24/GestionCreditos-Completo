import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../../models/reset_password_dto.dart';
import '../widgets/custom_text_field.dart';
import '../../services/Verificacion.dart';
import '../widgets/custom_text_field.dart';
import '../../models/ResetPasswordUnionDTO.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _cambiarClave() async {
    // 1️⃣ Validamos el formulario
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 2️⃣ Creamos el DTO con token y nueva contraseña
    final dto = ResetPasswordDTO(
      token: _tokenCtrl.text,
      nuevaClave: _newPassCtrl.text,
    );

    // 3️⃣ Llamamos al servicio Verificacion
    final service = Verificacion();
    final resultado = await service.resetPassword(dto);

    setState(() => _isLoading = false);

    // 4️⃣ Revisamos el resultado
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada. Inicia sesión.')),
      );
      context.go('/login'); // Navegamos a login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido o error.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Código / Token recibido',
                controller: _tokenCtrl,
                icon: Icons.vpn_key,
                validator: (v) => v!.isEmpty ? 'Ingresa el código' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Nueva Contraseña',
                controller: _newPassCtrl,
                isPassword: true,
                icon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obligatorio';
                  if (value.length < 12) return 'Mínimo 12 caracteres';
                  if (!value.contains(RegExp(r'[A-Z]'))) return 'Falta una mayúscula';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cambiarClave,
                        child: const Text('ACTUALIZAR CONTRASEÑA'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}