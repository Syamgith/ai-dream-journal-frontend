import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/dream_repository.dart';
import '../../../core/providers/core_providers.dart'; // For apiClientProvider

final dreamRepositoryProvider = Provider<DreamRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DreamRepository(apiClient);
});
