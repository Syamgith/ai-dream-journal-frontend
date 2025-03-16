import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    state = const AsyncValue.loading();
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        // If we had a way to get the current user, we would use it here
        // For now, we'll just set the state to null
        state = const AsyncValue.data(null);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Register a new user
  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(email, password, name);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Login a user
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Login as guest
  Future<void> loginAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginAsGuest();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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
    }
  }
}

// Auth provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
