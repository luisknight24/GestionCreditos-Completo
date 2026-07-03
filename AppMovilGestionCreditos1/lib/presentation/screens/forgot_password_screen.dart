import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../../models/forgot_password_dto.dart';
import '../widgets/custom_text_field.dart';
import '../../models/forgot_password_dto.dart';
import '../../services/Verificacion.dart'; 

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _enviarSolicitud() async {
    // 1️⃣ Validamos el formulario
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 2️⃣ Creamos el DTO con el correo
    final dto = ForgotPasswordDTO(correo: _emailCtrl.text);

    // 3️⃣ Llamamos al servicio Verificacion
    final service = Verificacion();
    final resultado = await service.forgotPassword(dto);

    setState(() => _isLoading = false);

    // 4️⃣ Revisamos el resultado
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo enviado correctamente. Revisa tu bandeja.')),
      );
      context.push('/reset-password'); // Navegamos a la pantalla de reset
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error. Verifica el correo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Ingresa tu correo y te enviaremos un código para restablecer tu clave.',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Correo',
                controller: _emailCtrl,
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El correo es obligatorio';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value))
                    return 'Ingresa un correo válido (@ y dominio)';
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
                        onPressed: _enviarSolicitud,
                        child: const Text('ENVIAR CÓDIGO'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}