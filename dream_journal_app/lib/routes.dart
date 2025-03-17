import 'package:flutter/material.dart';
import 'features/dreams/presentation/pages/add_dream_page.dart';
import 'features/dreams/presentation/pages/dreams_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/feedback/presentation/pages/feedback_page.dart';
import 'features/about/presentation/pages/about_page.dart';

class AppRoutes {
  static const String main = '/';
  static const String dreams = '/dreams';
  static const String profile = '/profile';
  static const String addDream = '/add-dream';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String feedback = '/feedback';
  static const String about = '/about';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      main: (context) => const AuthWrapper(),
      dreams: (context) => const DreamsPage(),
      profile: (context) => const ProfilePage(),
      addDream: (context) => const AddDreamPage(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      feedback: (context) => const FeedbackPage(),
      about: (context) => const AboutPage(),
    };
  }
}
