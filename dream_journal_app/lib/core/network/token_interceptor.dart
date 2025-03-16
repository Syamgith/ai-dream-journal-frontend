import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import '../auth/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

class TokenInterceptor implements InterceptorContract {
  final AuthRepository _authRepository;

  TokenInterceptor(this._authRepository);

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    final token = await AuthService.getToken();

    if (token != null) {
      data.headers['Authorization'] = 'Bearer $token';
    }

    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    // If the response is 401 Unauthorized, try to refresh the token
    if (data.statusCode == 401) {
      final newToken = await _authRepository.refreshToken();

      if (newToken != null) {
        // Retry the original request with the new token
        final request = data.request;
        final headers = Map<String, String>.from(request.headers);
        headers['Authorization'] = 'Bearer $newToken';

        final retryResponse = await http.Client().send(
          http.Request(request.method, request.url)
            ..headers.addAll(headers)
            ..body = request.body,
        );

        return ResponseData.fromHttpResponse(
          await http.Response.fromStream(retryResponse),
          request: request,
        );
      }
    }

    return data;
  }
}
