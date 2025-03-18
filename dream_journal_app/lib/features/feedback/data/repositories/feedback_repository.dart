import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/config.dart';

class FeedbackRepository {
  final String _apiURL = Config.apiURL;

  Future<void> submitFeedback(String content) async {
    try {
      final headers = await Config.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_apiURL/feedback/'),
        headers: headers,
        body: jsonEncode({
          'content': content,
          //'rating': 0, // Ignoring rating for now as requested
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
