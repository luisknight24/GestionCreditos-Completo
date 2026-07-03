class ForgotPasswordDTO {
  String correo;

  ForgotPasswordDTO({required this.correo});

  // Convertir a JSON para enviar al servidor
  Map<String, dynamic> toJson() => {
        'Correo': correo,
      };

  // Crear objeto a partir de JSON recibido del servidor
  factory ForgotPasswordDTO.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordDTO(
      correo: json['Correo'] ?? '',
    );
  }
}
