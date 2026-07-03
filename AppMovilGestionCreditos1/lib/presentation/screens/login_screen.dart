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
          content: const Text('Usuario o contraseña incorrectos'),
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
                      label: 'Correo Electrónico',
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
                          '¿Olvidaste tu contraseña?',
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

                    // --- SECCIÓN AGREGADA: SOPORTE Y WEB ---
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

                        // Opción Página Web
                        InkWell(
                          onTap: _launchWeb,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Icon(Icons.language, color: theme.colorScheme.secondary, size: 28),
                                const SizedBox(height: 5),
                                const Text('Página Web', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const Text('Ir al sitio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ---------------------------------------

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
import 'package:url_launcher/url_launcher.dart'; // Asegúrate de tener esto
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

  // --- LÓGICA DE NEGOCIO (Intacta) ---
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
      if (mounted) _mostrarAlerta('Error de Acceso', 'Usuario o contraseña incorrectos');
    }
  }

  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje.trim()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  // --- FUNCIONES DE SOPORTE Y WEB ---
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
    final theme = Theme.of(context);

    // Definimos colores basados en tu tema pero con variantes para el degradado
    final primaryColor = theme.primaryColor;
    final primaryDark = Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo base limpio
      body: SingleChildScrollView(
        // ConstrainedBox asegura que el contenido ocupe al menos toda la pantalla
        // para empujar el footer hacia abajo en pantallas grandes.
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                // 1. FONDO DEGRADADO CURVO (Diseño Profesional)
                Container(
                  height: size.height * 0.45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryDark, primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),

                // 2. CONTENIDO PRINCIPAL
                Column(
                  children: [
                    SizedBox(height: size.height * 0.12),

                    // Título y Bienvenida
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        children: [
                          const Icon(Icons.lock_person, size: 60, color: Colors.white),
                          const SizedBox(height: 10),
                          const Text(
                            'Bienvenido',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Gestiona tu crédito de forma segura',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // TARJETA DE LOGIN FLOTANTE
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: correoController,
                              label: 'Correo Electrónico',
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
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 5,
                                  shadowColor: theme.primaryColor.withOpacity(0.4),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                )
                                    : const Text(
                                  'INGRESAR',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // REGISTRO
                    FadeIn(
                      delay: const Duration(milliseconds: 1000),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('¿No tienes cuenta?', style: TextStyle(color: Colors.grey[600])),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: Text(
                              'Regístrate aquí',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spacer empuja el footer hacia abajo
                    const Spacer(),

                    // 3. SECCIÓN DE AYUDA (Nuevo Requerimiento)
                    _buildHelpSection(),

                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget extraído para mantener limpio el build principal
  Widget _buildHelpSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("Centro de Ayuda", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón Web
            _HelpButton(
              icon: Icons.language,
              label: 'Sitio Web',
              color: Colors.blue,
              onTap: () => _abrirEnlace('https://www.cellcompayec.com'),
            ),

            const SizedBox(width: 40), // Separación

            // Botón Soporte
            _HelpButton(
              icon: FontAwesomeIcons.whatsapp,
              label: 'Soporte',
              color: Colors.green,
              onTap: () => _abrirEnlace('https://wa.me/593982327250'),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget auxiliar para los botones de ayuda (Círculo con icono + Texto)
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
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), // Fondo suave del color del icono
                shape: BoxShape.circle,
              ),
              child: icon is IconData
                  ? Icon(icon as IconData, color: color, size: 24)
                  : FaIcon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}