import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/forgot_password_dto.dart';
import '../widgets/custom_text_field.dart';
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dto = ForgotPasswordDTO(correo: _emailCtrl.text);

    final service = Verificacion();
    final resultado = await service.forgotPassword(dto);

    if (mounted) setState(() => _isLoading = false);

    if (resultado != null) {
      _mostrarAlerta(
        'Éxito', 
        'Correo enviado correctamente. Revisa tu bandeja.',
        onOk: () {
          if (mounted) context.push('/reset-password');
        }
      );
    } else {
      _mostrarAlerta('Error', 'Error al enviar. Verifica el Correo electrónico.');
    }
  }

  void _mostrarAlerta(String titulo, String mensaje, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          mensaje.trim(),
          style: const TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                // FONDO SECCIONADO CON GRADIENTES RADIALES
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF090D16),
                  ),
                ),
                // Azul: Esquina Superior Izquierda
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.95, -0.95),
                        radius: 0.85,
                        colors: [
                          const Color(0xFF0284C7).withOpacity(0.40),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Amarillo / Dorado: Lado Derecho Completo
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

                // CONTENIDO
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        FadeInDown(
                          duration: const Duration(milliseconds: 800),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E293B).withOpacity(0.5),
                                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7).withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.mark_email_read_outlined,
                                  size: 40,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Recuperar contraseña',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Ingresa tu correo y te enviaremos un código para restablecer tu clave.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // TARJETA DE RECUPERACIÓN GLASSMORPHIC
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              color: const Color(0xEE0F172A),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  CustomTextField(
                                    label: 'Correo electrónico',
                                    controller: _emailCtrl,
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    fillColor: const Color(0x991E293B),
                                    textColor: Colors.white,
                                    labelColor: const Color(0xFFCBD5E1),
                                    iconColor: const Color(0xFF94A3B8),
                                    focusedBorderColor: const Color(0xFF10B981),
                                    borderColor: Colors.white.withOpacity(0.12),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'El correo es obligatorio';
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(value)) return 'Ingresa un correo válido (@ y dominio)';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _enviarSolicitud,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        elevation: 8,
                                        shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'ENVIAR CÓDIGO',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.8,
                                              ),
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