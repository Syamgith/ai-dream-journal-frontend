import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../routes.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isGuest = authState.value?.isGuest ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
      ),
      body: Container(
        color: AppColors.background,
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // Account Settings Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Account',
                style: TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Logout option
            Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              color: AppColors.darkBlue,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  isGuest
                      ? 'Warning: Your dreams will be permanently deleted!'
                      : 'Sign out of your account',
                  style: TextStyle(
                    color: isGuest ? Colors.red : Colors.white.withOpacity(0.7),
                  ),
                ),
                onTap: () => _showLogoutConfirmation(context, ref, isGuest),
              ),
            ),

            const SizedBox(height: 20),

            // App Settings Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'App Settings',
                style: TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Theme option (placeholder for future implementation)
            Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              color: AppColors.darkBlue,
              child: ListTile(
                leading: const Icon(Icons.color_lens, color: Colors.white),
                title: const Text(
                  'Theme',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Dark Mode',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                onTap: () {
                  // Theme functionality to be implemented in the future
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Theme settings coming soon!'),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                },
              ),
            ),

            // Notification Settings (placeholder for future implementation)
            Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              color: AppColors.darkBlue,
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.white),
                title: const Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Manage notification settings',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                onTap: () {
                  // Notification settings to be implemented in the future
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings coming soon!'),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(
      BuildContext context, WidgetRef ref, bool isGuest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: const Text('Logout', style: TextStyle(color: AppColors.white)),
        content: Text(
            isGuest
                ? 'Are you sure you want to logout? Your dreams will be permanently deleted!'
                : 'Are you sure you want to logout?',
            style: const TextStyle(color: AppColors.lightBlue)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGuest ? Colors.red : AppColors.primaryBlue,
            ),
            onPressed: () async {
              // Close the dialog first
              Navigator.of(context).pop();

              // Navigate to the main route before logging out
              // This ensures we don't depend on state changes for navigation
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.main,
                  (route) => false, // Remove all previous routes
                );
              }

              // Now perform the logout operation
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
