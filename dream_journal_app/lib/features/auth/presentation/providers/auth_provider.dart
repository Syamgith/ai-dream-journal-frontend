import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/auth/auth_service.dart';
import './auth_providers.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user.dart';
import '../../../dreams/providers/dreams_provider.dart';

// Auth repository provider
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   return AuthRepository();
// });

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(Ref ref)
      : _ref = ref,
        _repository = ref.watch(authRepositoryProvider),
        super(const AsyncValue.loading()) {
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
            // First try to get the current user with the existing token
            try {
              final user = await _repository.getCurrentUser();
              if (user != null) {
                state = AsyncValue.data(user);
                // Reset dreams cache and force refresh dreams data when user is already logged in
                _ref.read(dreamsProvider.notifier).reset();
                await _refreshDreamsData(forceRefresh: true);
                return; // Successfully authenticated with existing token
              }
            } catch (e) {
              // If getting user with existing token fails, try refreshing the token
              debugPrint('Error getting user with existing token: $e');
            }

            // Attempt to refresh the token
            final tokenRefreshed = await refreshToken();
            if (tokenRefreshed) {
              // Fetch user info from API with the refreshed token
              final user = await _repository.getCurrentUser();
              if (user != null) {
                state = AsyncValue.data(user);
                // Reset dreams cache and force refresh dreams data when user is authenticated with refreshed token
                _ref.read(dreamsProvider.notifier).reset();
                await _refreshDreamsData(forceRefresh: true);
              } else {
                // User info not found but we won't log out automatically
                // Just set state to null but keep tokens
                state = const AsyncValue.data(null);
                // Reset dreams cache since we're not authenticated
                _ref.read(dreamsProvider.notifier).reset();
              }
            } else {
              // Token refresh failed, but we'll still keep the tokens
              // and let the user try to authenticate again
              state = const AsyncValue.data(null);
              // Reset dreams cache since we're not authenticated
              _ref.read(dreamsProvider.notifier).reset();
            }
          } catch (e) {
            // Error during authentication process
            // We'll set state to null but won't delete tokens
            debugPrint('Error during authentication check: $e');
            state = const AsyncValue.data(null);
            // Reset dreams cache due to authentication error
            _ref.read(dreamsProvider.notifier).reset();
          }
        } else {
          state = const AsyncValue.data(null);
          // Reset dreams cache since we don't have a token
          _ref.read(dreamsProvider.notifier).reset();
        }
      } else {
        state = const AsyncValue.data(null);
        // Reset dreams cache since user is not logged in
        _ref.read(dreamsProvider.notifier).reset();
      }
    } catch (e) {
      // Error checking auth status
      debugPrint('Error checking auth status: $e');
      state = AsyncValue.error(e, StackTrace.current);
      // Reset dreams cache due to auth status error
      _ref.read(dreamsProvider.notifier).reset();
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
      // Clear any existing dreams before registration
      _ref.read(dreamsProvider.notifier).reset();

      final user = await _repository.registerAndLogin(email, password, name);
      state = AsyncValue.data(user);

      // Force refresh dreams data after successful registration and login
      await _refreshDreamsData(forceRefresh: true);

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
      // Clear any existing dreams before login
      _ref.read(dreamsProvider.notifier).reset();

      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);

      // Force refresh dreams data after successful login
      await _refreshDreamsData(forceRefresh: true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Login with Google
  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // Clear any existing dreams before login
      _ref.read(dreamsProvider.notifier).reset();

      final user = await _repository.loginWithGoogle();
      state = AsyncValue.data(user);

      // Force refresh dreams data after successful Google login
      await _refreshDreamsData(forceRefresh: true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Login as guest
  Future<void> loginAsGuest() async {
    state = const AsyncValue.loading();
    try {
      // Clear any existing dreams before login
      _ref.read(dreamsProvider.notifier).reset();

      final user = await _repository.loginAsGuest();
      state = AsyncValue.data(user);

      // Force refresh dreams data after successful guest login
      await _refreshDreamsData(forceRefresh: true);
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
      final user =
          await _repository.convertGuestToRegisteredUser(email, password, name);
      state = AsyncValue.data(user);

      // Force refresh dreams data after successful conversion
      await _refreshDreamsData(forceRefresh: true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Refresh dreams data
  Future<void> _refreshDreamsData({bool forceRefresh = false}) async {
    await _ref
        .read(dreamsProvider.notifier)
        .loadDreams(forceRefresh: forceRefresh);
  }

  // Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      // Clear the dreams cache before logout
      _ref.read(dreamsProvider.notifier).reset();

      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Add this new method
  Future<void> forceLogout() async {
    debugPrint("AuthNotifier: forceLogout initiated by system.");
    try {
      // Standard logout procedure: clear tokens, user data, Google sign-out.
      // _repository.logout() handles API calls and local data clearing.
      await _repository.logout();
    } catch (e) {
      // Log error during repository's logout, but ensure local state is cleared.
      debugPrint(
          "Error during _repository.logout() in forceLogout: $e. Ensuring local state is cleared.");
      // _repository.logout() has a finally block that calls _clearLocalAuthData(),
      // so local tokens/data should be cleared even if API call fails.
    } finally {
      // Crucially, reset any user-specific data (like dreams) and update the auth state.
      _ref.read(dreamsProvider.notifier).reset();
      state = const AsyncValue.data(
          null); // This will notify listeners and trigger UI navigation.
      debugPrint(
          "AuthNotifier: forceLogout completed. Auth state set to null.");
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteAccount();
      state = const AsyncValue.data(null);
      // Clear dreams cache after account deletion
      _ref.read(dreamsProvider.notifier).reset();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final newToken = await AuthRepository.refreshToken();
      return newToken != null;
    } catch (e) {
      debugPrint('Error refreshing token in AuthNotifier: $e');
      return false;
    }
  }
}

// Main auth provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});
