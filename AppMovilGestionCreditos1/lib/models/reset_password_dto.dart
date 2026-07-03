class ResetPasswordDTO {
  
  String token;
  String nuevaClave;

  ResetPasswordDTO({
    required this.token,
    required this.nuevaClave,
  });

  // Convertir a JSON para enviar al servidor
  Map<String, dynamic> toJson() => {
        'token': token,
        'nuevaClave': nuevaClave,
      };

  // Crear objeto a partir de JSON recibido del servidor
  factory ResetPasswordDTO.fromJson(Map<String, dynamic> json) {
    return ResetPasswordDTO(
      token: json['token'] ?? '',
      nuevaClave: json['nuevaClave'] ?? '',
    );
  }
}
