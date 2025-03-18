import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthConfig {
  // Google Sign-In client IDs
  static String get webClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  static String get androidClientId =>
      dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ??
      'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';
  static String get iOSClientId =>
      dotenv.env['GOOGLE_IOS_CLIENT_ID'] ??
      'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
}
