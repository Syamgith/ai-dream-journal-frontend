import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../auth/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

class ApiClient {
  final String baseUrl;
  final AuthRepository authRepository;

  ApiClient({
    required this.baseUrl,
    required this.authRepository,
  });

  // Helper method to get auth headers
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await AuthService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle response and token refresh if needed
  Future<http.Response> _handleResponse(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();

      // If unauthorized, try to refresh token and retry
      if (response.statusCode == 401) {
        final newToken = await authRepository.refreshToken();

        if (newToken != null) {
          // Retry the request with the new token
          return await request();
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // GET request
  Future<dynamic> get(String endpoint, {bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);

    final response = await _handleResponse(
        () => http.get(Uri.parse('$baseUrl$endpoint'), headers: headers));

    return _processResponse(response);
  }

  // POST request
  Future<dynamic> post(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);

    final response = await _handleResponse(() => http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        ));

    return _processResponse(response);
  }

  // PUT request
  Future<dynamic> put(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);

    final response = await _handleResponse(() => http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        ));

    return _processResponse(response);
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);

    final response = await _handleResponse(
        () => http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers));

    return _processResponse(response);
  }

  // Process response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Request failed with status: ${response.statusCode}. ${response.body}');
    }
  }
}
