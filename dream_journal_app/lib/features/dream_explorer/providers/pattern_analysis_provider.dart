import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_summary_model.dart';
import 'dream_explorer_repository_provider.dart';

class PatternAnalysisState {
  final String? analysis;
  final List<DreamSummary> relevantDreams;
  final bool isLoading;
  final String? error;

  PatternAnalysisState({
    this.analysis,
    this.relevantDreams = const [],
    this.isLoading = false,
    this.error,
  });

  PatternAnalysisState copyWith({
    String? analysis,
    List<DreamSummary>? relevantDreams,
    bool? isLoading,
    String? error,
  }) {
    return PatternAnalysisState(
      analysis: analysis ?? this.analysis,
      relevantDreams: relevantDreams ?? this.relevantDreams,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PatternAnalysisNotifier extends StateNotifier<PatternAnalysisState> {
  final Ref _ref;

  PatternAnalysisNotifier(this._ref) : super(PatternAnalysisState());

  Future<void> analyzePatterns(String query, {int topK = 10}) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(error: 'Pattern query cannot be empty');
      return;
    }

    if (query.length < 3 || query.length > 200) {
      state = state.copyWith(
          error: 'Pattern query must be between 3 and 200 characters');
      return;
    }

    if (topK < 1 || topK > 50) {
      state = state.copyWith(error: 'Top K must be between 1 and 50');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = _ref.read(dreamExplorerRepositoryProvider);
      final response = await repository.findPatterns(query, topK: topK);

      state = state.copyWith(
        analysis: response.patternAnalysis,
        relevantDreams: response.relevantDreams,
        isLoading: false,
        error: null,
      );

      debugPrint('PatternAnalysisNotifier: Pattern analysis completed');
    } catch (e) {
      debugPrint('PatternAnalysisNotifier: Error analyzing patterns: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearAnalysis() {
    state = PatternAnalysisState();
    debugPrint('PatternAnalysisNotifier: Analysis cleared');
  }
}

final patternAnalysisProvider =
    StateNotifierProvider<PatternAnalysisNotifier, PatternAnalysisState>((ref) {
  return PatternAnalysisNotifier(ref);
});
