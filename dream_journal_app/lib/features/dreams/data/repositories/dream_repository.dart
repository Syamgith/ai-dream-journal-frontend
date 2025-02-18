import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dream_entry.dart';
import '../../../../core/config/config.dart';

class DreamRepository {
  final List<DreamEntry> _dreams = [];
  final String _apiURL = Config.apiURL;

  Future<List<DreamEntry>> getDreams() async {
    return _dreams;
  }

  Future<DreamEntry> addDream(DreamEntry dream) async {
    print('$_apiURL/dreams/');
    try {
      final response = await http.post(
        Uri.parse('$_apiURL/dreams/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
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
    final index = _dreams.indexWhere((d) => d.id == dream.id);
    if (index != -1) {
      _dreams[index] = dream;
    }
  }

  Future<void> deleteDream(String id) async {
    _dreams.removeWhere((dream) => dream.id == id);
  }
}
