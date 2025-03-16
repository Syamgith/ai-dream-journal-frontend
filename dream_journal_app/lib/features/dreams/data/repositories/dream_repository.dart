import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dream_entry.dart';
import '../../../../core/config/config.dart';

class DreamRepository {
  final List<DreamEntry> _dreams = [];
  final String _apiURL = Config.apiURL;

  Future<List<DreamEntry>> getDreams() async {
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
        return dreams;
      } else {
        throw Exception('Failed to load dreams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<DreamEntry> addDream(DreamEntry dream) async {
    print('$_apiURL/dreams/');
    try {
      final headers = await Config.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_apiURL/dreams/'),
        headers: headers,
        body: jsonEncode(dream.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final interpretedDream = DreamEntry.fromJson(jsonDecode(response.body));
        _dreams.add(interpretedDream);
        return interpretedDream;
      } else {
        print(response.statusCode);
        throw Exception('Failed to get dream interpretation');
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

      if (response.statusCode == 204) {
        _dreams.removeWhere((dream) => dream.id == id);
      } else {
        throw Exception('Failed to delete dream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
