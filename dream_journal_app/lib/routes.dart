import 'package:flutter/material.dart';
import 'features/dreams/presentation/pages/add_dream_page.dart';
import 'features/dreams/presentation/pages/dreams_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/shared/screens/main_screen.dart';

class AppRoutes {
  static const String main = '/';
  static const String dreams = '/dreams';
  static const String profile = '/profile';
  static const String addDream = '/add-dream';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      main: (context) => const MainScreen(),
      dreams: (context) => const DreamsPage(),
      profile: (context) => const ProfilePage(),
      addDream: (context) => const AddDreamPage(), // Add this line
    };
  }
}
