import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String name;
  final String email;
  final String memberSince;
  final int totalDreams;
  final int dreamStreak;
  final double averageSleep;

  ProfileState({
    required this.name,
    required this.email,
    required this.memberSince,
    required this.totalDreams,
    required this.dreamStreak,
    required this.averageSleep,
  });
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          name: 'User Name',
          email: 'user@example.com',
          memberSince: 'Jan 2024',
          totalDreams: 42,
          dreamStreak: 7,
          averageSleep: 7.5,
        ));

  void updateProfile({
    String? name,
    String? email,
    String? memberSince,
    int? totalDreams,
    int? dreamStreak,
    double? averageSleep,
  }) {
    state = ProfileState(
      name: name ?? state.name,
      email: email ?? state.email,
      memberSince: memberSince ?? state.memberSince,
      totalDreams: totalDreams ?? state.totalDreams,
      dreamStreak: dreamStreak ?? state.dreamStreak,
      averageSleep: averageSleep ?? state.averageSleep,
    );
  }
}
