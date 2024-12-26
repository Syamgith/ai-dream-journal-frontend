import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes.dart';
import '../../dreams/presentation/pages/dreams_page.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

// lib/features/shared/widgets/bottom_nav_bar.dart
// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const BottomNavBar({
//     required this.currentIndex,
//     required this.onTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       color: AppColors.background,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextButton.icon(
//             onPressed: () => onTap(0),
//             icon: Icon(
//               Icons.menu,
//               color:
//                   currentIndex == 0 ? AppColors.primaryBlue : AppColors.white,
//             ),
//             label: Text(
//               'Dreams',
//               style: TextStyle(
//                 color:
//                     currentIndex == 0 ? AppColors.primaryBlue : AppColors.white,
//               ),
//             ),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               Navigator.pushNamed(context, AppRoutes.addDream);
//             },
//             backgroundColor: AppColors.primaryBlue,
//             child: const Icon(Icons.add),
//           ),
//           TextButton.icon(
//             onPressed: () => onTap(1),
//             icon: Icon(
//               Icons.person,
//               color:
//                   currentIndex == 1 ? AppColors.primaryBlue : AppColors.white,
//             ),
//             label: Text(
//               'Profile',
//               style: TextStyle(
//                 color:
//                     currentIndex == 1 ? AppColors.primaryBlue : AppColors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
