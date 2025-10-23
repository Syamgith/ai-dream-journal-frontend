import 'dream_summary_model.dart';
import 'chat_message_model.dart';

class DreamExplorerResponse {
  final String answer;
  final List<DreamSummary> relevantDreams;
  final List<ChatMessage> chatHistory;

  DreamExplorerResponse({
    required this.answer,
    required this.relevantDreams,
    required this.chatHistory,
  });

  factory DreamExplorerResponse.fromJson(Map<String, dynamic> json) {
    return DreamExplorerResponse(
      answer: json['answer'] as String,
      relevantDreams: (json['relevant_dreams'] as List<dynamic>)
          .map((dream) => DreamSummary.fromJson(dream as Map<String, dynamic>))
          .toList(),
      chatHistory: (json['chat_history'] as List<dynamic>)
          .map((message) => ChatMessage.fromJson(message as Map<String, dynamic>))
          .toList(),
    );
  }
}
