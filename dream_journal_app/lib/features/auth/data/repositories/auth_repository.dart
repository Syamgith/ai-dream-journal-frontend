import 'dart:convert'; // Re-added
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
// import 'package:http/http.dart' as http; // Will be removed after refactoring confirmPasswordReset
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/auth_config.dart';
import '../../../../core/auth/auth_service.dart';
import '../../domain/models/user.dart';

class AuthRepository {
  final String _baseUrl = Config.apiURL;
  final ApiClient _apiClient;

  // Initialize Google Sign-In with platform-specific configuration
  late final GoogleSignIn _googleSignIn = _initGoogleSignIn();

  AuthRepository(this._apiClient);

  // Initialize Google Sign-In based on platform
  GoogleSignIn _initGoogleSignIn() {
    debugPrint("web client id: ");
    debugPrint(AuthConfig.webClientId);
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
    try {
      await _apiClient.post('/users/register',
          body: {
            'email': email,
            'password': password,
            'name': name,
          },
          requireAuth: false);
      return true;
    } catch (e) {
      rethrow;
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
    try {
      final data = await _apiClient.post('/users/login',
          body: {
            'email': email,
            'password': password,
          },
          requireAuth: false);

      // Save the tokens
      await AuthService.setToken(data['access_token']);
      await AuthService.setRefreshToken(data['refresh_token']);

      // Save user data locally for offline access
      final user = User.fromJson(data['user']);
      await AuthService.setUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Login as guest
  Future<User> loginAsGuest() async {
    try {
      final data = await _apiClient.post('/users/guest', requireAuth: false);
      // Save the tokens
      await AuthService.setToken(data['access_token']);
      await AuthService.setRefreshToken(data['refresh_token']);

      // Save user data locally for offline access
      final user = User.fromJson(data['user']);
      await AuthService.setUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      rethrow;
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

      debugPrint('Google User: $googleUser');
      debugPrint('Google Auth: $googleAuth');
      debugPrint('ID Token: ${googleAuth.idToken}');
      debugPrint('Access Token: ${googleAuth.accessToken}');

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
    User? currentUser;
    final localUserData = await AuthService.getUserData();
    if (localUserData != null) {
      try {
        currentUser = User.fromJson(jsonDecode(localUserData));
      } catch (e) {
        debugPrint('Error decoding local user data during logout: $e');
        // Proceed with generic logout if user data is corrupt
      }
    }

    try {
      if (currentUser != null && currentUser.isGuest) {
        // Guest user logout: call the specific backend endpoint
        await _apiClient.delete('/users/guest/logout');
        debugPrint('Guest user logout API call successful.');
      } else {
        // Regular user logout: no backend API call needed as per clarification.
        // The original code might have called POST /users/logout, which we found doesn't exist for regular users.
        // So, we'll skip any API call here for regular users.
        debugPrint('Regular user logout: No backend API call made.');
      }
    } catch (e) {
      // This catch block will now primarily handle errors from the guest logout API call.
      debugPrint(
          'Error during API part of logout (likely guest logout): $e. Proceeding with local data clearing.');
    } finally {
      await _clearLocalAuthData(); // This clears tokens, user data, and Google sign-out
    }
  }

  Future<void> _clearLocalAuthData() async {
    await AuthService.clearAllAuthData();

    // If using Google Sign-In, sign out from Google as well
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }

  static Future<String?> refreshToken() async {
    final refreshToken = await AuthService.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final uri = Uri.parse('${Config.apiURL}/users/refresh')
          .replace(queryParameters: {'refresh_token': refreshToken});

      final response = await http.post(uri, headers: {
        'Accept': 'application/json',
      });

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
        debugPrint(
            'Token refresh failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return null;
    }
  }

  // Get current user information
  Future<User?> getCurrentUser() async {
    // First, try to load from local storage for speed
    final localUserData = await AuthService.getUserData();
    if (localUserData != null) {
      try {
        return User.fromJson(jsonDecode(localUserData));
      } catch (e) {
        debugPrint('Error decoding local user data: $e');
        // Fall through to fetch from API if local data is corrupt
      }
    }

    try {
      final data = await _apiClient.get('/users/me');
      final user = User.fromJson(data);
      await AuthService.setUserData(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      debugPrint('Failed to fetch user data from API: $e');
      return null;
    }
  }

  // Convert guest user to registered user
  Future<User> convertGuestToRegisteredUser(
      String email, String password, String name) async {
    try {
      final guestToken =
          await AuthService.getToken(); // Get current guest token
      if (guestToken == null) {
        throw Exception('Guest token not found. Cannot convert user.');
      }

      final data = await _apiClient.post('/users/convert-guest', body: {
        'email': email,
        'password': password,
        'name': name,
        'token': guestToken, // Add the guest token to the body
      });

      // After successful conversion, new tokens are issued.
      // Update local storage with new tokens and user data.
      await AuthService.setToken(data['access_token']);
      await AuthService.setRefreshToken(data['refresh_token']);
      final user = User.fromJson(data['user']);
      await AuthService.setUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      // Handle specific errors or rethrow
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('/users/me');
      await _clearLocalAuthData();
    } catch (e) {
      rethrow;
    }
  }

  // Get user data
  Future<User?> getUserData() async {
    // First, try to load from local storage for speed
    final localUserData = await AuthService.getUserData();
    if (localUserData != null) {
      try {
        return User.fromJson(jsonDecode(localUserData));
      } catch (e) {
        debugPrint('Error decoding local user data: $e');
        // Fall through to fetch from API if local data is corrupt
      }
    }

    try {
      final data = await _apiClient.get('/users/me');
      final user = User.fromJson(data);
      await AuthService.setUserData(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      debugPrint('Failed to fetch user data from API: $e');
      return null;
    }
  }

  // Update user data
  Future<User?> updateUser(User user) async {
    try {
      final data = await _apiClient.put('/users/me', body: user.toJson());
      final updatedUser = User.fromJson(data);
      await AuthService.setUserData(jsonEncode(updatedUser.toJson()));
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  // Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiClient.post('/users/password-reset/',
          body: {'email': email}, requireAuth: false);
    } catch (e) {
      rethrow;
    }
  }

  // Confirm password reset
  Future<void> confirmPasswordReset(
      String token, String newPassword, String uid) async {
    try {
      await _apiClient.post('/users/password-reset/confirm/',
          body: {
            'token': token,
            'new_password': newPassword,
            'uid': uid,
          },
          requireAuth: false);
    } catch (e) {
      rethrow;
    }
  }
}
