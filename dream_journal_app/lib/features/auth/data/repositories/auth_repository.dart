import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/config.dart';
import '../../../../core/auth/auth_service.dart';
import '../../domain/models/user.dart';

class AuthRepository {
  final String _baseUrl = Config.apiURL;

  // Register a new user
  Future<User> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Save the token
      await AuthService.setToken(data['access_token']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Login a user
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save the token
      await AuthService.setToken(data['access_token']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Login as guest
  Future<User> loginAsGuest() async {
    // Create a guest user
    final user = User.guest();
    // No token is saved for guest users
    return user;
  }

  // Logout
  Future<void> logout() async {
    await AuthService.deleteToken();
  }
}
