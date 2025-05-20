// import 'dart:convert'; // Removed
// import 'package:http/http.dart' as http; // To be removed
// import '../../../../core/config/config.dart'; // To be removed
import '../../../../core/network/api_client.dart'; // Added

class FeedbackRepository {
  // final String _apiURL = Config.apiURL; // Removed
  final ApiClient _apiClient; // Added

  FeedbackRepository(this._apiClient); // Added constructor

  Future<void> submitFeedback(String content) async {
    try {
      await _apiClient.post('/feedback/', body: {'content': content});
    } catch (e) {
      rethrow;
    }
  }
}
