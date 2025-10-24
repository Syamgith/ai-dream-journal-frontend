import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';

class ExploringIndicator extends StatefulWidget {
  final String? message;

  const ExploringIndicator({
    super.key,
    this.message,
  });

  @override
  State<ExploringIndicator> createState() => _ExploringIndicatorState();
}

class _ExploringIndicatorState extends State<ExploringIndicator>
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            width: 60,
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
                        size: const Size(60, 60),
                        painter: DreamStarsPainter(
                          color: AppColors.lightBlue.withValues(alpha: 0.8),
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
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.94),
                              AppColors.primaryBlue.withValues(alpha: 0.7),
                            ],
                            center: const Alignment(0.3, -0.3),
                            radius: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
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
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _dotsController,
            builder: (context, child) {
              final dots = _getDots(_dotsController.value);
              return Text(
                '${widget.message ?? "Exploring"}$dots',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
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

// Custom painter for the stars animation
class DreamStarsPainter extends CustomPainter {
  final Color color;

  DreamStarsPainter({required this.color});

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

    // Draw a center circle with a gradient
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.6));

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(DreamStarsPainter oldDelegate) => false;
}
