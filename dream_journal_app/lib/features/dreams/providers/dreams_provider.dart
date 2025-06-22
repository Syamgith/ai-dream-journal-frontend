import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_entry.dart';
import './dream_repository_provider.dart';
import '../data/repositories/dream_repository.dart';
import 'package:flutter/foundation.dart';

// Provider to track loading state for dreams
final dreamsLoadingProvider = StateProvider<bool>((ref) => false);

// Provider to track if initial loading has been done
final dreamsInitialLoadProvider = StateProvider<bool>((ref) => false);

final dreamsProvider =
    StateNotifierProvider<DreamsNotifier, List<DreamEntry>>((ref) {
  final repository = ref.watch(dreamRepositoryProvider);
  return DreamsNotifier(repository, ref);
});

class DreamsNotifier extends StateNotifier<List<DreamEntry>> {
  final DreamRepository _repository;
  final Ref _ref;
  bool _hasInitialLoad = false;

  DreamsNotifier(this._repository, this._ref) : super([]) {
    // Don't call loadDreams() directly in the constructor
    // This avoids modifying other providers during initialization
  }

  // Method to initialize data loading
  Future<void> initialize() async {
    if (!_hasInitialLoad) {
      await loadDreams();
    }
  }

  // Check if initial load has been done
  bool get hasInitialLoad => _hasInitialLoad;

  // Reset state when user logs out
  void reset() {
    // Clear the repository cache
    _repository.clearCache();
    // Reset state to empty
    state = [];
    // Reset initial load flag
    _hasInitialLoad = false;
    _ref.read(dreamsInitialLoadProvider.notifier).state = false;
  }

  // Load dreams with force refresh option
  Future<void> loadDreams({bool forceRefresh = false}) async {
    try {
      // If we already have dreams in the cache and this isn't the first load,
      // don't show the loading indicator to avoid UI flicker
      final bool showLoading =
          state.isEmpty || !_hasInitialLoad || forceRefresh;

      if (showLoading) {
        _ref.read(dreamsLoadingProvider.notifier).state = true;
      }

      // Fetch dreams from the repository with force refresh if needed
      final dreams = await _repository.getDreams(forceRefresh: forceRefresh);

      // Update the state with the fetched dreams
      state = dreams;

      // Mark that we've done the initial load
      if (!_hasInitialLoad) {
        _hasInitialLoad = true;
        _ref.read(dreamsInitialLoadProvider.notifier).state = true;
      }
    } catch (e) {
      // Log the error but keep the current state
      debugPrint('Error loading dreams: $e');
    } finally {
      // Set loading state to false when done
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }

  // Add a dream without triggering a full reload
  Future<DreamEntry> addDream(DreamEntry dream) async {
    try {
      // Only show loading indicator if this is the first dream
      final bool showLoading = state.isEmpty;
      if (showLoading) {
        _ref.read(dreamsLoadingProvider.notifier).state = true;
      }

      final interpretedDream = await _repository.addDream(dream);

      // Update the state by adding the new dream to the existing list
      // This avoids a full reload and preserves the existing dream cards
      if (!state.contains(interpretedDream)) {
        state = [...state, interpretedDream];
      }

      return interpretedDream;
    } finally {
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }

  // Update a dream without triggering a full reload
  Future<DreamEntry> updateDream(DreamEntry dream) async {
    try {
      // Using a direct update approach without loading indicator to avoid UI flicker
      final interpretedDream = await _repository.updateDream(dream);

      // Update only the specific dream in the list
      state = [
        for (final item in state)
          if (item.id == dream.id) interpretedDream else item
      ];
      return interpretedDream;
    } finally {
      // Ensure loading state is false when done
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }

  // Delete a dream without triggering a full reload
  Future<void> deleteDream(int? id) async {
    if (id == null) return;

    try {
      // Using a direct delete approach without loading indicator to avoid UI flicker
      await _repository.deleteDream(id);

      // Remove the specific dream from the list
      state = state.where((dream) => dream.id != id).toList();
    } finally {
      // Ensure loading state is false when done
      _ref.read(dreamsLoadingProvider.notifier).state = false;
    }
  }

  // Report a dream for inappropriate content
  Future<void> reportDream(int dreamId, {String? reason}) async {
    try {
      await _repository.reportDream(dreamId, reason: reason);
    } catch (e) {
      rethrow;
    }
  }

  // Method to refresh a specific dream by ID
  Future<void> refreshDream(int id) async {
    try {
      // Get the updated dream from the repository
      final updatedDreams = await _repository.getDreams();
      final updatedDream = updatedDreams.firstWhere(
        (dream) => dream.id == id,
        orElse: () => state.firstWhere(
          (dream) => dream.id == id,
          orElse: () => throw Exception('Dream not found'),
        ),
      );

      // Update only this specific dream in the state
      state = [
        for (final item in state)
          if (item.id == id) updatedDream else item
      ];
    } catch (e) {
      debugPrint('Error refreshing dream: $e');
    }
  }
}
