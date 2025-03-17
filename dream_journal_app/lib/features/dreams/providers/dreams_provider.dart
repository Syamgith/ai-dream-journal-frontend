import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_entry.dart';
import '../data/repositories/dream_repository.dart';

final dreamRepositoryProvider = Provider((ref) => DreamRepository());

// Provider to track loading state for dreams
final dreamsLoadingProvider = StateProvider<bool>((ref) => false);

final dreamsProvider =
    StateNotifierProvider<DreamsNotifier, List<DreamEntry>>((ref) {
  final repository = ref.watch(dreamRepositoryProvider);
  return DreamsNotifier(repository, ref);
});

class DreamsNotifier extends StateNotifier<List<DreamEntry>> {
  final DreamRepository _repository;
  final Ref _ref;

  DreamsNotifier(this._repository, this._ref) : super([]) {
    loadDreams();
  }

  Future<void> loadDreams() async {
    try {
      // Set loading state to true
      _ref.read(dreamsLoadingProvider.notifier).state = true;

      // Fetch dreams from the repository
      final dreams = await _repository.getDreams();

      // Update the state with the fetched dreams
      state = dreams;
    } catch (e) {
      // Log the error but keep the current state
      print('Error loading dreams: $e');
    } finally {
      // Set loading state to false when done
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }

  Future<DreamEntry> addDream(DreamEntry dream) async {
    try {
      _ref.read(dreamsLoadingProvider.notifier).state = true;
      final interpretedDream = await _repository.addDream(dream);
      state = state.contains(interpretedDream)
          ? [...state]
          : [...state, interpretedDream];
      return interpretedDream;
    } finally {
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }

  Future<void> updateDream(DreamEntry dream) async {
    try {
      _ref.read(dreamsLoadingProvider.notifier).state = true;
      await _repository.updateDream(dream);
      state = [
        for (final item in state)
          if (item.id == dream.id) dream else item
      ];
    } finally {
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteDream(int? id) async {
    try {
      _ref.read(dreamsLoadingProvider.notifier).state = true;
      await _repository.deleteDream(id);
      state = state.where((dream) => dream.id != id).toList();
    } finally {
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }
}
