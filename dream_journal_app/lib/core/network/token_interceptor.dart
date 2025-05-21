import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../auth/auth_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

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
        } else {
          // Token refresh failed
          debugPrint(
              'Token refresh failed in interceptor. Initiating force logout.');
          await _ref.read(authProvider.notifier).forceLogout();
          throw ForceLogoutInitiatedException();
        }
      } catch (e) {
        // Log the error but don't throw it to avoid disrupting the app flow
        // unless it's our specific exception
        if (e is ForceLogoutInitiatedException) {
          rethrow; // Rethrow if it's the one we just threw
        }
        debugPrint(
            'Error during token refresh in interceptor: $e. Initiating force logout.');
        await _ref.read(authProvider.notifier).forceLogout();
        throw ForceLogoutInitiatedException('Error during token refresh: $e');
      }
    }

    return response;
  }
}

// Custom exception to signal a forced logout - now public
class ForceLogoutInitiatedException implements Exception {
  final String message;
  ForceLogoutInitiatedException(
      [this.message = "Force logout initiated due to token refresh failure."]);
  @override
  String toString() => message;
}
