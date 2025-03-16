import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'providers/profile_provider.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';

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
        actions: [
          _buildLogoutButton(context, ref),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(profile, context, ref),
          const SizedBox(height: 20),
          _buildStatsCard(profile),
          const SizedBox(height: 20),
          if (profile.isGuest) _buildGuestMessage(context, ref),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout, color: AppColors.white),
      onPressed: () => _showLogoutConfirmation(context, ref),
      tooltip: 'Logout',
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: const Text('Logout', style: TextStyle(color: AppColors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: AppColors.lightBlue)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, ProfileState profile) {
    final nameController = TextEditingController(text: profile.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: const Text('Edit Profile',
            style: TextStyle(color: AppColors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: AppColors.lightBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.lightBlue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Email is displayed but not editable
              TextField(
                controller: TextEditingController(text: profile.email),
                style: const TextStyle(color: AppColors.white),
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email (cannot be changed)',
                  labelStyle: const TextStyle(color: AppColors.lightBlue),
                  disabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.lightBlue.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            onPressed: () {
              // Update profile with new name
              ref.read(profileProvider.notifier).updateProfile(
                    name: nameController.text.trim(),
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestMessage(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'You are currently using a guest account',
              style: TextStyle(color: AppColors.lightBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                // Navigate to login page
                ref.read(authProvider.notifier).logout();
              },
              child: const Text('Sign in to save your dreams'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      ProfileState profile, BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (!profile.isGuest)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                    onPressed: () =>
                        _showEditProfileDialog(context, ref, profile),
                    tooltip: 'Edit Profile',
                  ),
              ],
            ),
            const SizedBox(height: 8),
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
            const Text(
              'Dream Statistics',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
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
