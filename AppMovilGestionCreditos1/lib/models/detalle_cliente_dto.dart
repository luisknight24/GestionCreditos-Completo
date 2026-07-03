/*
class DetalleClienteDTO {
  int id;
  String numeroCedula;
  String nombreApellidos;
  String telefono;
  String direccion;
  String? fotoClienteUrl;
  //String? fotoContrato;
  //String? fotoCelularEntregadoUrl;

  DetalleClienteDTO({
    this.id = 0,
    required this.numeroCedula,
    required this.nombreApellidos,
    required this.telefono,
    required this.direccion,
    this.fotoClienteUrl,
    //this.fotoContrato,
    //this.fotoCelularEntregadoUrl,
  });

 // ------------------- FROM JSON -------------------
  factory DetalleClienteDTO.fromJson(Map<String, dynamic> json) {
    return DetalleClienteDTO(
      id: json['Id'] ?? 0,
      numeroCedula: json['NumeroCedula'] ?? '',
      nombreApellidos: json['NombreApellidos'] ?? '',
      telefono: json['Telefono'] ?? '',
      direccion: json['Direccion'] ?? '',
      fotoClienteUrl: json['FotoClienteUrl'],
      //fotoContrato: json['FotoContrato'],
      //fotoCelularEntregadoUrl: json['FotoCelularEntregadoUrl'],
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
        'Id': id,
        'NumeroCedula': numeroCedula,
        'NombreApellidos': nombreApellidos,
        'Telefono': telefono,
        'Direccion': direccion,
        'FotoClienteUrl': fotoClienteUrl,
        //'FotoContrato': fotoContrato,
        //'FotoCelularEntregadoUrl': fotoCelularEntregadoUrl,
      };
}

 */

class DetalleClienteDTO {
  int id;
  String numeroCedula;
  String nombreApellidos;
  String telefono;
  String direccion;
  //String propietarioCredito; // <--- NUEVO CAMPO
  String? fotoClienteUrl;
  //String? fotoContrato;
  //String? fotoCelularEntregadoUrl;

  DetalleClienteDTO({
    this.id = 0,
    required this.numeroCedula,
    required this.nombreApellidos,
    required this.telefono,
    required this.direccion,
    //required this.propietarioCredito, // <--- NUEVO CAMPO
    this.fotoClienteUrl,
    //this.fotoContrato,
    //this.fotoCelularEntregadoUrl,
  });

  // ------------------- FROM JSON -------------------
  factory DetalleClienteDTO.fromJson(Map<String, dynamic> json) {
    return DetalleClienteDTO(
      id: json['Id'] ?? 0,
      numeroCedula: json['NumeroCedula'] ?? '',
      nombreApellidos: json['NombreApellidos'] ?? '',
      telefono: json['Telefono'] ?? '',
      direccion: json['Direccion'] ?? '',
      //propietarioCredito: json['PropietarioCredito'] ?? '', // <--- NUEVO CAMPO
      fotoClienteUrl: json['FotoClienteUrl'],
      //fotoContrato: json['FotoContrato'],
      //fotoCelularEntregadoUrl: json['FotoCelularEntregadoUrl'],
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
    'Id': id,
    'NumeroCedula': numeroCedula,
    'NombreApellidos': nombreApellidos,
    'Telefono': telefono,
    'Direccion': direccion,
    //'PropietarioCredito': propietarioCredito, // <--- NUEVO CAMPO
    'FotoClienteUrl': fotoClienteUrl,
    //'FotoContrato': fotoContrato,
    //'FotoCelularEntregadoUrl': fotoCelularEntregadoUrl,
  };
}