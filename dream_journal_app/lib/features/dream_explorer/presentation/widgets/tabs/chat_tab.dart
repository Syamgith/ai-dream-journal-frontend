import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../providers/conversation_state_provider.dart';
import '../chat_message_bubble.dart';
import '../loading_chat_indicator.dart';
import '../error_message_widget.dart';
import '../dream_summary_card.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    _questionController.clear();
    await ref.read(conversationStateProvider.notifier).askQuestion(question);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final conversationState = ref.watch(conversationStateProvider);

    return Column(
      children: [
        // Chat history
        Expanded(
          child: conversationState.chatHistory.isEmpty &&
                  !conversationState.isLoading &&
                  conversationState.error == null
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: conversationState.chatHistory.length +
                      (conversationState.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == conversationState.chatHistory.length) {
                      return const LoadingChatIndicator();
                    }

                    final message = conversationState.chatHistory[index];
                    return ChatMessageBubble(message: message);
                  },
                ),
        ),

        // Relevant dreams section
        if (conversationState.relevantDreams.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(8),
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Relevant Dreams',
                    style: TextStyle(
                      color: AppColors.lightBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: conversationState.relevantDreams.length,
                    itemBuilder: (context, index) {
                      final dream = conversationState.relevantDreams[index];
                      return SizedBox(
                        width: 250,
                        child: DreamSummaryCard(
                          dreamSummary: dream,
                          onTap: () {
                            // Navigate to dream detail page
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],

        // Error message
        if (conversationState.error != null)
          ErrorMessageWidget(
            errorMessage: conversationState.error!,
            onRetry: () {
              ref.read(conversationStateProvider.notifier).resetError();
            },
          ),

        // Input section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  maxLines: null,
                  maxLength: 500,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask about your dreams...',
                    hintStyle: TextStyle(color: AppColors.white.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.lightBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.lightBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _askQuestion(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: conversationState.isLoading ? null : _askQuestion,
                icon: Icon(
                  Icons.send,
                  color: conversationState.isLoading
                      ? AppColors.white.withValues(alpha: 0.3)
                      : AppColors.primaryBlue,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.lightBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about your dreams!',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
