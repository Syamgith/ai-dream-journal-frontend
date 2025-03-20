import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' show Random;
import '../../../../core/constants/app_colors.dart';
import '../../providers/dreams_provider.dart';
import '../widgets/dream_card.dart';
import 'package:flutter/foundation.dart';
import '../pages/add_dream_page.dart';
//import '../widgets/dream_icon.dart';

class DreamsPage extends ConsumerWidget {
  const DreamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreams = ref.watch(dreamsProvider);
    final isLoading = ref.watch(dreamsLoadingProvider);
    final hasInitialLoad = ref.watch(dreamsInitialLoadProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(20),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'December',
          //         style: AppTextStyles.monthTitle,
          //       ),
          //       Row(
          //         children: [
          //           Text(
          //             '10',
          //             style: AppTextStyles.dayNumber,
          //           ),
          //           const SizedBox(width: 8),
          //           Text(
          //             'Tue',
          //             style: AppTextStyles.dayText,
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: isLoading && !hasInitialLoad
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : dreams.isEmpty
                    ? Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/add-dream'),
                          child: const Text(
                            'Add your first dream!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(dreamsProvider.notifier)
                            .loadDreams(forceRefresh: true),
                        child: _DreamsList(dreams: dreams),
                      ),
          ),
          //SleepingIcon()
        ],
      ),
    );
  }
}

// A separate widget for the dreams list to optimize rebuilds
class _DreamsList extends StatelessWidget {
  final List<dynamic> dreams;

  const _DreamsList({required this.dreams});

  @override
  Widget build(BuildContext context) {
    // Sort dreams by timestamp in descending order (newest first)
    final sortedDreams = List.from(dreams)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sortedDreams.length,
      itemBuilder: (context, index) {
        final dream = sortedDreams[index];
        return KeyedSubtree(
          // Use the dream ID as a key to maintain widget identity
          key: ValueKey(
              dream.id ?? 'dream-${dream.timestamp.millisecondsSinceEpoch}'),
          child: DreamCard(dream: dream),
        );
      },
    );
  }
}

// Custom animated Add Dream button with dreamlike effects
class _AddDreamButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddDreamButton({required this.onPressed});

  @override
  State<_AddDreamButton> createState() => _AddDreamButtonState();
}

class _AddDreamButtonState extends State<_AddDreamButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isHovered ? 1.1 : _pulseAnimation.value,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkBlue,
                    AppColors.primaryBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue
                        .withOpacity(_isHovered ? 0.5 : 0.3),
                    blurRadius: _isHovered ? 16 : 10,
                    spreadRadius: _isHovered ? 2 : 1,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Colors.white24,
                  child: Stack(
                    children: [
                      // Star background
                      if (_isHovered)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StarryBackgroundPainter(),
                          ),
                        ),

                      // Moon icon
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Plus sign
                            Icon(
                              Icons.add,
                              color: Colors.white.withOpacity(0.9),
                              size: 30,
                            ),

                            // Small moon in the top-right corner
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.9),
                                      AppColors.lightBlue.withOpacity(0.7),
                                    ],
                                    center: const Alignment(0.3, -0.3),
                                    radius: 0.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Shine effect (when hovered)
                      if (_isHovered)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.7),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for the starry background in the add button
class _StarryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(12); // Different seed from other stars
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw tiny stars
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 1.0 + 0.5;

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(_StarryBackgroundPainter oldDelegate) => false;
}
