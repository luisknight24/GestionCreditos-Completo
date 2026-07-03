import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:animate_do/animate_do.dart';
import '../../data/services/auth_service.dart';
import '../../services/usuario_service.dart';
import '../../models/verificar_dto.dart';
import '../../services/ValidarCuenta.dart';
import '../../services/UsuarioRegistroData.dart';
import '../../services/UsuarioRegistroData.dart';
import '../../providers/register_provider.dart';
import 'package:provider/provider.dart';
class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {

  UsuarioRegistroData registroData = UsuarioRegistroData();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
void _verificarCodigo() async {
  final codigo = _pinController.text.trim();

  // Validación básica del código
  if (codigo.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor ingresa el código completo')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Obtener correo del usuario desde el Provider
    final correoUser = context.read<RegisterProvider>().usuario.correo!;
    final datos = VerificarDTO(correo: correoUser, codigo: codigo);

    // Llamar al servicio para verificar el código
    final authService = ValidarCuenta();
    final exito = await authService.verificarCuenta1(datos);

    if (!exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código incorrecto o expirado.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Detener si el código es inválido
    }

    // ✅ Código correcto: el usuario ya se creó en la API, solo mostramos éxito
    _showSuccessDialog();

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ocurrió un error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('¡Cuenta Verificada!'),
          ],
        ),
        content: const Text(
          'Tu registro se ha completado con éxito. Ahora puedes iniciar sesión con tu correo y contraseña.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              // Borramos todo el historial de navegación y vamos al Login
              context.go('/login');
            },
            child: const Text('IR A INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Estilos para los cuadritos del PIN
    final defaultPinTheme = PinTheme(
      width: 56, height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 30, 60, 87), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: theme.primaryColor, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.mark_email_read, size: 60, color: theme.primaryColor),
                ),
              ),
              const SizedBox(height: 30),

              FadeInDown(
                child: Text('Verificación', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                child: Text(
                  'Ingresa el código enviado a:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),

              const SizedBox(height: 40),

              FadeInUp(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) => _verificarCodigo(), // Intenta verificar al terminar de escribir
                ),
              ),

              const SizedBox(height: 40),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verificarCodigo,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('VERIFICAR', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Botón de reenvío (Por ahora solo visual o simulado)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud de reenvío enviada')));
                },
                child: const Text("¿No recibiste el código? Reenviar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}