import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dream_explorer_repository_provider.dart';

class ComparisonState {
  final String? comparison;
  final int? selectedDream1Id;
  final int? selectedDream2Id;
  final bool isLoading;
  final String? error;

  ComparisonState({
    this.comparison,
    this.selectedDream1Id,
    this.selectedDream2Id,
    this.isLoading = false,
    this.error,
  });

  ComparisonState copyWith({
    String? comparison,
    int? selectedDream1Id,
    int? selectedDream2Id,
    bool? isLoading,
    String? error,
  }) {
    return ComparisonState(
      comparison: comparison ?? this.comparison,
      selectedDream1Id: selectedDream1Id ?? this.selectedDream1Id,
      selectedDream2Id: selectedDream2Id ?? this.selectedDream2Id,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get canCompare =>
      selectedDream1Id != null && selectedDream2Id != null && !isLoading;
}

class ComparisonStateNotifier extends StateNotifier<ComparisonState> {
  final Ref _ref;

  ComparisonStateNotifier(this._ref) : super(ComparisonState());

  void selectDream1(int dreamId) {
    state = state.copyWith(selectedDream1Id: dreamId, error: null);
    debugPrint('ComparisonStateNotifier: Dream 1 selected: $dreamId');
  }

  void selectDream2(int dreamId) {
    state = state.copyWith(selectedDream2Id: dreamId, error: null);
    debugPrint('ComparisonStateNotifier: Dream 2 selected: $dreamId');
  }

  Future<void> compareDreams(int dreamId1, int dreamId2) async {
    if (dreamId1 == dreamId2) {
      state = state.copyWith(error: 'Cannot compare a dream with itself');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedDream1Id: dreamId1,
      selectedDream2Id: dreamId2,
    );

    try {
      final repository = _ref.read(dreamExplorerRepositoryProvider);
      final response = await repository.compareDreams(dreamId1, dreamId2);

      state = state.copyWith(
        comparison: response.comparison,
        isLoading: false,
        error: null,
      );

      debugPrint('ComparisonStateNotifier: Dreams compared successfully');
    } catch (e) {
      debugPrint('ComparisonStateNotifier: Error comparing dreams: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearComparison() {
    state = ComparisonState();
    debugPrint('ComparisonStateNotifier: Comparison cleared');
  }
}

final comparisonStateProvider =
    StateNotifierProvider<ComparisonStateNotifier, ComparisonState>((ref) {
  return ComparisonStateNotifier(ref);
});
