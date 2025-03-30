import 'dart:convert';
import 'package:flutter/foundation.dart';

class ErrorFormatter {
  /// Formats error messages from various sources to be user-friendly
  static String format(Object error) {
    final errorStr = error.toString();

    // Check if the error message contains a JSON string
    if (errorStr.contains('{"detail":')) {
      try {
        // Extract JSON from the error message
        final jsonStart = errorStr.indexOf('{');
        final jsonEnd = errorStr.lastIndexOf('}') + 1;

        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = errorStr.substring(jsonStart, jsonEnd);
          final errorData = jsonDecode(jsonStr);

          // Format the detail field
          if (errorData.containsKey('detail')) {
            return _formatDetailMessage(errorData['detail']);
          }
        }
      } catch (e) {
        // If JSON parsing fails, fall back to standard message
        debugPrint('Error parsing JSON from error message: $e');
      }
    }

    // Handle authentication-specific error messages
    if (errorStr.contains('Failed to login:') ||
        errorStr.contains('Failed to register:') ||
        errorStr.contains('Invalid username or password') ||
        errorStr.contains('Invalid credentials')) {
      return 'Invalid username or password. Please try again.';
    }

    if (errorStr.contains('Failed to refresh token')) {
      return 'Your session has expired. Please sign in again.';
    }

    // Handle connection errors
    if (errorStr.contains('Failed to connect to the server')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    // Strip out 'Exception:' prefix for cleaner messages
    if (errorStr.startsWith('Exception:')) {
      final cleanedError = errorStr.substring('Exception:'.length).trim();

      // Return clean error if it doesn't look like JSON
      if (!cleanedError.contains('{') && !cleanedError.contains('}')) {
        return cleanedError;
      }
    }

    // Default fallback message
    return 'Something went wrong. Please try again later.';
  }

  /// Format authentication detail messages specifically
  static String _formatDetailMessage(String detail) {
    if (detail.contains('Invalid username or password')) {
      return 'Invalid username or password. Please try again.';
    }

    if (detail.toLowerCase().contains('password')) {
      return 'Password error: $detail';
    }

    if (detail.toLowerCase().contains('email')) {
      return 'Email error: $detail';
    }

    // Return the detail as is if it seems user-friendly already
    if (!detail.contains('{') && !detail.contains('}') && detail.length < 100) {
      return detail;
    }

    return 'Authentication error. Please try again.';
  }
}
