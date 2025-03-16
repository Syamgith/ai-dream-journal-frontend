import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _tokenKey = 'TOCKENKEY_PLACEHOLDER';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Store JWT token
  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Retrieve JWT token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete JWT token (for logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
