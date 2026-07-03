class LoginDTO {
  String? correo;
  String? clave;

  // Constructor
  LoginDTO({this.correo, this.clave});

  // Crear objeto a partir de JSON (respuesta del servidor)
  factory LoginDTO.fromJson(Map<String, dynamic> json) {
    return LoginDTO(
      correo: json['correo'],
      clave: json['clave'],
    );
  }

  // Convertir objeto a JSON (para enviar al servidor)
  Map<String, dynamic> toJson() => {
        'correo': correo,
        'clave': clave,
      };

  // Validación básica de campos antes de enviar
  String? validarCorreo() {
    if (correo == null || correo!.isEmpty) {
      return 'El correo es obligatorio';
    }
    // Regex simple para validar formato de correo
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(correo!)) {
      return 'El formato del correo no es válido';
    }
    return null;
  }

  String? validarClave() {
    if (clave == null || clave!.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (clave!.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  // Validación general
  bool esValido() {
    return validarCorreo() == null && validarClave() == null;
  }
}
