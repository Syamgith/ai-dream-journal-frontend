import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ShimmerSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: [
                AppColors.darkBlue,
                AppColors.darkBlue.withValues(alpha: 0.7),
                AppColors.darkBlue,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Skeleton for dream card
class DreamCardSkeleton extends StatelessWidget {
  const DreamCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.darkBlue,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ShimmerSkeleton(
                    height: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const ShimmerSkeleton(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ShimmerSkeleton(
              width: 120,
              height: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

// Skeleton for analysis result
class AnalysisSkeleton extends StatelessWidget {
  const AnalysisSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkBlue,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerSkeleton(
              width: 150,
              height: 20,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ShimmerSkeleton(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            ShimmerSkeleton(
              width: 200,
              height: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
