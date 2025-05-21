import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../../features/auth/domain/models/user.dart';
import '../../../../../features/dreams/providers/dreams_provider.dart';
import '../../../../../features/dreams/data/models/dream_entry.dart';
import 'package:intl/intl.dart';
import '../../../../../core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/providers/core_providers.dart';

class ProfileState {
  final String name;
  final String email;
  final String memberSince;
  final int totalDreams;
  final int dreamStreak;
  final bool isGuest;

  ProfileState({
    required this.name,
    required this.email,
    required this.memberSince,
    required this.totalDreams,
    required this.dreamStreak,
    required this.isGuest,
  });

  // Create a copy of the current state with optional new values
  ProfileState copyWith({
    String? name,
    String? email,
    String? memberSince,
    int? totalDreams,
    int? dreamStreak,
    bool? isGuest,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      memberSince: memberSince ?? this.memberSince,
      totalDreams: totalDreams ?? this.totalDreams,
      dreamStreak: dreamStreak ?? this.dreamStreak,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

// Profile provider that automatically updates when auth state changes
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.value;
  final dreams = ref.watch(dreamsProvider);
  final apiClient = ref.read(apiClientProvider);

  return ProfileNotifier(user, dreams, apiClient, ref);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiClient _apiClient;
  final Ref _ref;

  ProfileNotifier(
      User? user, List<DreamEntry> dreams, this._apiClient, this._ref)
      : super(ProfileState(
          name: user?.name ?? 'Guest User',
          email: user?.email ?? 'guest@example.com',
          memberSince: _calculateMemberSince(user, dreams),
          totalDreams: dreams.length,
          dreamStreak: _calculateDreamStreak(dreams),
          isGuest: user?.isGuest ?? true,
        ));

  // Calculate member since date based on user's dateCreated or the first dream entry
  static String _calculateMemberSince(User? user, List<DreamEntry> dreams) {
    // If user has a dateCreated field, use that
    if (user?.dateCreated != null) {
      return DateFormat('MMM yyyy').format(user!.dateCreated!);
    }

    // Fallback to old method if dateCreated is not available
    if (dreams.isEmpty) {
      return user?.isGuest ?? true ? '2025' : '2025';
    }

    // Find the oldest dream
    final sortedDreams = List<DreamEntry>.from(dreams)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Use the date of the oldest dream as member since date
    final firstDreamDate = sortedDreams.first.timestamp;
    return DateFormat('MMM yyyy').format(firstDreamDate);
  }

  // Calculate dream streak
  static int _calculateDreamStreak(List<DreamEntry> dreams) {
    if (dreams.isEmpty) {
      return 0;
    }

    // Sort dreams by date, newest first
    final sortedDreams = List<DreamEntry>.from(dreams)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Check if there's a dream from today
    final today = DateTime.now();
    final todayFormatted = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime? lastDate;

    for (var dream in sortedDreams) {
      final dreamDate = DateTime(
        dream.timestamp.year,
        dream.timestamp.month,
        dream.timestamp.day,
      );

      // First dream in the loop
      if (lastDate == null) {
        lastDate = dreamDate;
        streak = 1;

        if (dreamDate.isAtSameMomentAs(todayFormatted)) {
          // Dream is from today
        } else {
          // If first dream is not today, check if it's yesterday
          final yesterday = todayFormatted.subtract(const Duration(days: 1));
          if (!dreamDate.isAtSameMomentAs(yesterday)) {
            // If first dream is not yesterday, streak is broken
            return 0;
          }
        }
        continue;
      }

      // Check if this dream is from the day before the last one
      final expectedPreviousDay = lastDate.subtract(const Duration(days: 1));

      if (dreamDate.isAtSameMomentAs(expectedPreviousDay)) {
        streak++;
        lastDate = dreamDate;
      } else if (dreamDate.isBefore(expectedPreviousDay)) {
        // Found a gap, streak is broken
        break;
      }
    }

    return streak;
  }

  // Update profile data locally
  void updateProfile({
    String? name,
    String? email,
    String? memberSince,
    int? totalDreams,
    int? dreamStreak,
    bool? isGuest,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      memberSince: memberSince,
      totalDreams: totalDreams,
      dreamStreak: dreamStreak,
      isGuest: isGuest,
    );
  }

  // Update user's name on the backend
  Future<bool> updateUserName(String name) async {
    try {
      await _apiClient.put('/users/me', body: {'name': name});

      // Optimistically update the local profile state
      updateProfile(name: name);

      // Update the authProvider's state directly
      _ref.read(authProvider.notifier).updateUserNameInState(name);

      // No longer needed as authProvider update will trigger rebuilds
      // _ref.refresh(authProvider);
      return true;
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    }
  }
}
