import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../config/config.dart';
// AuthRepository provider will be needed by ApiClient indirectly via TokenInterceptor,
// but ApiClient itself doesn\'t directly depend on AuthRepository instance anymore.
// However, to ensure AuthRepository is available when TokenInterceptor needs it,
// we might need to ensure authRepositoryProvider is initialized.
// For simplicity now, we assume Riverpod handles dependency resolution.

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: Config.apiURL,
    ref: ref, // Pass the ref to ApiClient
  );
});
