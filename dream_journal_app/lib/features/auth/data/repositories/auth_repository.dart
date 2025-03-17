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

      // Save user data locally for offline access
      final user = User.fromJson(data['user']);
      await AuthService.setUserData(jsonEncode(user.toJson()));

      return user;
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

      // Save user data locally for offline access
      final user = User.fromJson(data['user']);
      await AuthService.setUserData(jsonEncode(user.toJson()));

      return user;
    } else {
      throw Exception('Failed to login as guest: ${response.body}');
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.clearAllAuthData();
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
        // If the response also contains a new refresh token, save it
        if (data.containsKey('refresh_token')) {
          await AuthService.setRefreshToken(data['refresh_token']);
        }
        return newToken;
      } else {
        // Don't automatically logout on refresh failure
        // Just return null to indicate refresh failed
        print('Token refresh failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Don't automatically logout on refresh failure
      // Just return null to indicate refresh failed
      print('Error refreshing token: $e');
      return null;
    }
  }

  // Get current user information
  Future<User?> getCurrentUser() async {
    final token = await AuthService.getToken();

    if (token == null) {
      // Try to get user from local storage if token is not available
      final userData = await AuthService.getUserData();
      if (userData != null) {
        try {
          return User.fromJson(jsonDecode(userData));
        } catch (e) {
          print('Error parsing stored user data: $e');
          return null;
        }
      }
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
        final user = User.fromJson(data);

        // Update stored user data
        await AuthService.setUserData(jsonEncode(user.toJson()));

        return user;
      } else if (response.statusCode == 401) {
        // Token is invalid, try to refresh it
        final newToken = await refreshToken();
        if (newToken != null) {
          // Try again with the new token
          return await getCurrentUser();
        } else {
          // Refresh failed, but don't force logout
          // Try to get user from local storage
          final userData = await AuthService.getUserData();
          if (userData != null) {
            try {
              return User.fromJson(jsonDecode(userData));
            } catch (e) {
              print('Error parsing stored user data: $e');
              return null;
            }
          }
          return null;
        }
      } else {
        // Try to get user from local storage if API call fails
        final userData = await AuthService.getUserData();
        if (userData != null) {
          try {
            return User.fromJson(jsonDecode(userData));
          } catch (e) {
            print('Error parsing stored user data: $e');
            throw Exception('Failed to get user information: ${response.body}');
          }
        }
        throw Exception('Failed to get user information: ${response.body}');
      }
    } catch (e) {
      // Try to get user from local storage if API call fails
      final userData = await AuthService.getUserData();
      if (userData != null) {
        try {
          return User.fromJson(jsonDecode(userData));
        } catch (e2) {
          print('Error parsing stored user data: $e2');
          throw Exception('Error getting user information: $e');
        }
      }
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

        // Save user data locally for offline access
        final user = User.fromJson(data['user']);
        await AuthService.setUserData(jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception('Failed to convert guest user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error converting guest user: $e');
    }
  }
}
