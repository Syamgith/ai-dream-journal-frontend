import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' show Random;
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dream_entry.dart';
import '../pages/dream_details_page.dart';

class DreamCard extends StatefulWidget {
  final DreamEntry dream;

  const DreamCard({
    super.key,
    required this.dream,
  });

  @override
  State<DreamCard> createState() => _DreamCardState();
}

class _DreamCardState extends State<DreamCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  String _formatDate() {
    return DateFormat('d\nMMM').format(widget.dream.timestamp).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _isHovered
                  ? AppColors.primaryBlue.withOpacity(0.3)
                  : AppColors.darkBlue,
              _isHovered
                  ? AppColors.darkBlue.withOpacity(0.9)
                  : AppColors.darkBlue.withAlpha(204),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primaryBlue.withOpacity(0.3)
                  : Colors.black.withAlpha(51),
              blurRadius: _isHovered ? 15 : 10,
              spreadRadius: _isHovered ? 1 : 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -3))
            : Matrix4.identity(),
        child: Stack(
          children: [
            // Shimmer effect (only visible on hover)
            if (_isHovered)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Opacity(
                        opacity: 0.1,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment(_shimmerAnimation.value - 1, 0),
                              end: Alignment(_shimmerAnimation.value, 0),
                            ).createShader(bounds);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Stars background effect (only visible on hover)
            if (_isHovered)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    painter: _StarsPainter(),
                  ),
                ),
              ),

            // Main content
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DreamDetailsPage(dream: widget.dream),
                      ),
                    );
                  },
                  splashColor: AppColors.primaryBlue.withAlpha(40),
                  highlightColor: AppColors.primaryBlue.withAlpha(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date section with visual separator
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: _isHovered
                                    ? AppColors.primaryBlue.withAlpha(125)
                                    : AppColors.primaryBlue.withAlpha(77),
                                width: _isHovered ? 2.5 : 2,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: _isHovered
                                      ? AppColors.white.withAlpha(255)
                                      : AppColors.white.withAlpha(230),
                                  fontSize: _isHovered ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                child: Text(
                                  _formatDate(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Content section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: _isHovered
                                      ? AppColors.white
                                      : AppColors.white.withAlpha(242),
                                  fontSize: _isHovered ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                child: Text(
                                  widget.dream.title ?? 'Untitled Dream',
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: _isHovered
                                      ? AppColors.white.withAlpha(230)
                                      : AppColors.white.withAlpha(204),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                                child: Text(
                                  widget.dream.description.length > 100
                                      ? '${widget.dream.description.substring(0, 100)}...'
                                      : widget.dream.description,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Moon icon indicator (only visible on hover)
            if (_isHovered)
              Positioned(
                right: 15,
                bottom: 15,
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        AppColors.primaryBlue.withOpacity(0.7),
                      ],
                      center: const Alignment(0.3, -0.3),
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw small stars in the card background
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(42); // Fixed seed for consistent star pattern
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw tiny stars
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 1.2 + 0.4;

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}
