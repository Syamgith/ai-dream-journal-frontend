import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_entry.dart';
import '../data/repositories/dream_repository.dart';

final dreamRepositoryProvider = Provider((ref) => DreamRepository());

final dreamsProvider =
    StateNotifierProvider<DreamsNotifier, List<DreamEntry>>((ref) {
  final repository = ref.watch(dreamRepositoryProvider);
  return DreamsNotifier(repository);
});

class DreamsNotifier extends StateNotifier<List<DreamEntry>> {
  final DreamRepository _repository;

  DreamsNotifier(this._repository) : super([]) {
    loadDreams();
  }

  Future<void> loadDreams() async {
    state = await _repository.getDreams();
  }

  Future<DreamEntry> addDream(DreamEntry dream) async {
    final interpretedDream = await _repository.addDream(dream);
    state = state.contains(interpretedDream)
        ? [...state]
        : [...state, interpretedDream];
    return interpretedDream;
  }

  Future<void> updateDream(DreamEntry dream) async {
    await _repository.updateDream(dream);
    state = [
      for (final item in state)
        if (item.id == dream.id) dream else item
    ];
  }

  Future<void> deleteDream(int? id) async {
    await _repository.deleteDream(id);
    state = state.where((dream) => dream.id != id).toList();
  }
}
