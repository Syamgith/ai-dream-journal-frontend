import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/keyboard_dismissible.dart';
import '../../../core/utils/keyboard_utils.dart';
import '../../dreams/presentation/pages/dreams_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../../dreams/providers/dreams_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Refresh dreams data when the main screen is loaded, but only if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDreamsData();
    });
  }

  Future<void> _refreshDreamsData() async {
    try {
      // First initialize the dreams provider
      await ref.read(dreamsProvider.notifier).initialize();

      // Then force refresh dreams data when manually refreshing
      await ref.read(dreamsProvider.notifier).loadDreams(forceRefresh: true);
    } catch (e) {
      // Log the error but don't show it to the user
      debugPrint('Error refreshing dreams data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Dreams'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              KeyboardUtils.hideKeyboard(context);
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  KeyboardUtils.hideKeyboardThen(context, _refreshDreamsData),
              tooltip: 'Refresh Dreams',
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: const DreamsPage(),
        bottomNavigationBar: BottomNavBar(
          currentIndex: 0,
          onTap: (index) {
            KeyboardUtils.hideKeyboard(context);
            // Index is always 0 since we only have Dreams page here
          },
        ),
      ),
    );
  }
}
