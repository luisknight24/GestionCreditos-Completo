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

    //  Código correcto: el usuario ya se creó en la API, solo mostramos éxito
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

  Future<void> _reenviarCodigo() async {
    setState(() => _isLoading = true);
    try {
      final usuarioFinal = context.read<RegisterProvider>().getUsuarioFinal();
      final validarCuenta = ValidarCuenta();
      final enviado = await validarCuenta.enviarCodigoCompleto(usuarioFinal);

      if (mounted) {
        if (enviado == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nuevo código de verificación enviado al correo.'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo reenviar el código. Inténtalo de nuevo.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'Tu registro se ha completado con éxito. Ahora puedes iniciar sesión con tu correo y Contraseña.',
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
    final size = MediaQuery.of(context).size;

    // Estilos para los cuadritos del PIN
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 58,
      textStyle: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: const Color(0x991E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF10B981), width: 2),
      borderRadius: BorderRadius.circular(14),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                // FONDO SECCIONADO CON GRADIENTES RADIALES
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
                        const SizedBox(height: 20),

                        Center(
                          child: Column(
                            children: [
                              FadeInDown(
                                child: Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: const Color(0xEE0F172A),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.2),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.mark_email_read_rounded, size: 55, color: Color(0xFF10B981)),
                                ),
                              ),
                              const SizedBox(height: 24),

                              FadeInDown(
                                delay: const Duration(milliseconds: 200),
                                child: const Text(
                                  'Verificación de código',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FadeInDown(
                                delay: const Duration(milliseconds: 300),
                                child: Text(
                                  'Ingresa el código enviado a:\n${widget.email}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        FadeInUp(
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
                            child: Column(
                              children: [
                                Pinput(
                                  length: 6,
                                  controller: _pinController,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                  showCursor: true,
                                  onCompleted: (pin) => _verificarCodigo(),
                                ),
                                const SizedBox(height: 30),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _verificarCodigo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      elevation: 6,
                                      shadowColor: const Color(0xFF10B981).withOpacity(0.35),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'VERIFICAR Y ACTIVAR',
                                                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.check_circle_outline_rounded, size: 20),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TextButton(
                                  onPressed: _isLoading ? null : _reenviarCodigo,
                                  child: const Text(
                                    "¿No recibiste el código? Reenviar",
                                    style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 13.5),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}