import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../auth/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import 'token_interceptor.dart';

class ApiClient {
  final String baseUrl;
  final AuthRepository authRepository;
  late final TokenInterceptor _tokenInterceptor;

  ApiClient({
    required this.baseUrl,
    required this.authRepository,
  }) {
    _tokenInterceptor = TokenInterceptor(authRepository);
  }

  // Helper method to get auth headers
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      return await _tokenInterceptor.addAuthHeader(headers);
    }

    return headers;
  }

  // Handle response and token refresh if needed
  Future<http.Response> _handleResponse(
      Future<http.Response> Function() request,
      Future<http.Response> Function(String) retryWithToken) async {
    try {
      final response = await request();
      return await _tokenInterceptor.handleResponse(response, retryWithToken);
    } catch (e) {
      rethrow;
    }
  }

  // GET request
  Future<dynamic> get(String endpoint, {bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);

    final response = await _handleResponse(
      () => http.get(Uri.parse('$baseUrl$endpoint'), headers: headers),
      (newToken) {
        final newHeaders = Map<String, String>.from(headers);
        newHeaders['Authorization'] = 'Bearer $newToken';
        return http.get(Uri.parse('$baseUrl$endpoint'), headers: newHeaders);
      },
    );

    return _processResponse(response);
  }

  // POST request
  Future<dynamic> post(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    final encodedBody = jsonEncode(body);

    final response = await _handleResponse(
      () => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: encodedBody,
      ),
      (newToken) {
        final newHeaders = Map<String, String>.from(headers);
        newHeaders['Authorization'] = 'Bearer $newToken';
        return http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: newHeaders,
          body: encodedBody,
        );
      },
    );

    return _processResponse(response);
  }

  // PUT request
  Future<dynamic> put(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    final encodedBody = jsonEncode(body);

    final response = await _handleResponse(
      () => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: encodedBody,
      ),
      (newToken) {
        final newHeaders = Map<String, String>.from(headers);
        newHeaders['Authorization'] = 'Bearer $newToken';
        return http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: newHeaders,
          body: encodedBody,
        );
      },
    );

    return _processResponse(response);
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);

    final response = await _handleResponse(
      () => http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers),
      (newToken) {
        final newHeaders = Map<String, String>.from(headers);
        newHeaders['Authorization'] = 'Bearer $newToken';
        return http.delete(Uri.parse('$baseUrl$endpoint'), headers: newHeaders);
      },
    );

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
      // Try to extract a more user-friendly error message
      String errorMessage =
          'Request failed with status: ${response.statusCode}';

      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData is Map) {
            if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'];
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            } else if (errorData.containsKey('error')) {
              errorMessage = errorData['error'];
            }
          }
        } catch (e) {
          // If JSON parsing fails, use the response body as is
          errorMessage =
              'Request failed with status: ${response.statusCode}. ${response.body}';
        }
      }

      throw Exception(errorMessage);
    }
  }
}
