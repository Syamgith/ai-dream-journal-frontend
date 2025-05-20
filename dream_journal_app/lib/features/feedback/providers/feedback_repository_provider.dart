import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/feedback_repository.dart';
import '../../../core/providers/core_providers.dart'; // For apiClientProvider

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedbackRepository(apiClient);
});
