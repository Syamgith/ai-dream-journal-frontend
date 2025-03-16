import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth/auth_service.dart';

class Config {
  static String get apiURL => dotenv.env['API_URL'] ?? 'http://localhost:8000';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Get auth headers with JWT token
  static Future<Map<String, String>> getAuthHeaders() async {
    var token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
