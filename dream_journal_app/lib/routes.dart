import 'package:flutter/material.dart';
import 'features/dreams/presentation/pages/add_dream_page.dart';
import 'features/dreams/presentation/pages/dreams_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/feedback/presentation/pages/feedback_page.dart';
import 'features/about/presentation/pages/about_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/shared/screens/main_screen.dart';
import 'features/dream_explorer/presentation/pages/dream_explorer_page.dart';

class AppRoutes {
  static const String main = '/';
  static const String home = '/home';
  static const String dreams = '/dreams';
  static const String profile = '/profile';
  static const String addDream = '/add-dream';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String feedback = '/feedback';
  static const String about = '/about';
  static const String settings = '/settings';
  static const String dreamExplorer = '/dream-explorer';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      main: (context) => const AuthWrapper(),
      home: (context) => const MainScreen(),
      dreams: (context) => const DreamsPage(),
      profile: (context) => const ProfilePage(),
      addDream: (context) => const AddDreamPage(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      feedback: (context) => const FeedbackPage(),
      about: (context) => const AboutPage(),
      settings: (context) => const SettingsPage(),
    };
  }

  // Custom route generator for special transitions
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Dream Explorer with slide-up transition
    if (settings.name == dreamExplorer) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DreamExplorerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // Start from bottom
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
    }

    // Default route handling
    final routes = getRoutes();
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: (context) => builder(context),
        settings: settings,
      );
    }

    return null;
  }
}
