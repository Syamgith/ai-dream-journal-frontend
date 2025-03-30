import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _tokenKey = 'TOCKENKEY_JWT';
  static const String _refreshTokenKey = 'REFRESH_TOCKENKEY_JWT';
  static const String _userDataKey = 'USER_DATA_KEY';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Store JWT token
  static Future<void> setToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('Error storing token: $e');
      // Rethrow to allow caller to handle
      rethrow;
    }
  }

  // Retrieve JWT token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error retrieving token: $e');
      return null;
    }
  }

  // Delete JWT token
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('Error deleting token: $e');
      // Rethrow to allow caller to handle
      rethrow;
    }
  }

  // Store refresh token
  static Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      debugPrint('Error storing refresh token: $e');
      // Rethrow to allow caller to handle
      rethrow;
    }
  }

  // Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('Error retrieving refresh token: $e');
      return null;
    }
  }

  // Delete refresh token
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('Error deleting refresh token: $e');
      // Rethrow to allow caller to handle
      rethrow;
    }
  }

  // Store user data as JSON string
  static Future<void> setUserData(String userData) async {
    try {
      await _storage.write(key: _userDataKey, value: userData);
    } catch (e) {
      debugPrint('Error storing user data: $e');
      // Rethrow to allow caller to handle
      rethrow;
    }
  }

  // Retrieve user data
  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      debugPrint('Error retrieving user data: $e');
      return null;
    }
  }

  // Delete user data
  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      // Rethrow to allow caller to handle
      rethrow;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final refreshToken = await getRefreshToken();
      return (token != null && token.isNotEmpty) ||
          (refreshToken != null && refreshToken.isNotEmpty);
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Clear all auth data (for logout)
  static Future<void> clearAllAuthData() async {
    try {
      await deleteToken();
      await deleteRefreshToken();
      await deleteUserData();
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      rethrow;
    }
  }
}
