import 'package:http/http.dart' as http;
import '../auth/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

// A simpler implementation without using the http_interceptor package
class TokenInterceptor {
  final AuthRepository _authRepository;

  TokenInterceptor(this._authRepository);

  // Add authorization header to request
  Future<Map<String, String>> addAuthHeader(Map<String, String> headers) async {
    final token = await AuthService.getToken();

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle response and refresh token if needed
  Future<http.Response> handleResponse(http.Response response,
      Future<http.Response> Function(String) retryWithToken) async {
    // If the response is 401 Unauthorized, try to refresh the token
    if (response.statusCode == 401) {
      final newToken = await _authRepository.refreshToken();

      if (newToken != null) {
        // Retry the original request with the new token
        return await retryWithToken(newToken);
      }
    }

    return response;
  }
}
