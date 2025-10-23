import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamidiary/features/dream_explorer/providers/search_state_provider.dart';

void main() {
  group('SearchState', () {
    test('initial state has empty search results', () {
      final state = SearchState();

      expect(state.searchResults.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.totalFound, 0);
      expect(state.currentQuery, null);
    });

    test('copyWith creates new state with updated values', () {
      final state = SearchState();
      final newState = state.copyWith(isLoading: true, totalFound: 5);

      expect(newState.isLoading, true);
      expect(newState.totalFound, 5);
      expect(newState.searchResults, state.searchResults);
    });
  });

  group('SearchStateNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () {
      final state = container.read(searchStateProvider);

      expect(state.searchResults.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('searchDreams validates empty query', () async {
      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchDreams('');

      final state = container.read(searchStateProvider);
      expect(state.error, 'Search query cannot be empty');
    });

    test('searchDreams validates query length - too short', () async {
      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchDreams('ab');

      final state = container.read(searchStateProvider);
      expect(state.error, 'Search query must be between 3 and 500 characters');
    });

    test('searchDreams validates query length - too long', () async {
      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchDreams('a' * 501);

      final state = container.read(searchStateProvider);
      expect(state.error, 'Search query must be between 3 and 500 characters');
    });

    test('searchDreams validates date range', () async {
      final notifier = container.read(searchStateProvider.notifier);

      await notifier.searchDreams(
        'test query',
        startDate: DateTime(2024, 12, 31),
        endDate: DateTime(2024, 1, 1),
      );

      final state = container.read(searchStateProvider);
      expect(state.error, 'Start date must be before end date');
    });

    test('clearSearch resets state', () async {
      final notifier = container.read(searchStateProvider.notifier);

      // Set some state
      await notifier.searchDreams('');

      // Clear
      notifier.clearSearch();

      final state = container.read(searchStateProvider);
      expect(state.searchResults.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.totalFound, 0);
      expect(state.currentQuery, null);
    });
  });
}
