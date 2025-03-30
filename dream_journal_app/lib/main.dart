import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/themes/app_theme.dart';
import 'core/widgets/keyboard_dismissible.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: MaterialApp(
        title: 'Dreami Diary',
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.main,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
