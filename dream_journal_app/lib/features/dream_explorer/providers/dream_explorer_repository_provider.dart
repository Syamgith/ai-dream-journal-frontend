import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/repositories/dream_explorer_repository.dart';

final dreamExplorerRepositoryProvider = Provider<DreamExplorerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DreamExplorerRepository(apiClient);
});
