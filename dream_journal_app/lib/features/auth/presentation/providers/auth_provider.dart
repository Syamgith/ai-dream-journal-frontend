import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user.dart';
import '../../../dreams/providers/dreams_provider.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    state = const AsyncValue.loading();
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        // Get the token
        final token = await AuthService.getToken();
        if (token != null) {
          try {
            // Attempt to refresh the token to ensure it's still valid
            final tokenRefreshed = await refreshToken();
            if (tokenRefreshed) {
              // Fetch user info from API
              final user = await _repository.getCurrentUser();
              if (user != null) {
                state = AsyncValue.data(user);

                // Refresh dreams data when user is already logged in
                await _refreshDreamsData();
              } else {
                // User info not found, user needs to login again
                await _repository.logout();
                state = const AsyncValue.data(null);
              }
            } else {
              // Token refresh failed, user needs to login again
              await _repository.logout();
              state = const AsyncValue.data(null);
            }
          } catch (e) {
            // Error refreshing token, user needs to login again
            await _repository.logout();
            state = const AsyncValue.data(null);
          }
        } else {
          state = const AsyncValue.data(null);
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Register a new user
  Future<bool> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.register(email, password, name);
      // After registration, the user still needs to login
      state = const AsyncValue.data(null);
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Register and automatically login
  Future<User> registerAndLogin(
      String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerAndLogin(email, password, name);
      state = AsyncValue.data(user);

      // Refresh dreams data after successful registration and login
      await _refreshDreamsData();

      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Login a user
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);

      // Refresh dreams data after successful login
      await _refreshDreamsData();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Login as guest
  Future<void> loginAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginAsGuest();
      state = AsyncValue.data(user);

      // Refresh dreams data after successful guest login
      await _refreshDreamsData();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Convert guest user to regular user
  Future<void> convertGuestUser(
      String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.convertGuestUser(name, email, password);
      state = AsyncValue.data(user);

      // Refresh dreams data after successful conversion
      await _refreshDreamsData();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Refresh dreams data
  Future<void> _refreshDreamsData() async {
    try {
      // Access the dreams notifier and refresh the dreams data
      await _ref.read(dreamsProvider.notifier).loadDreams();
    } catch (e) {
      // Log the error but don't rethrow it to avoid disrupting the login flow
      print('Error refreshing dreams data: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final newToken = await _repository.refreshToken();
      return newToken != null;
    } catch (e) {
      return false;
    }
  }
}

// Auth provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});
