class MenuDTO {
  int id;
  String? nombre;
  String? icono;
  String? url;

  MenuDTO({
    this.id = 0,
    this.nombre,
    this.icono,
    this.url,
  });

  factory MenuDTO.fromJson(Map<String, dynamic> json) {
    return MenuDTO(
      id: json['id'] ?? 0,
      nombre: json['nombre'],
      icono: json['icono'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Nombre': nombre,
    'Icono': icono,
    'Url': url,
  };
}