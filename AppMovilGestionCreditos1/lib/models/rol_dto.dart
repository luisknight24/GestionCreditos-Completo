class RolDTO {
  int id;
  String? descripcion;

  RolDTO({
    this.id = 0,
    this.descripcion,
  });

  factory RolDTO.fromJson(Map<String, dynamic> json) {
    return RolDTO(
      id: json['id'] ?? 0,
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Descripcion': descripcion,
  };
}