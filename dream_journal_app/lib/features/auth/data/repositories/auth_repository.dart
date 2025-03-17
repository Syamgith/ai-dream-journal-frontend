import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/config.dart';
import '../../../../core/auth/auth_service.dart';
import '../../domain/models/user.dart';

class AuthRepository {
  final String _baseUrl = Config.apiURL;

  // Register a new user
  Future<bool> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      //final data = jsonDecode(response.body);
      // Registration successful, but no token is returned
      // User needs to login separately
      return true;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Register and login in one step
  Future<User> registerAndLogin(
      String email, String password, String name) async {
    // First register the user
    final registerSuccess = await register(email, password, name);

    if (registerSuccess) {
      // Then login the user
      return await login(email, password);
    } else {
      throw Exception('Registration failed');
    }
  }

  // Login a user
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save the tokens
      await AuthService.setToken(data['access_token']);
      await AuthService.setRefreshToken(data['refresh_token']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Login as guest
  Future<User> loginAsGuest() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/guest'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save the tokens
      await AuthService.setToken(data['access_token']);
      await AuthService.setRefreshToken(data['refresh_token']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to login as guest: ${response.body}');
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.deleteToken();
    await AuthService.deleteRefreshToken();
  }

  // Refresh token
  Future<String?> refreshToken() async {
    final refreshToken = await AuthService.getRefreshToken();

    if (refreshToken == null) {
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['access_token'];
        await AuthService.setToken(newToken);
        return newToken;
      } else {
        // If refresh token is invalid, logout the user
        await logout();
        return null;
      }
    } catch (e) {
      await logout();
      return null;
    }
  }

  // Get current user information
  Future<User?> getCurrentUser() async {
    final token = await AuthService.getToken();

    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token is invalid, try to refresh it
        final newToken = await refreshToken();
        if (newToken != null) {
          // Try again with the new token
          return await getCurrentUser();
        } else {
          // Refresh failed, user needs to login again
          return null;
        }
      } else {
        throw Exception('Failed to get user information: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user information: $e');
    }
  }

  // Convert guest user to regular user
  Future<User> convertGuestUser(
      String name, String email, String password) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/convert-guest'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save the new tokens
        await AuthService.setToken(data['access_token']);
        await AuthService.setRefreshToken(data['refresh_token']);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to convert guest user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error converting guest user: $e');
    }
  }
}
