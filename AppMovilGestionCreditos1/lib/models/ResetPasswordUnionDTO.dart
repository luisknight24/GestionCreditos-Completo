class ResetPasswordUnionDTO {
  
  String correo;
  String codigo;
  String nuevaClave;


  ResetPasswordUnionDTO({

    required this.correo,
    required this.codigo,
    required this.nuevaClave,

  });

  // Convertir a JSON para enviar al servidor
  Map<String, dynamic> toJson() => {
  
        'correo': correo,
        'codigo': codigo,
        'nuevaClave': nuevaClave

      };

  // Crear objeto a partir de JSON recibido del servidor
  factory ResetPasswordUnionDTO.fromJson(Map<String, dynamic> json) {
    return ResetPasswordUnionDTO(
  
      correo: json['correo'] ?? '',
      codigo: json['codigo'] ?? '',
      nuevaClave: json['nuevaClave'] ?? ''
    
    );
  }
}
