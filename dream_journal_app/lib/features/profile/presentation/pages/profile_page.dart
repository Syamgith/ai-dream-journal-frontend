import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/widgets/auth_button.dart';
import 'providers/profile_provider.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/error_message_display.dart';
import '../../../../core/utils/error_formatter.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileCard(profile, context, ref),
              const SizedBox(height: 20),
              _buildStatsCard(profile, context, ref),
              const SizedBox(height: 20),
              if (profile.isGuest) _buildGuestMessage(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: AppColors.white),
        label: const Text('Logout', style: TextStyle(color: AppColors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _showLogoutConfirmation(context, ref),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    // Check if the current user is a guest
    final authState = ref.read(authProvider);
    final isGuest = authState.value?.isGuest ?? false;

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
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlue,
          title: const Text('Edit Profile',
              style: TextStyle(color: AppColors.white)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 320,
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
                      constraints: BoxConstraints(maxWidth: 320),
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
                      constraints: const BoxConstraints(maxWidth: 320),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppColors.lightBlue.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    ErrorMessageDisplay(
                      message: errorMessage!,
                      compact: true,
                      padding: const EdgeInsets.only(top: 16),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.primaryBlue)),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate input
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          setState(() {
                            errorMessage = 'Name cannot be empty';
                          });
                          return;
                        }

                        // Set loading state
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        try {
                          // Call API to update user name
                          await ref
                              .read(profileProvider.notifier)
                              .updateUserName(newName);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            CustomSnackbar.show(
                              context: context,
                              message: 'Profile updated successfully',
                              type: SnackBarType.success,
                            );
                          }
                        } catch (e) {
                          setState(() {
                            errorMessage = ErrorFormatter.format(e);
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGuestMessage(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You are currently using a guest account',
              style: TextStyle(color: AppColors.lightBlue, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Convert to a regular account to save your dreams permanently',
              style: TextStyle(color: AppColors.lightBlue, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 300,
                height: 36,
                child: AuthButton(
                  text: 'Convert to Regular Account',
                  onPressed: () => _showConvertGuestDialog(context, ref),
                  isLoading: false,
                  backgroundColor: AppColors.primaryBlue,
                  textColor: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your dreams will be lost if you logout',
              style: TextStyle(color: AppColors.lightBlue, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Center(
              child: SizedBox(
                width: 140,
                height: 36,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  onPressed: () => _showLogoutConfirmation(context, ref),
                  child: const Text('Logout',
                      style: TextStyle(color: AppColors.primaryBlue)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConvertGuestDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    String? errorMessage;
    bool isConverting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.darkBlue,
            title: const Text('Create Your Account',
                style: TextStyle(color: AppColors.white)),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Convert your guest account to a regular account to save your dreams permanently.',
                      style:
                          TextStyle(color: AppColors.lightBlue, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
                        constraints: BoxConstraints(maxWidth: 320),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: AppColors.lightBlue),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightBlue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        constraints: BoxConstraints(maxWidth: 320),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: AppColors.lightBlue),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightBlue),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.lightBlue,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: AppColors.lightBlue),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightBlue),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.lightBlue,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    if (errorMessage != null)
                      ErrorMessageDisplay(
                        message: errorMessage!,
                        compact: true,
                        padding: const EdgeInsets.only(top: 16),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isConverting ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.primaryBlue)),
              ),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(180, 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  onPressed: isConverting
                      ? null
                      : () async {
                          // Validate inputs
                          if (nameController.text.trim().isEmpty) {
                            setState(() {
                              errorMessage = 'Please enter your name';
                            });
                            return;
                          }
                          if (emailController.text.trim().isEmpty) {
                            setState(() {
                              errorMessage = 'Please enter your email';
                            });
                            return;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(emailController.text.trim())) {
                            setState(() {
                              errorMessage = 'Please enter a valid email';
                            });
                            return;
                          }
                          if (passwordController.text.length < 6) {
                            setState(() {
                              errorMessage =
                                  'Password must be at least 6 characters';
                            });
                            return;
                          }
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            setState(() {
                              errorMessage = 'Passwords do not match';
                            });
                            return;
                          }

                          // Convert guest user
                          setState(() {
                            errorMessage = null;
                            isConverting = true;
                          });

                          try {
                            await ref
                                .read(authProvider.notifier)
                                .convertGuestUser(
                                  nameController.text.trim(),
                                  emailController.text.trim(),
                                  passwordController.text,
                                );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              CustomSnackbar.show(
                                context: context,
                                message:
                                    'Your account has been successfully created!',
                                type: SnackBarType.success,
                              );
                            }
                          } catch (e) {
                            setState(() {
                              errorMessage = ErrorFormatter.format(e);
                              isConverting = false;
                            });
                          }
                        },
                  child: isConverting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
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

  Widget _buildStatsCard(
      ProfileState profile, BuildContext context, WidgetRef ref) {
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
            if (!profile.isGuest) ...[
              const Divider(color: AppColors.lightBlue, height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: _buildLogoutButton(context, ref),
              ),
            ],
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
