import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';

class CompactExploringIndicator extends StatefulWidget {
  const CompactExploringIndicator({super.key});

  @override
  State<CompactExploringIndicator> createState() => _CompactExploringIndicatorState();
}

class _CompactExploringIndicatorState extends State<CompactExploringIndicator>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _moonController;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _moonController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _moonController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 80, top: 4, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                AnimatedBuilder(
                  animation: _starsController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _starsController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(24, 24),
                        painter: CompactStarsPainter(
                          color: AppColors.lightBlue.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),
                // Inner rotating moon
                AnimatedBuilder(
                  animation: _moonController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -_moonController.value * 2 * math.pi,
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.9),
                              AppColors.primaryBlue.withValues(alpha: 0.6),
                            ],
                            center: const Alignment(0.3, -0.3),
                            radius: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _dotsController,
            builder: (context, child) {
              final dots = _getDots(_dotsController.value);
              return Text(
                'Exploring$dots',
                style: TextStyle(
                  color: AppColors.lightBlue.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getDots(double value) {
    final progress = (value * 4).floor() % 4;
    switch (progress) {
      case 0:
        return '';
      case 1:
        return '.';
      case 2:
        return '..';
      case 3:
        return '...';
      default:
        return '';
    }
  }
}

// Compact version of the stars painter
class CompactStarsPainter extends CustomPainter {
  final Color color;

  CompactStarsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Paint for the stars
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw stars around the circle
    const int starCount = 8;
    const double innerRadius = 0.7;
    const double outerRadius = 1.0;

    final path = Path();

    for (int i = 0; i < starCount; i++) {
      final double angle = (i * 2 * math.pi / starCount);
      final double nextAngle = angle + (math.pi / starCount);

      final outerPoint = Offset(
          center.dx + radius * outerRadius * math.cos(angle),
          center.dy + radius * outerRadius * math.sin(angle));

      final innerPoint = Offset(
          center.dx + radius * innerRadius * math.cos(nextAngle),
          center.dy + radius * innerRadius * math.sin(nextAngle));

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }

      path.lineTo(innerPoint.dx, innerPoint.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CompactStarsPainter oldDelegate) => false;
}
