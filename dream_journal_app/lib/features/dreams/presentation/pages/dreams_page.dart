import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' show Random;
import '../../../../core/constants/app_colors.dart';
import '../../providers/dreams_provider.dart';
import '../widgets/dream_card.dart';
//import '../widgets/dream_icon.dart';

class DreamsPage extends ConsumerWidget {
  const DreamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure the dreams provider is initialized when this page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dreamsProvider.notifier).initialize();
    });

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
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: _HoverText(
                              text: 'Add your first dream!',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/add-dream'),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(dreamsProvider.notifier)
                                .initialize();
                            return ref
                                .read(dreamsProvider.notifier)
                                .loadDreams(forceRefresh: true);
                          },
                          child: _DreamsList(dreams: dreams),
                        ),
            ),
            //SleepingIcon()
          ],
        ));
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

// A more subtle and elegant floating action button that matches the app theme
class _DreamFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _DreamFAB({required this.onPressed});

  @override
  State<_DreamFAB> createState() => _DreamFABState();
}

class _DreamFABState extends State<_DreamFAB>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
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
            scale: _isHovered ? 1.05 : _pulseAnimation.value,
            child: Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue.withAlpha(230),
                    AppColors.primaryBlue.withAlpha(153),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.primaryBlue.withAlpha(_isHovered ? 77 : 51),
                    blurRadius: _isHovered ? 12 : 8,
                    spreadRadius: _isHovered ? 1 : 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Colors.white24,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white.withAlpha(242),
                      size: 28,
                    ),
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkBlue,
                    AppColors.primaryBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(
                            0xFF8066CE) // AppColors.primaryBlue.withAlpha(128)
                        : const Color(
                            0xFF4D66CE), // AppColors.primaryBlue.withAlpha(77)
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
                  splashColor: const Color(0x3DFFFFFF), // Colors.white24
                  child: Stack(
                    children: [
                      // Star background
                      if (_isHovered)
                        const Positioned.fill(
                          child: CustomPaint(
                            painter: _StarryBackgroundPainter(),
                          ),
                        ),

                      // Moon icon
                      const Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Plus sign
                            Icon(
                              Icons.add,
                              color: Color(0xE6FFFFFF),
                              size: 30,
                            ),

                            // Small moon in the top-right corner
                            Positioned(
                              top: -4,
                              right: -4,
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(
                                            0xE6FFFFFF), // Colors.white.withAlpha(230)
                                        Color(
                                            0xFFB3B5C6), // AppColors.lightBlue.withAlpha(179)
                                      ],
                                      center: Alignment(0.3, -0.3),
                                      radius: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                            0x80FFFFFF), // Colors.white.withAlpha(128)
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                  0xB3FFFFFF), // Colors.white.withAlpha(179)
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                      0x80FFFFFF), // Colors.white.withAlpha(128)
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
  const _StarryBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(12); // Different seed from other stars
    final paint = Paint()
      ..color = const Color(0x66FFFFFF) // Colors.white.withAlpha(102)
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

// Add this new widget class at the end of the file
class _HoverText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HoverText({
    required this.text,
    required this.onTap,
  });

  @override
  State<_HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<_HoverText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: _isHovered
              ? const Color(0xFFFFFFFF)
              : const Color(0xB3FFFFFF), // Colors.white or Colors.white70
          fontSize: 16,
          letterSpacing: _isHovered ? 0.5 : 0,
          shadows: _isHovered
              ? const [
                  BoxShadow(
                    color: Color(0x26FFFFFF), // Colors.white.withAlpha(38)
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : const [],
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
