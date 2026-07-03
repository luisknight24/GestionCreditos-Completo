import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navegar después de 2 segundos exactos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Verifica si ya hay sesión (lógica futura) o manda al Login
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Fondo blanco para que resalte el logo (o cámbialo si tu logo es blanco)
      backgroundColor: Colors.white,
      body: Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 1500), // Efecto suave de aparición
          child: SizedBox(
            width: size.width * 0.8, // El logo ocupará el 80% del ancho de la pantalla
            child: Image.asset(
              'assets/images/cellcompay.jpg',
              fit: BoxFit.contain, // Se ajusta sin deformarse
            ),
          ),
        ),
      ),
    );
  }
}