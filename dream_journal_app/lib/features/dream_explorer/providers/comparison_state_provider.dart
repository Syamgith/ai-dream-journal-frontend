import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dream_explorer_repository_provider.dart';

class ComparisonState {
  final String? comparison;
  final int? selectedDream1Id;
  final String? selectedDream1Title;
  final int? selectedDream2Id;
  final String? selectedDream2Title;
  final bool isLoading;
  final String? error;

  ComparisonState({
    this.comparison,
    this.selectedDream1Id,
    this.selectedDream1Title,
    this.selectedDream2Id,
    this.selectedDream2Title,
    this.isLoading = false,
    this.error,
  });

  ComparisonState copyWith({
    String? comparison,
    int? selectedDream1Id,
    String? selectedDream1Title,
    int? selectedDream2Id,
    String? selectedDream2Title,
    bool? isLoading,
    String? error,
  }) {
    return ComparisonState(
      comparison: comparison ?? this.comparison,
      selectedDream1Id: selectedDream1Id ?? this.selectedDream1Id,
      selectedDream1Title: selectedDream1Title ?? this.selectedDream1Title,
      selectedDream2Id: selectedDream2Id ?? this.selectedDream2Id,
      selectedDream2Title: selectedDream2Title ?? this.selectedDream2Title,
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

  void selectDream1(int dreamId, String dreamTitle) {
    state = state.copyWith(
      selectedDream1Id: dreamId,
      selectedDream1Title: dreamTitle,
      error: null,
    );
    debugPrint('ComparisonStateNotifier: Dream 1 selected: $dreamId - $dreamTitle');
  }

  void selectDream2(int dreamId, String dreamTitle) {
    state = state.copyWith(
      selectedDream2Id: dreamId,
      selectedDream2Title: dreamTitle,
      error: null,
    );
    debugPrint('ComparisonStateNotifier: Dream 2 selected: $dreamId - $dreamTitle');
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
