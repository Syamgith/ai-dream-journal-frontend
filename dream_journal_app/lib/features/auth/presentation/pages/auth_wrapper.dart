import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../../../../features/shared/screens/main_screen.dart';
import '../../../../features/shared/widgets/loading_indicator.dart';
import '../../../../features/shared/widgets/error_message.dart';
import '../../../../core/utils/error_formatter.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // User is authenticated, navigate to main screen
          return const MainScreen();
        } else {
          // User is not authenticated, navigate to login screen
          return const LoginPage();
        }
      },
      loading: () => const Scaffold(
        body: LoadingIndicator(message: 'Journeying into your dream realm...'),
      ),
      error: (error, stackTrace) => Scaffold(
        body: ErrorMessage(
          message: ErrorFormatter.format(error),
          onRetry: () => ref.read(authProvider.notifier).checkAuthStatus(),
        ),
      ),
    );
  }
}
