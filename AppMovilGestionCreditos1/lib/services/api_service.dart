import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:7166/api"; // tu URL

  //-------------------------------------------
  // GEThttps://localhost:7166/
  //-------------------------------------------
  Future<List<dynamic>> getData(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error GET: ${response.statusCode}");
    }
  }

  //-------------------------------------------
  // POST
  //-------------------------------------------
  Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    return {
      "status": response.statusCode,
      "body": json.decode(response.body)
    };
  }
}
