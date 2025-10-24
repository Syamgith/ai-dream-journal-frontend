import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message_model.dart';
import '../data/models/dream_summary_model.dart';
import 'dream_explorer_repository_provider.dart';

class ConversationState {
  final List<ChatMessage> chatHistory;
  final bool isLoading;
  final String? error;
  final List<DreamSummary> relevantDreams;

  ConversationState({
    this.chatHistory = const [],
    this.isLoading = false,
    this.error,
    this.relevantDreams = const [],
  });

  ConversationState copyWith({
    List<ChatMessage>? chatHistory,
    bool? isLoading,
    String? error,
    List<DreamSummary>? relevantDreams,
  }) {
    return ConversationState(
      chatHistory: chatHistory ?? this.chatHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      relevantDreams: relevantDreams ?? this.relevantDreams,
    );
  }
}

class ConversationStateNotifier extends StateNotifier<ConversationState> {
  final Ref _ref;

  ConversationStateNotifier(this._ref) : super(ConversationState());

  Future<void> askQuestion(String question, {int topK = 5}) async {
    if (question.trim().isEmpty) {
      state = state.copyWith(error: 'Question cannot be empty');
      return;
    }

    if (question.length < 3 || question.length > 500) {
      state = state.copyWith(
          error: 'Question must be between 3 and 500 characters');
      return;
    }

    // Save old history before updating (to pass to API)
    final oldHistory = state.chatHistory;

    // Add user's message to chat history immediately for UI
    final userMessage = ChatMessage(
      role: 'user',
      content: question,
    );
    final updatedHistory = [...oldHistory, userMessage];

    state = state.copyWith(
      chatHistory: updatedHistory,
      isLoading: true,
      error: null,
    );

    try {
      final repository = _ref.read(dreamExplorerRepositoryProvider);
      // Pass old history (without user message) - backend will add it
      final response = await repository.askQuestion(
        question,
        oldHistory,
        topK: topK,
      );

      state = state.copyWith(
        chatHistory: response.chatHistory,
        relevantDreams: response.relevantDreams,
        isLoading: false,
        error: null,
      );

      debugPrint('ConversationStateNotifier: Question answered successfully');
    } catch (e) {
      debugPrint('ConversationStateNotifier: Error asking question: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearConversation() {
    state = ConversationState();
    debugPrint('ConversationStateNotifier: Conversation cleared');
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}

final conversationStateProvider =
    StateNotifierProvider<ConversationStateNotifier, ConversationState>((ref) {
  return ConversationStateNotifier(ref);
});
