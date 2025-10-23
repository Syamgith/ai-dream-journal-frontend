import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_summary_model.dart';
import 'dream_explorer_repository_provider.dart';

class SearchState {
  final List<DreamSummary> searchResults;
  final bool isLoading;
  final String? error;
  final int totalFound;
  final String? currentQuery;

  SearchState({
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
    this.totalFound = 0,
    this.currentQuery,
  });

  SearchState copyWith({
    List<DreamSummary>? searchResults,
    bool? isLoading,
    String? error,
    int? totalFound,
    String? currentQuery,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalFound: totalFound ?? this.totalFound,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

class SearchStateNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchStateNotifier(this._ref) : super(SearchState());

  Future<void> searchDreams(
    String query, {
    int topK = 5,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? emotionTags,
  }) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(error: 'Search query cannot be empty');
      return;
    }

    if (query.length < 3 || query.length > 500) {
      state = state.copyWith(
          error: 'Search query must be between 3 and 500 characters');
      return;
    }

    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      state = state.copyWith(error: 'Start date must be before end date');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentQuery: query,
    );

    try {
      final repository = _ref.read(dreamExplorerRepositoryProvider);
      final response = await repository.searchDreams(
        query,
        topK: topK,
        startDate: startDate,
        endDate: endDate,
        emotionTags: emotionTags,
      );

      state = state.copyWith(
        searchResults: response.dreams,
        totalFound: response.totalFound,
        isLoading: false,
        error: null,
      );

      debugPrint('SearchStateNotifier: Search completed with ${response.totalFound} results');
    } catch (e) {
      debugPrint('SearchStateNotifier: Error searching dreams: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = SearchState();
    debugPrint('SearchStateNotifier: Search cleared');
  }
}

final searchStateProvider =
    StateNotifierProvider<SearchStateNotifier, SearchState>((ref) {
  return SearchStateNotifier(ref);
});
