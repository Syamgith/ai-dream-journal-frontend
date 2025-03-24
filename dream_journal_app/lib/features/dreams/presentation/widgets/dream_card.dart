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

  String _formatDayNumber() {
    return DateFormat('d').format(widget.dream.timestamp);
  }

  String _formatMonth() {
    return DateFormat('MMM').format(widget.dream.timestamp).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 4),
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
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 140),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _isHovered
                  ? AppColors.darkBlue.withOpacity(0.8)
                  : AppColors.darkBlue,
              _isHovered
                  ? AppColors.primaryBlue.withOpacity(0.15)
                  : AppColors.darkBlue.withAlpha(204),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primaryBlue.withOpacity(0.2)
                  : Colors.black.withAlpha(40),
              blurRadius: _isHovered ? 12 : 8,
              spreadRadius: _isHovered ? 0.5 : 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryBlue.withOpacity(0.3)
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -2))
            : Matrix4.identity(),
        child: Stack(
          children: [
            // Subtle edge glow (only visible on hover)
            if (_isHovered)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Opacity(
                        opacity: 0.07,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primaryBlue.withOpacity(0.7),
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

            // Very subtle stars background effect (only visible on hover)
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
                                    ? AppColors.primaryBlue.withAlpha(100)
                                    : AppColors.primaryBlue.withAlpha(77),
                                width: _isHovered ? 2 : 1.5,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Day number
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: _isHovered
                                      ? AppColors.white.withAlpha(240)
                                      : AppColors.white.withAlpha(215),
                                  fontSize: _isHovered ? 20 : 19,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Text(
                                  _formatDayNumber(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Month
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: _isHovered
                                      ? AppColors.white.withAlpha(240)
                                      : AppColors.white.withAlpha(215),
                                  fontSize: _isHovered ? 16 : 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Text(
                                  _formatMonth(),
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: _isHovered
                                      ? AppColors.white.withAlpha(240)
                                      : AppColors.white.withAlpha(220),
                                  fontSize: _isHovered ? 21 : 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                child: Text(
                                  widget.dream.title ?? 'Untitled Dream',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    color: _isHovered
                                        ? AppColors.white.withAlpha(215)
                                        : AppColors.white.withAlpha(190),
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                  child: Text(
                                    widget.dream.description.length > 100
                                        ? '${widget.dream.description.substring(0, 100)}...'
                                        : widget.dream.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw small stars in the card background - now more subtle
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(42); // Fixed seed for consistent star pattern
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Draw fewer, more subtle stars
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 0.8 + 0.3;

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}
