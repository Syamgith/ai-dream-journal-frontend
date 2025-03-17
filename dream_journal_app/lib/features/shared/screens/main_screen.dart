import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../dreams/presentation/pages/dreams_page.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../../dreams/providers/dreams_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of page titles corresponding to the pages in the IndexedStack
  final List<String> _pageTitles = const ['Dreams', 'Profile'];

  @override
  void initState() {
    super.initState();
    // Refresh dreams data when the main screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDreamsData();
    });
  }

  Future<void> _refreshDreamsData() async {
    try {
      await ref.read(dreamsProvider.notifier).loadDreams();
    } catch (e) {
      // Log the error but don't show it to the user
      print('Error refreshing dreams data: $e');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(_pageTitles[_currentIndex]),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          if (_currentIndex == 0) // Only show refresh button on Dreams page
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDreamsData,
              tooltip: 'Refresh Dreams',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DreamsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
