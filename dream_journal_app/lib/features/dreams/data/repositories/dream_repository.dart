import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dream_entry.dart';
import '../../../../core/network/api_client.dart';

class DreamRepository {
  final ApiClient _apiClient;

  // In-memory cache of dreams
  final List<DreamEntry> _dreams = [];
  DateTime? _lastFetchTime;

  DreamRepository(this._apiClient);

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
      final dynamic responseData = await _apiClient.get('/dreams/');

      final List<dynamic> dreamsJson = responseData;
      final dreams =
          dreamsJson.map((json) => DreamEntry.fromJson(json)).toList();
      _dreams.clear();
      _dreams.addAll(dreams);
      _lastFetchTime = now;
      return dreams;
    } catch (e) {
      // If there's an error but we have cached dreams, return those
      if (_dreams.isNotEmpty) {
        return _dreams;
      }
      rethrow;
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
      final dynamic responseData = await _apiClient.get('/dreams/$id/');

      final dreamJson = responseData;
      final dream = DreamEntry.fromJson(dreamJson);

      // Update the dream in the cache
      final index = _dreams.indexWhere((d) => d.id == id);
      if (index != -1) {
        _dreams[index] = dream;
      } else {
        _dreams.add(dream);
      }

      return dream;
    } catch (e) {
      rethrow;
    }
  }

  Future<DreamEntry> addDream(DreamEntry dream) async {
    try {
      final dynamic responseData = await _apiClient.post(
        '/dreams/',
        body: dream.toJson(),
      );

      final interpretedDream = DreamEntry.fromJson(responseData);

      // Add to cache if not already present
      if (!_dreams.any((d) => d.id == interpretedDream.id)) {
        _dreams.add(interpretedDream);
      }

      return interpretedDream;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDream(DreamEntry dream) async {
    try {
      await _apiClient.put(
        '/dreams/${dream.id}/',
        body: dream.toJson(),
      );

      // Update in cache
      final index = _dreams.indexWhere((d) => d.id == dream.id);
      if (index != -1) {
        _dreams[index] = dream;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDream(int? id) async {
    if (id == null) return;

    try {
      await _apiClient.delete('/dreams/$id/');

      // Remove from cache
      _dreams.removeWhere((dream) => dream.id == id);
    } catch (e) {
      rethrow;
    }
  }

  // Report a dream for inappropriate content
  Future<void> reportDream(int dreamId, {String? reason}) async {
    try {
      await _apiClient.post(
        '/dreams/$dreamId/report',
        body: reason != null ? {'reason': reason} : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}
