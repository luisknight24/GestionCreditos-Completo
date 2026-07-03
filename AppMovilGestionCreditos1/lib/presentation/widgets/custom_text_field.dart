/*
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly; // <--- NUEVO CAMPO

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.controller,
    this.readOnly = false, // <--- Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly, // <--- Conectamos la propiedad
      style: TextStyle(
        fontSize: 15,
        color: readOnly ? Colors.grey[700] : null, // Visualmente indicamos que está bloqueado
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: readOnly ? Colors.grey : colors.primary)
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        filled: readOnly, // Fondo gris si es solo lectura
        fillColor: readOnly ? Colors.grey[200] : null,
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly; // Nueva propiedad para bloquear edición
  final String? suffixText;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false, // Por defecto es editable
    this.suffixText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Variable interna para controlar si se ve o no el texto
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly, // Aplicamos la propiedad
      validator: widget.validator,
      style: TextStyle(
        color: widget.readOnly ? Colors.grey[700] : Colors.black, // Texto gris si es solo lectura
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: widget.readOnly ? Colors.grey[100] : Colors.grey[50], // Fondo gris claro si es readOnly

        // 🟢 Lógica del botón para ver contraseña
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,

        suffixText: widget.suffixText, // ✅ Mostrar GB aquí
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}