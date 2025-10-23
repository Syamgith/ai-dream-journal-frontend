import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/providers/core_providers.dart';

// This provider will be defined in core_providers.dart later
// extern final apiClientProvider;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(
      apiClientProvider); // apiClientProvider will be defined in core_providers.dart
  return AuthRepository(apiClient);
});
