import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes.dart';

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
//             onPressed: () {
//               onTap(0);
//               Navigator.pushReplacementNamed(context, AppRoutes.dreams);
//             },
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
//             onPressed: () {
//               onTap(1);
//               Navigator.pushReplacementNamed(context, AppRoutes.profile);
//             },
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

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => onTap(0),
            icon: Icon(
              Icons.menu,
              color:
                  currentIndex == 0 ? AppColors.primaryBlue : AppColors.white,
            ),
            label: Text(
              'Dreams',
              style: TextStyle(
                color:
                    currentIndex == 0 ? AppColors.primaryBlue : AppColors.white,
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addDream);
            },
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add),
          ),
          TextButton.icon(
            onPressed: () => onTap(1),
            icon: Icon(
              Icons.person,
              color:
                  currentIndex == 1 ? AppColors.primaryBlue : AppColors.white,
            ),
            label: Text(
              'Profile',
              style: TextStyle(
                color:
                    currentIndex == 1 ? AppColors.primaryBlue : AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
