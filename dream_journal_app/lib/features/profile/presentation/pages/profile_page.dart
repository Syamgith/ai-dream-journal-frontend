import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(profile),
          const SizedBox(height: 20),
          _buildStatsCard(profile),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ProfileState profile) {
    return Card(
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileItem(Icons.person, 'Name', profile.name),
            _buildProfileItem(Icons.email, 'Email', profile.email),
            _buildProfileItem(
                Icons.calendar_today, 'Member Since', profile.memberSince),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ProfileState profile) {
    return Card(
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatItem('Total Dreams', '${profile.totalDreams}'),
            _buildStatItem('Dream Streak', '${profile.dreamStreak} days'),
            _buildStatItem('Average Sleep', '${profile.averageSleep} hours'),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileItem(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.lightBlue)),
            Text(value, style: const TextStyle(color: AppColors.white)),
          ],
        ),
      ],
    ),
  );
}

Widget _buildStatItem(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.lightBlue)),
        Text(value,
            style: const TextStyle(
                color: AppColors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
