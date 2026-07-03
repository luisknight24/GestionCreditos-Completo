class SesionDTO {
  int id;
  String? nombreApellidos;
  String? correo;
  String? rolDescripcion;

  SesionDTO({
    this.id = 0,
    this.nombreApellidos,
    this.correo,
    this.rolDescripcion,
  });

  factory SesionDTO.fromJson(Map<String, dynamic> json) {
    return SesionDTO(
      id: json['id'] ?? 0,
      nombreApellidos: json['nombreApellidos'],
      correo: json['correo'],
      rolDescripcion: json['rolDescripcion'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'NombreApellidos': nombreApellidos,
    'Correo': correo,
    'RolDescripcion': rolDescripcion,
  };
}