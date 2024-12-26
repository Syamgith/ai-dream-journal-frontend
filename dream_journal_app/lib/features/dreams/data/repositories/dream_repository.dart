import '../models/dream_entry.dart';

class DreamRepository {
  final List<DreamEntry> _dreams = [];

  Future<List<DreamEntry>> getDreams() async {
    return _dreams;
  }

  Future<void> addDream(DreamEntry dream) async {
    _dreams.add(dream);
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
