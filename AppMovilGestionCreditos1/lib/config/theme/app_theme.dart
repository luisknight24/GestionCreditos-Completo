/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores Corporativos (Clean Fintech)
  static const Color primary = Color(0xFF1A237E); // Azul Profundo
  static const Color secondary = Color(0xFF00BFA5); // Verde Menta (Acción)
  static const Color background = Color(0xFFF5F5F5); // Gris suave

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primary, // Genera paleta basada en el azul
      scaffoldBackgroundColor: background,

      // Tipografía moderna
      textTheme: GoogleFonts.poppinsTextTheme(),

      // Estilo global de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // Estilo global de Inputs (Cajas de texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🔵 NUEVA PALETA DE COLORES (Estilo "Royal Blue" Fintech)

  // Azul vibrante y sólido (reemplaza al morado/indigo).
  // Similar a Colors.blue.shade800, transmite confianza y tecnología.
  static const Color primary = Color(0xFF1565C0);

  // Color de acento para resaltar (Botones secundarios, links).
  // Un Cyan o Turquesa brillante contrasta increíble con el azul oscuro.
  static const Color secondary = Color(0xFF03A9F4); // Light Blue / Cyan

  // Fondo muy limpio
  static const Color background = Color(0xFFF8F9FA);

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      // Al usar este seed con el nuevo color, Flutter generará
      // todos los tonos automáticos en la gama de AZULES, no morados.
      colorSchemeSeed: primary,
      scaffoldBackgroundColor: background,

      // Tipografía moderna
      textTheme: GoogleFonts.poppinsTextTheme(),

      // Estilo global de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bordes un poco más suaves
          elevation: 3, // Sombra suave para dar profundidad
          shadowColor: primary.withOpacity(0.4),
        ),
      ),

      // Estilo global de Inputs (Cajas de texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Más redondeado = más moderno
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.blueGrey.shade600),
        prefixIconColor: primary, // Los iconos de los inputs ahora serán azules
      ),

      // Personalización adicional para que el AppBar sea azul por defecto en toda la app
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}