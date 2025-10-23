import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamidiary/features/dream_explorer/providers/conversation_state_provider.dart';

void main() {
  group('ConversationState', () {
    test('initial state has empty chat history', () {
      final state = ConversationState();

      expect(state.chatHistory.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.relevantDreams.isEmpty, true);
    });

    test('copyWith creates new state with updated values', () {
      final state = ConversationState();
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, true);
      expect(newState.chatHistory, state.chatHistory);
    });

    test('copyWith with null error clears error', () {
      final state = ConversationState(error: 'Some error');
      final newState = state.copyWith(error: null);

      expect(newState.error, null);
    });
  });

  group('ConversationStateNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () {
      final state = container.read(conversationStateProvider);

      expect(state.chatHistory.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('askQuestion validates empty question', () async {
      final notifier = container.read(conversationStateProvider.notifier);

      await notifier.askQuestion('');

      final state = container.read(conversationStateProvider);
      expect(state.error, 'Question cannot be empty');
    });

    test('askQuestion validates question length - too short', () async {
      final notifier = container.read(conversationStateProvider.notifier);

      await notifier.askQuestion('ab');

      final state = container.read(conversationStateProvider);
      expect(state.error, 'Question must be between 3 and 500 characters');
    });

    test('askQuestion validates question length - too long', () async {
      final notifier = container.read(conversationStateProvider.notifier);

      await notifier.askQuestion('a' * 501);

      final state = container.read(conversationStateProvider);
      expect(state.error, 'Question must be between 3 and 500 characters');
    });

    test('clearConversation resets state', () async {
      final notifier = container.read(conversationStateProvider.notifier);

      // Set some state
      await notifier.askQuestion('');

      // Clear
      notifier.clearConversation();

      final state = container.read(conversationStateProvider);
      expect(state.chatHistory.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.relevantDreams.isEmpty, true);
    });

    test('resetError clears error', () async {
      final notifier = container.read(conversationStateProvider.notifier);

      // Set error
      await notifier.askQuestion('');

      // Reset error
      notifier.resetError();

      final state = container.read(conversationStateProvider);
      expect(state.error, null);
    });
  });
}
