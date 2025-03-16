import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth/auth_service.dart';

class Config {
  static String get apiURL => dotenv.env['API_URL'] ?? 'http://localhost:8000';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Get auth headers with JWT token
  static Future<Map<String, String>> getAuthHeaders() async {
    var token = await AuthService.getToken();
    // only for debuing. remove this token after testing
    token ??=
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDIyMTAwMzIsInN1YiI6IjQiLCJ0eXBlIjoiYWNjZXNzIn0.54zfbvNCIFeWDQJJw0noid7Ale7LHoe8zuRrQhJUc20';
    return {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
