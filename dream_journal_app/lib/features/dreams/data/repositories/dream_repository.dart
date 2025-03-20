import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dream_entry.dart';
import '../../../../core/config/config.dart';

class DreamRepository {
  // In-memory cache of dreams
  final List<DreamEntry> _dreams = [];
  final String _apiURL = Config.apiURL;
  DateTime? _lastFetchTime;

  // Clear the dreams cache
  void clearCache() {
    _dreams.clear();
    _lastFetchTime = null;
  }

  // Get dreams from cache if available and recent, otherwise fetch from API
  Future<List<DreamEntry>> getDreams({bool forceRefresh = false}) async {
    // If we have dreams in cache and it's been less than 5 minutes since last fetch
    // and we're not forcing a refresh, return the cached dreams
    final now = DateTime.now();
    if (!forceRefresh &&
        _dreams.isNotEmpty &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMinutes < 5) {
      return _dreams;
    }

    try {
      final headers = await Config.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_apiURL/dreams/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> dreamsJson = jsonDecode(response.body);
        final dreams =
            dreamsJson.map((json) => DreamEntry.fromJson(json)).toList();
        _dreams.clear();
        _dreams.addAll(dreams);
        _lastFetchTime = now;
        return dreams;
      } else {
        // If API call fails but we have cached dreams, return those
        if (_dreams.isNotEmpty) {
          return _dreams;
        }
        throw Exception('Failed to load dreams: ${response.statusCode}');
      }
    } catch (e) {
      // If there's an error but we have cached dreams, return those
      if (_dreams.isNotEmpty) {
        return _dreams;
      }
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get a single dream by ID, first checking cache
  Future<DreamEntry?> getDreamById(int id) async {
    // First check if the dream is in the cache
    final cachedDream = _dreams.firstWhere(
      (dream) => dream.id == id,
      orElse: () => DreamEntry(
        id: -1,
        description: '',
        timestamp: DateTime.now(),
      ),
    );

    if (cachedDream.id != -1) {
      return cachedDream;
    }

    // If not in cache, fetch from API
    try {
      final headers = await Config.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_apiURL/dreams/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dreamJson = jsonDecode(response.body);
        final dream = DreamEntry.fromJson(dreamJson);

        // Update the dream in the cache
        final index = _dreams.indexWhere((d) => d.id == id);
        if (index != -1) {
          _dreams[index] = dream;
        } else {
          _dreams.add(dream);
        }

        return dream;
      } else {
        throw Exception('Failed to load dream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<DreamEntry> addDream(DreamEntry dream) async {
    try {
      final headers = await Config.getAuthHeaders();

      final response = await http.post(
        Uri.parse('$_apiURL/dreams/'),
        headers: headers,
        body: jsonEncode(dream.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final interpretedDream = DreamEntry.fromJson(jsonDecode(response.body));

        // Add to cache if not already present
        if (!_dreams.any((d) => d.id == interpretedDream.id)) {
          _dreams.add(interpretedDream);
        }

        return interpretedDream;
      } else {
        throw Exception(
            'Failed to get dream interpretation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<void> updateDream(DreamEntry dream) async {
    try {
      final headers = await Config.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_apiURL/dreams/${dream.id}/'),
        headers: headers,
        body: jsonEncode(dream.toJson()),
      );

      if (response.statusCode == 200) {
        // Update in cache
        final index = _dreams.indexWhere((d) => d.id == dream.id);
        if (index != -1) {
          _dreams[index] = dream;
        }
      } else {
        throw Exception('Failed to update dream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<void> deleteDream(int? id) async {
    if (id == null) return;

    try {
      final headers = await Config.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_apiURL/dreams/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Remove from cache
        _dreams.removeWhere((dream) => dream.id == id);
      } else {
        throw Exception('Failed to delete dream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
