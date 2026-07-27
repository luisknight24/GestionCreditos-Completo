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
  final bool readOnly;
  final String? suffixText;
  final Color? fillColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? iconColor;
  final Color? focusedBorderColor;
  final Color? borderColor;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.suffixText,
    this.fillColor,
    this.textColor,
    this.labelColor,
    this.iconColor,
    this.focusedBorderColor,
    this.borderColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = widget.textColor ?? (widget.readOnly ? Colors.grey[700]! : Colors.black);
    final effectiveFillColor = widget.fillColor ?? (widget.readOnly ? Colors.grey[100]! : Colors.grey[50]!);
    final effectiveLabelColor = widget.labelColor ?? Colors.grey[700];
    final effectiveIconColor = widget.iconColor ?? Theme.of(context).primaryColor;
    final effectiveBorderColor = widget.borderColor ?? Colors.grey[300]!;
    final effectiveFocusedBorderColor = widget.focusedBorderColor ?? Theme.of(context).primaryColor;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      validator: widget.validator,
      style: TextStyle(
        color: effectiveTextColor,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: effectiveLabelColor),
        prefixIcon: widget.icon != null ? Icon(widget.icon, color: effectiveIconColor) : null,
        filled: true,
        fillColor: effectiveFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: effectiveBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: effectiveBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 1.8),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: widget.iconColor ?? Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        suffixText: widget.suffixText,
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}