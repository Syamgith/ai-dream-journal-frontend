import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../auth/auth_service.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

// A simpler implementation without using the http_interceptor package
class TokenInterceptor {
  final Ref _ref;

  TokenInterceptor(this._ref);

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
      try {
        //final authRepository = _ref.read(authRepositoryProvider);
        final newToken = await AuthRepository.refreshToken();

        if (newToken != null) {
          // Retry the original request with the new token
          return await retryWithToken(newToken);
        }
      } catch (e) {
        // Log the error but don't throw it to avoid disrupting the app flow
        debugPrint('Error during token refresh in interceptor: $e');
      }
    }

    return response;
  }
}
