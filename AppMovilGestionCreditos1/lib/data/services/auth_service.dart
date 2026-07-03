import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/usuario_dto.dart';
import '../../models/verificar_dto.dart';
import '../../models/login_dto.dart';
import '../../models/forgot_password_dto.dart';
import '../../models/reset_password_dto.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  // VARIABLE DE CONTROL: Pon esto en false cuando ya tengas la API corriendo
  final bool _modoSimulacion = true;

  // 1. REGISTRO
  Future<bool> registrarUsuario(UsuarioDTO usuario) async {
    if (_modoSimulacion) {
      print("⚠️ MODO SIMULACIÓN: Registrando usuario...");
      print("JSON Enviado: ${jsonEncode(usuario.toJson())}");
      await Future.delayed(const Duration(seconds: 2)); // Simula espera de red
      return true; // Simula éxito siempre
    }

    // --- CÓDIGO REAL (Se usará cuando _modoSimulacion sea false) ---
    final url = Uri.parse('$baseUrl/Auth/Register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(usuario.toJson()),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error real: $e');
      return false;
    }
  }

  // 2. VERIFICAR OTP
  Future<bool> verificarCodigo(VerificarDTO datos) async {
    if (_modoSimulacion) {
      print("⚠️ MODO SIMULACIÓN: Verificando código OTP ${datos.codigo}...");
      await Future.delayed(const Duration(seconds: 2));
      // Simular que solo el código "123456" es válido (opcional) o aceptar todos
      return true;
    }

    final url = Uri.parse('$baseUrl/Auth/Verify');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. LOGIN
  Future<Map<String, dynamic>?> login(LoginDTO datos) async {
    if (_modoSimulacion) {
      print("⚠️ MODO SIMULACIÓN: Login...");
      await Future.delayed(const Duration(seconds: 2));
      // Retornamos un token falso y datos falsos
      return {
        'token': 'token_falso_jwt_123456',
        'usuario': {
          'NombreApellidos': 'Usuario Simulado',
          'Correo': datos.correo,
          'RolDescripcion': 'Encargado'
        }
      };
    }

    final url = Uri.parse('$baseUrl/Auth/Login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos.toJson()),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 4. OLVIDÉ MI CONTRASEÑA
  Future<bool> forgotPassword(ForgotPasswordDTO datos) async {
    if (_modoSimulacion) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }
    // ... código real ...
    return false; // Dejar implementado luego
  }

  // 5. RESTABLECER CONTRASEÑA
  Future<bool> resetPassword(ResetPasswordDTO datos) async {
    if (_modoSimulacion) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }
    // ... código real ...
    return false;
  }
}