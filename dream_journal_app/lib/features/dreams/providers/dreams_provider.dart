import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_entry.dart';

final dreamsProvider =
    StateNotifierProvider<DreamsNotifier, List<DreamEntry>>((ref) {
  return DreamsNotifier();
});

class DreamsNotifier extends StateNotifier<List<DreamEntry>> {
  DreamsNotifier() : super([]);

  void addDream(DreamEntry dream) {
    state = [...state, dream];
  }

  void removeDream(String id) {
    state = state.where((dream) => dream.id != id).toList();
  }

  void updateDream(DreamEntry updatedDream) {
    state = state
        .map((dream) => dream.id == updatedDream.id ? updatedDream : dream)
        .toList();
  }
}
