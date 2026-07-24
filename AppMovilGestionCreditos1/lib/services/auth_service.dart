import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class AuthService {
  // URL de la API: usa HTTP y el puerto correcto
  final String baseUrl = "https://gestioncreditos-backend.onrender.com/api";
  final storage = const FlutterSecureStorage();
  Future<bool> login1(LoginDTO loginDTO) async {
    final url = Uri.parse('$baseUrl/Usuario/IniciarSesion');

    print('Intentando conectarse a la API: $url');
    print('Datos enviados: ${loginDTO.toJson()}');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(loginDTO.toJson()),
          )
          .timeout(const Duration(seconds: 5)); // timeout de 5 segundos

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Datos decodificados: $data');

        if (data['status'] == true) {
          print('Login exitoso: ${data['value']}');
          return true;
        } else {
          print('Error en login: ${data['msg']}');
          return false;
        }
      } else {
        print('Error en la conexión: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Excepción al conectarse a la API: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>?> login(LoginDTO loginDTO) async {
    final url = Uri.parse('$baseUrl/Usuario/IniciarSesion');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginDTO.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Guardar token en almacenamiento seguro
          final token = data['value']['token'];
          await storage.write(key: 'jwt_token', value: token);
           await storage.write(key: 'usuario_id', value: data['usuarioId'].toString()); 

          // Retornar datos del usuario y token
          return data['value'];
        } else {
          print('Error en login: ${data['msg']}');
          return null;
        }
      } else {
        print('Error en la conexión: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al conectarse a la API: $e');
      return null;
    }
  }

   Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }
}
