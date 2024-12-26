import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SleepingIcon extends StatelessWidget {
  const SleepingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF34495E),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              child: const Icon(
                Icons.nightlight,
                color: AppColors.white,
                size: 30,
              ),
            ),
          ),
          Center(
              // child: CustomPaint(
              //   size: const Size(150, 100),
              //   painter: SleepingFacePainter(),
              // ),
              ),
        ],
      ),
    );
  }
}
