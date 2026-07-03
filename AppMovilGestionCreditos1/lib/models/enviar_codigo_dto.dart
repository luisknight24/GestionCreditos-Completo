class EnviarCodigoDTO {
  String correo;

  EnviarCodigoDTO({required this.correo});

  Map<String, dynamic> toJson() => {
    'Correo': correo,
  };
}