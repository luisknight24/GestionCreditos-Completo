/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
//import 'package:url_launcher/url_launcher.dart'; // Opcional: si tienes el paquete instalado
import '../widgets/custom_text_field.dart';
import '../../models/login_dto.dart';
import '../../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;

  void _login() async {
    final loginDTO = LoginDTO(
      correo: correoController.text,
      clave: claveController.text,
    );

    // Validación antes de enviar
    if (!loginDTO.esValido()) {
      final correoError = loginDTO.validarCorreo();
      final claveError = loginDTO.validarClave();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('${correoError ?? ''}\n${claveError ?? ''}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await authService.login(loginDTO);

    setState(() => isLoading = false);

    if (success != null) {
      print('Token JWT: ${success['token']}');
      context.go('/home'); // Redirige a la pantalla principal
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Usuario o Contraseña incorrectos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  // Función auxiliar para abrir web (Maquetada)
  Future<void> _launchWeb() async {
    final Uri url = Uri.parse('https://www.google.com');
    // if (!await launchUrl(url)) { throw Exception('Could not launch $url'); }
    debugPrint("Redirigiendo a: $url");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera con fondo curvo
            Stack(
              children: [
                Container(
                  height: size.height * 0.35,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 30,
                  child: FadeInDown(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenido',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Inicia sesión para gestionar tu crédito',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),

            // Formulario login
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: correoController,
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: claveController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          '¿Olvidaste tu Contraseña?',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        child: isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text(
                          'INGRESAR',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'Regístrate',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary),
                          ),
                        ),
                      ],
                    ),

                    
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.grey.withOpacity(0.3)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Centro de Ayuda",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Opción Soporte Técnico
                        InkWell(
                          onTap: () {
                            // Lógica para llamar
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Icon(Icons.support_agent, color: theme.primaryColor, size: 28),
                                const SizedBox(height: 5),
                                const Text('Soporte Técnico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const Text('0987034477', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),

                        // Opción Página web
                        InkWell(
                          onTap: _launchWeb,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Icon(Icons.language, color: theme.colorScheme.secondary, size: 28),
                                const SizedBox(height: 5),
                                const Text('Página web', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const Text('Ir al sitio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    

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
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_text_field.dart';
import '../../models/login_dto.dart';
import '../../services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;

  void _login() async {
    final loginDTO = LoginDTO(
      correo: correoController.text,
      clave: claveController.text,
    );

    if (!loginDTO.esValido()) {
      final correoError = loginDTO.validarCorreo();
      final claveError = loginDTO.validarClave();
      _mostrarAlerta('Error de Validación', '${correoError ?? ''}\n${claveError ?? ''}');
      return;
    }

    setState(() => isLoading = true);

    final success = await authService.login(loginDTO);

    if (mounted) setState(() => isLoading = false);

    if (success != null) {
      debugPrint('Token JWT: ${success['token']}');
      if (mounted) context.go('/home');
    } else {
      if (mounted) _mostrarAlerta('Error de Acceso', 'Usuario o Contraseña incorrectos');
    }
  }

  void _mostrarAlerta(String titulo, String mensaje) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint("No se pudo abrir $url");
      }
    } catch (e) {
      debugPrint("Error al abrir enlace: $e");
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
                // 1. FONDO SECCIONADO CON GRADIENTES RADIALES (Igual al Dashboard Web)
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
                // Rojo: Lado Izquierdo (85% lateral)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.9, 0.0),
                        radius: 1.15,
                        colors: [
                          const Color(0xFFE11D48).withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Amarillo / Dorado: Lado Derecho Completo (50% espacio del lienzo)
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

                // 2. CONTENIDO DE LA PANTALLA DE LOGIN
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // CABECERA Y LOGO CIRCULAR (SIN ESPACIO BLANCO VACÍO)
                        FadeInDown(
                          duration: const Duration(milliseconds: 800),
                          child: Column(
                            children: [
                              // LOGO CIRCULAR DIRECTO SIN CONTORNO BLANCO
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFACC15).withOpacity(0.35),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Transform.scale(
                                    scale: 1.62, // El anillo del logo llena el borde del círculo directamente
                                    child: Image.asset(
                                      'assets/images/cellcompay.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              const Text(
                                'Bienvenido de nuevo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Ingresa tu cuenta para gestionar tu crédito',
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

                        const SizedBox(height: 28),

                        // TARJETA DE LOGIN GLASSMORPHIC
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
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.08),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CustomTextField(
                                  controller: correoController,
                                  label: 'Correo electrónico',
                                  icon: Icons.mail_outline,
                                  keyboardType: TextInputType.emailAddress,
                                  fillColor: const Color(0x991E293B),
                                  textColor: Colors.white,
                                  labelColor: const Color(0xFFCBD5E1),
                                  iconColor: const Color(0xFF94A3B8),
                                  focusedBorderColor: const Color(0xFF10B981),
                                  borderColor: Colors.white.withOpacity(0.12),
                                ),
                                const SizedBox(height: 18),
                                CustomTextField(
                                  controller: claveController,
                                  label: 'Contraseña',
                                  icon: Icons.lock_open_outlined,
                                  isPassword: true,
                                  fillColor: const Color(0x991E293B),
                                  textColor: Colors.white,
                                  labelColor: const Color(0xFFCBD5E1),
                                  iconColor: const Color(0xFF94A3B8),
                                  focusedBorderColor: const Color(0xFF10B981),
                                  borderColor: Colors.white.withOpacity(0.12),
                                ),
                                const SizedBox(height: 10),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push('/forgot-password'),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    child: const Text(
                                      '¿Olvidaste tu Contraseña?',
                                      style: TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'INICIAR SESIÓN',
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

                        const SizedBox(height: 22),

                        // ENLACE DE REGISTRO
                        FadeIn(
                          delay: const Duration(milliseconds: 1000),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿No tienes cuenta?',
                                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5),
                              ),
                              TextButton(
                                onPressed: () => context.push('/register'),
                                child: const Text(
                                  'Regístrate aquí',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFACC15),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // CENTRO DE AYUDA Y Soporte
                        _buildHelpSection(),

                        const SizedBox(height: 16),
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

  Widget _buildHelpSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Centro de Ayuda",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HelpButton(
              icon: Icons.language,
              label: 'Sitio Web',
              color: const Color(0xFF38BDF8),
              onTap: () => _abrirEnlace('https://www.cellcompayec.com'),
            ),
            const SizedBox(width: 32),
            _HelpButton(
              icon: FontAwesomeIcons.whatsapp,
              label: 'Soporte',
              color: const Color(0xFF10B981),
              onTap: () => _abrirEnlace('https://wa.me/593982327250'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HelpButton extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HelpButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            icon is IconData
                ? Icon(icon as IconData, color: color, size: 20)
                : FaIcon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
