import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../../features/auth/domain/models/user.dart';

class ProfileState {
  final String name;
  final String email;
  final String memberSince;
  final int totalDreams;
  final int dreamStreak;
  final double averageSleep;
  final bool isGuest;

  ProfileState({
    required this.name,
    required this.email,
    required this.memberSince,
    required this.totalDreams,
    required this.dreamStreak,
    required this.averageSleep,
    required this.isGuest,
  });

  // Create a copy of the current state with optional new values
  ProfileState copyWith({
    String? name,
    String? email,
    String? memberSince,
    int? totalDreams,
    int? dreamStreak,
    double? averageSleep,
    bool? isGuest,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      memberSince: memberSince ?? this.memberSince,
      totalDreams: totalDreams ?? this.totalDreams,
      dreamStreak: dreamStreak ?? this.dreamStreak,
      averageSleep: averageSleep ?? this.averageSleep,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.value;

  return ProfileNotifier(user);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(User? user)
      : super(ProfileState(
          name: user?.name ?? 'Guest User',
          email: user?.email ?? 'guest@example.com',
          memberSince: 'Jan 2024', // This could be fetched from the backend
          totalDreams: 42,
          dreamStreak: 7,
          averageSleep: 7.5,
          isGuest: user?.isGuest ?? true,
        ));

  void updateProfile({
    String? name,
    String? email,
    String? memberSince,
    int? totalDreams,
    int? dreamStreak,
    double? averageSleep,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      memberSince: memberSince,
      totalDreams: totalDreams,
      dreamStreak: dreamStreak,
      averageSleep: averageSleep,
    );
  }
}
