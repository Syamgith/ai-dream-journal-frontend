import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _tokenKey = 'TOCKENKEY_JWT';
  static const String _refreshTokenKey = 'REFRESH_TOCKENKEY_JWT';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Store JWT token
  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Retrieve JWT token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete JWT token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Store refresh token
  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Delete refresh token
  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
