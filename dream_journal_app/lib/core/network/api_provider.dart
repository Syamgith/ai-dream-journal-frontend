import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/config.dart';
import 'api_client.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ApiClient(
    baseUrl: Config.apiURL,
    authRepository: authRepository,
  );
});

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
