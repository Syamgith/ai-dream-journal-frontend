import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get apiURL => dotenv.env['API_URL'] ?? 'http://localhost:8000';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}
