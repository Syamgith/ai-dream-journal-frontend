import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/token_interceptor.dart';
import 'package:flutter/foundation.dart';

// Custom exception for rate limiting
class RateLimitExceededException implements Exception {
  final String message;
  RateLimitExceededException(this.message);

  @override
  String toString() => 'RateLimitExceededException: $message';
}

class ApiClient {
  final String baseUrl;
  final Ref _ref;
  late final TokenInterceptor _tokenInterceptor;

  // Rate limiting variables
  final List<DateTime> _requestTimestamps = [];
  static const int _maxRequests = 100;
  static const Duration _timeWindow = Duration(hours: 1);

  ApiClient({
    required this.baseUrl,
    required Ref ref,
  }) : _ref = ref {
    _tokenInterceptor = TokenInterceptor(_ref);
  }

  // Core rate-limiting logic
  void _checkAndRecordRequest() {
    final now = DateTime.now();
    // Remove old timestamps
    _requestTimestamps
        .removeWhere((timestamp) => now.difference(timestamp) > _timeWindow);

    // Check request limit
    if (_requestTimestamps.length >= _maxRequests) {
      throw RateLimitExceededException(
          'API rate limit exceeded. Please try again later.');
    }

    // Record current request timestamp
    _requestTimestamps.add(now);
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
    _checkAndRecordRequest();
    try {
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
    } on RateLimitExceededException {
      debugPrint('ApiClient: Rate limit exceeded for GET $endpoint.');
      rethrow;
    } on ForceLogoutInitiatedException {
      debugPrint('ApiClient: Request aborted due to force logout.');
      rethrow;
    }
  }

  // POST request
  Future<dynamic> post(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    _checkAndRecordRequest();
    try {
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
    } on RateLimitExceededException {
      debugPrint('ApiClient: Rate limit exceeded for POST $endpoint.');
      rethrow;
    } on ForceLogoutInitiatedException {
      debugPrint('ApiClient: Request aborted due to force logout.');
      rethrow;
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint,
      {dynamic body, bool requireAuth = true}) async {
    _checkAndRecordRequest();
    try {
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
    } on RateLimitExceededException {
      debugPrint('ApiClient: Rate limit exceeded for PUT $endpoint.');
      rethrow;
    } on ForceLogoutInitiatedException {
      debugPrint('ApiClient: Request aborted due to force logout.');
      rethrow;
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    _checkAndRecordRequest();
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await _handleResponse(
        () => http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers),
        (newToken) {
          final newHeaders = Map<String, String>.from(headers);
          newHeaders['Authorization'] = 'Bearer $newToken';
          return http.delete(Uri.parse('$baseUrl$endpoint'),
              headers: newHeaders);
        },
      );

      return _processResponse(response);
    } on RateLimitExceededException {
      debugPrint('ApiClient: Rate limit exceeded for DELETE $endpoint.');
      rethrow;
    } on ForceLogoutInitiatedException {
      debugPrint('ApiClient: Request aborted due to force logout.');
      rethrow;
    }
  }

  // Process response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } else {
      String errorMessage =
          'Request failed with status: ${response.statusCode}';
      String rawResponseBody = response.body;

      if (rawResponseBody.isNotEmpty) {
        try {
          final errorData = jsonDecode(rawResponseBody);
          if (errorData != null && errorData is Map) {
            if (errorData.containsKey('detail')) {
              final detail = errorData['detail'];
              if (detail is String) {
                errorMessage = detail;
              } else if (detail is List && detail.isNotEmpty) {
                // Handle Pydantic-style error list
                final firstError = detail[0];
                if (firstError is Map) {
                  final msg = firstError['msg'] ?? 'Invalid input';
                  final loc = firstError['loc'];
                  if (loc is List && loc.length > 1) {
                    errorMessage = 'Error in field ${loc[1]}: $msg';
                  } else {
                    errorMessage = msg.toString();
                  }
                } else {
                  errorMessage =
                      'An unexpected error occurred.'; // Fallback for unknown list format
                }
              } else if (detail != null) {
                errorMessage = detail
                    .toString(); // Fallback if detail is not string or list
              }
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            } else if (errorData.containsKey('error')) {
              errorMessage = errorData['error'];
            }
            // Potentially add more specific key checks if your backend uses other error formats
          }
        } catch (e) {
          // If JSON parsing fails, or if the structure is unexpected,
          // use the raw response body (if it's not too large or sensitive).
          errorMessage =
              'Request failed with status: ${response.statusCode}. Response: $rawResponseBody';
        }
      }
      throw Exception(errorMessage);
    }
  }
}
