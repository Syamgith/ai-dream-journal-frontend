import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.person, size: 50, color: AppColors.white),
          ),
          const SizedBox(height: 20),
          _buildProfileCard(),
          const SizedBox(height: 20),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileItem(Icons.person, 'Name', 'User Name'),
            _buildProfileItem(Icons.email, 'Email', 'user@example.com'),
            _buildProfileItem(Icons.calendar_today, 'Member Since', 'Jan 2024'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatItem('Total Dreams', '42'),
            _buildStatItem('Dream Streak', '7 days'),
            _buildStatItem('Average Sleep', '7.5 hours'),
          ],
        ),
      ),
    );
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
}
