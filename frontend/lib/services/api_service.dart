import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://172.24.219.246:8000";

  static Future<Map<String, dynamic>> predictDisease(
      List<String> symptoms, String city) async {
    final url = Uri.parse("$baseUrl/predict");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "symptoms": symptoms,
        "city": city,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // Contains disease, confidence, severity, specialist, care_tips, nearby_hospitals
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }
}

