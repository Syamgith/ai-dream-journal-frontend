import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes.dart';
import '../../profile/presentation/pages/providers/profile_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/error_message_display.dart';
import '../../../core/utils/error_formatter.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                // Calculate section height: divide by number of sections
                final numSections = profile.isGuest ? 4 : 3;
                final sectionHeight = availableHeight / numSections;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Part 1: Title Section
                      SizedBox(
                        height: sectionHeight,
                        child: _buildTitleSection(),
                      ),
                      _buildSectionDivider(),

                      // Extra spacing between title and profile
                      // const SizedBox(height: 16),
                      // _buildSectionDivider(),

                      // Part 2: Profile Info Section
                      SizedBox(
                        height: sectionHeight,
                        child: _buildProfileSection(context, ref, profile),
                      ),
                      _buildSectionDivider(),

                      // Part 3: Dream Statistics Section
                      SizedBox(
                        height: sectionHeight,
                        child: _buildStatsSection(profile),
                      ),
                      _buildSectionDivider(),

                      // Part 4: Guest User Section (if guest)
                      if (profile.isGuest) ...[
                        SizedBox(
                          height: sectionHeight,
                          child: _buildActionSection(
                              context, ref, profile.isGuest),
                        ),
                        _buildSectionDivider(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Part 5: Menu Section (always at bottom)
          _buildMenuSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.lightBlue.withValues(alpha: 0.3),
              AppColors.lightBlue.withValues(alpha: 0.5),
              AppColors.lightBlue.withValues(alpha: 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      color: AppColors.darkBlue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dreami Diary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Explore Your Dreams',
            style: TextStyle(
              color: AppColors.lightBlue,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
      BuildContext context, WidgetRef ref, ProfileState profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNameRow(context, ref, profile),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, profile.email, AppColors.lightBlue),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Member since ${profile.memberSince}',
            AppColors.lightBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildNameRow(
      BuildContext context, WidgetRef ref, ProfileState profile) {
    return Row(
      children: [
        const Icon(Icons.person, color: AppColors.primaryBlue, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            profile.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!profile.isGuest)
          IconButton(
            icon:
                const Icon(Icons.edit, color: AppColors.primaryBlue, size: 16),
            onPressed: () => _showChangeNameDialog(context, ref, profile.name),
            tooltip: 'Edit Name',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            iconSize: 16,
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ProfileState profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatRow('Total Dreams', '${profile.totalDreams}'),
          const SizedBox(height: 10),
          _buildStatRow('Dream Streak', '${profile.dreamStreak} days'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightBlue,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(
      BuildContext context, WidgetRef ref, bool isGuest) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Guest Account',
              style: TextStyle(
                color: AppColors.lightBlue,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Convert to save dreams permanently',
              style: TextStyle(
                color: AppColors.lightBlue,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                onPressed: () => _showConvertGuestDialog(context, ref),
                child: const Text(
                  'Convert Account',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: AppColors.lightBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            context,
            Icons.feedback,
            'Feedback',
            AppRoutes.feedback,
          ),
          _buildMenuItem(
            context,
            Icons.info,
            'About',
            AppRoutes.about,
          ),
          _buildMenuItem(
            context,
            Icons.settings,
            'Settings',
            AppRoutes.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeNameDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    final nameController = TextEditingController(text: currentName);
    String? errorMessage;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.darkBlue,
            title: const Text('Change Display Name',
                style: TextStyle(color: AppColors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: TextStyle(color: AppColors.lightBlue),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.lightBlue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                  ),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ErrorMessageDisplay(message: errorMessage!),
                  ),
              ],
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
                          final newName = nameController.text.trim();
                          if (newName.isEmpty) {
                            setState(() {
                              errorMessage = 'Name cannot be empty';
                            });
                            return;
                          }

                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          try {
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
        },
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
                style: TextStyle(color: AppColors.white, fontSize: 16)),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Convert your guest account to save dreams permanently.',
                      style:
                          TextStyle(color: AppColors.lightBlue, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      style:
                          const TextStyle(color: AppColors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle:
                            TextStyle(color: AppColors.lightBlue, fontSize: 12),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightBlue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style:
                          const TextStyle(color: AppColors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle:
                            TextStyle(color: AppColors.lightBlue, fontSize: 12),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightBlue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style:
                          const TextStyle(color: AppColors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                            color: AppColors.lightBlue, fontSize: 12),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightBlue),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.lightBlue,
                            size: 18,
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
                      style:
                          const TextStyle(color: AppColors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(
                            color: AppColors.lightBlue, fontSize: 12),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightBlue),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.lightBlue,
                            size: 18,
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
                        padding: const EdgeInsets.only(top: 12),
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
                    style:
                        TextStyle(color: AppColors.primaryBlue, fontSize: 12)),
              ),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
                            if (context.mounted) {
                              setState(() {
                                errorMessage = ErrorFormatter.format(e);
                                isConverting = false;
                              });
                            }
                          }
                        },
                  child: isConverting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
}
