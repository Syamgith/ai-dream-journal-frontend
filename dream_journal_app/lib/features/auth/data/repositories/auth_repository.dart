import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/config/config.dart';
import '../../../../core/config/auth_config.dart';
import '../../../../core/auth/auth_service.dart';
import '../../domain/models/user.dart';

class AuthRepository {
  final String _baseUrl = Config.apiURL;

  // Initialize Google Sign-In with platform-specific configuration
  late final GoogleSignIn _googleSignIn = _initGoogleSignIn();

  // Initialize Google Sign-In based on platform
  GoogleSignIn _initGoogleSignIn() {
    print("web client id: ");
    print(AuthConfig.webClientId);
    if (kIsWeb) {
      // Web platform
      return GoogleSignIn(
        scopes: ['openid', 'email', 'profile'],
        clientId: AuthConfig.webClientId,
      );
    } else if (Platform.isAndroid) {
      // Android platform
      return GoogleSignIn(
        scopes: ['openid', 'email', 'profile'],
        // Android doesn't need clientId here as it's configured via OAuth in Google Cloud Console
        // and uses the SHA-1 certificate fingerprint
      );
    } else if (Platform.isIOS) {
      // iOS platform
      return GoogleSignIn(
        scopes: ['openid', 'email', 'profile'],
        clientId: AuthConfig.iOSClientId,
      );
    } else {
      // Default case
      return GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
  }

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
      return true;
    } else {
      // Try to extract a more user-friendly error message
      String errorMessage = 'Failed to register';

      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData is Map) {
            if (errorData.containsKey('detail')) {
              errorMessage = 'Registration failed: ${errorData['detail']}';
            }
          }
        } catch (e) {
          // If JSON parsing fails, use generic message
          errorMessage = 'Registration failed. Please try again.';
        }
      }

      throw Exception(errorMessage);
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
      // Try to extract a more user-friendly error message
      String errorMessage = 'Failed to login';

      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData is Map) {
            if (errorData.containsKey('detail')) {
              errorMessage = 'Login failed: ${errorData['detail']}';
            }
          }
        } catch (e) {
          // If JSON parsing fails, use generic message
          errorMessage = 'Login failed. Please check your credentials.';
        }
      }

      throw Exception(errorMessage);
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
      // Try to extract a more user-friendly error message
      String errorMessage = 'Failed to login as guest';

      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData is Map) {
            if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'];
            }
          }
        } catch (e) {
          // If JSON parsing fails, use generic message
          errorMessage = 'Guest login failed. Please try again later.';
        }
      }

      throw Exception(errorMessage);
    }
  }

  // Login with Google
  Future<User> loginWithGoogle() async {
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        throw Exception('Google sign-in was canceled');
      }

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Google User: $googleUser');
      print('Google Auth: $googleAuth');
      print('ID Token: ${googleAuth.idToken}');
      print('Access Token: ${googleAuth.accessToken}');

      // Use idToken if available, otherwise fall back to accessToken
      final tokenToUse = googleAuth.idToken ?? googleAuth.accessToken;

      if (tokenToUse == null) {
        throw Exception('Failed to obtain authentication token from Google');
      }

      // Determine which type of token we're sending
      final tokenType =
          googleAuth.idToken != null ? 'id_token' : 'access_token';

      // Send the token to your backend
      final response = await http.post(
        Uri.parse('$_baseUrl/users/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': tokenToUse,
          'token_type': tokenType,
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
        // Try to extract a more user-friendly error message
        String errorMessage = 'Failed to login with Google';

        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData != null && errorData is Map) {
              if (errorData.containsKey('detail')) {
                errorMessage = errorData['detail'];
              }
            }
          } catch (e) {
            // If JSON parsing fails, use generic message
            errorMessage = 'Google login failed. Please try again later.';
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      // Ensure sign out from Google when there's an error
      await _googleSignIn.signOut();
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error during Google sign-in. Please try again.');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Check if current user is a guest user
      final userData = await AuthService.getUserData();
      if (userData != null) {
        try {
          final user = User.fromJson(jsonDecode(userData));
          if (user.isGuest) {
            // If the user is a guest, use the guest logout method
            await logoutGuestUser();
            return;
          }
        } catch (e) {
          print('Error parsing user data during logout: $e');
          // Continue with regular logout
        }
      }

      // Sign out from Google if the user signed in with Google
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
      // Continue with logout even if Google sign-out fails
    }

    await AuthService.clearAllAuthData();
  }

  // Logout a guest user (also deletes the user from backend)
  Future<void> logoutGuestUser() async {
    try {
      final token = await AuthService.getToken();

      if (token != null) {
        // Make DELETE request to delete the guest user
        try {
          final response = await http.delete(
            Uri.parse('$_baseUrl/users/guest/logout'),
            headers: {'Authorization': 'Bearer $token'},
          );

          // Log response for debugging
          print('Guest user logout response: ${response.statusCode}');

          if (response.statusCode != 200 && response.statusCode != 204) {
            print('Failed to delete guest user: ${response.body}');
          }
          await AuthService.clearAllAuthData();
        } catch (e) {
          print('Error calling guest logout API: $e');
          // Continue with regular logout even if the API call fails
        }
      }

      // Try signing out from Google (just in case)
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Error signing out from Google: $e');
      }

      // Clear local auth data
      await AuthService.clearAllAuthData();
    } catch (e) {
      print('Error during guest user logout: $e');
      // Still clear auth data even if there was an error
      await AuthService.clearAllAuthData();
    }
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
