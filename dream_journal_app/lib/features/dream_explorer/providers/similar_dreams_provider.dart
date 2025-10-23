import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_summary_model.dart';
import 'dream_explorer_repository_provider.dart';

class SimilarDreamsState {
  final List<DreamSummary> similarDreams;
  final bool isLoading;
  final String? error;
  final int? sourceDreamId;

  SimilarDreamsState({
    this.similarDreams = const [],
    this.isLoading = false,
    this.error,
    this.sourceDreamId,
  });

  SimilarDreamsState copyWith({
    List<DreamSummary>? similarDreams,
    bool? isLoading,
    String? error,
    int? sourceDreamId,
  }) {
    return SimilarDreamsState(
      similarDreams: similarDreams ?? this.similarDreams,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sourceDreamId: sourceDreamId ?? this.sourceDreamId,
    );
  }
}

class SimilarDreamsNotifier extends StateNotifier<SimilarDreamsState> {
  final Ref _ref;

  SimilarDreamsNotifier(this._ref) : super(SimilarDreamsState());

  Future<void> findSimilar(int dreamId, {int topK = 5}) async {
    if (topK < 1 || topK > 20) {
      state = state.copyWith(error: 'Top K must be between 1 and 20');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      sourceDreamId: dreamId,
    );

    try {
      final repository = _ref.read(dreamExplorerRepositoryProvider);
      final response = await repository.findSimilarDreams(dreamId, topK: topK);

      state = state.copyWith(
        similarDreams: response.dreams,
        isLoading: false,
        error: null,
      );

      debugPrint('SimilarDreamsNotifier: Found ${response.dreams.length} similar dreams');
    } catch (e) {
      debugPrint('SimilarDreamsNotifier: Error finding similar dreams: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearResults() {
    state = SimilarDreamsState();
    debugPrint('SimilarDreamsNotifier: Results cleared');
  }
}

final similarDreamsProvider =
    StateNotifierProvider<SimilarDreamsNotifier, SimilarDreamsState>((ref) {
  return SimilarDreamsNotifier(ref);
});
