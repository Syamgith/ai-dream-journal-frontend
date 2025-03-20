import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dream_entry.dart';
import '../../providers/dreams_provider.dart';

class AddDreamPage extends ConsumerStatefulWidget {
  final DreamEntry? dream;
  const AddDreamPage({super.key, this.dream});

  @override
  ConsumerState<AddDreamPage> createState() => _AddDreamPageState();
}

class _AddDreamPageState extends ConsumerState<AddDreamPage>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  late DateTime _selectedDate;
  String? _interpretation;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _starsController;
  late AnimationController _moonController;

  @override
  void initState() {
    super.initState();
    if (widget.dream != null) {
      _titleController.text = widget.dream!.title ?? '';
      _descriptionController.text = widget.dream!.description;
      _selectedDate = widget.dream!.timestamp;
      _interpretation = widget.dream!.interpretation;
    } else {
      _selectedDate = DateTime.now();
    }

    // Initialize animation controllers
    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _moonController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _starsController.dispose();
    _moonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.dream != null ? 'Edit Dream' : 'Add Dream',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryBlue.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        maxLength: 30,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                        decoration: InputDecoration(
                          labelText: null,
                          hintText: 'Give your dream a title...(optional)',
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterText: '',
                          hintStyle: TextStyle(
                            color: AppColors.white.withAlpha(128),
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(14, 8, 14, 8),
                          prefixIcon: Icon(
                            Icons.edit_outlined,
                            color: AppColors.white.withAlpha(128),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryBlue.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Write about your dream experience...',
                          hintStyle: TextStyle(
                            color: AppColors.white.withAlpha(128),
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12),
                            child: Icon(
                              Icons.auto_stories_outlined,
                              color: AppColors.white.withAlpha(128),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.white.withAlpha(179),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate),
                          style: TextStyle(
                            color: AppColors.white.withAlpha(230),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.dream != null) const Spacer(),
                        if (widget.dream != null)
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.lightBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _saveDream,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Text(
                                'Update Dream',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
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
                                      color: AppColors.lightBlue.withAlpha(200),
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
                                          Colors.white.withAlpha(240),
                                          AppColors.primaryBlue.withAlpha(180),
                                        ],
                                        center: const Alignment(0.3, -0.3),
                                        radius: 0.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withAlpha(150),
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
                      const SizedBox(height: 20),
                      const Text(
                        "Breaking down your dream...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              if (_interpretation != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dream Exploration',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _interpretation!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (widget.dream == null)
                Center(
                  child: Container(
                    height: 46,
                    width: 180,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.lightBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withAlpha(77),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _interpretation != null
                          ? _navigateToHome
                          : _saveDream,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_interpretation != null)
                            const Icon(
                              Icons.home,
                              color: AppColors.white,
                              size: 18,
                            ),
                          if (_interpretation != null) const SizedBox(width: 8),
                          Text(
                            _interpretation != null ? 'Home' : 'Save Dream',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_interpretation == null) const SizedBox(width: 8),
                          if (_interpretation == null)
                            const Icon(
                              Icons.edit_note,
                              color: AppColors.white,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pop(context);
  }

  void _saveDream() async {
    if (_descriptionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dream = DreamEntry(
        id: widget.dream?.id,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        description: _descriptionController.text.trim(),
        timestamp: _selectedDate,
        interpretation: widget.dream?.interpretation,
      );

      if (widget.dream != null) {
        await ref.read(dreamsProvider.notifier).updateDream(dream);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        final interpretedDream =
            await ref.read(dreamsProvider.notifier).addDream(dream);

        if (mounted) {
          setState(() {
            _interpretation = interpretedDream.interpretation;
          });
        }
        return; // Don't pop the page, show interpretation instead
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          Colors.white.withOpacity(0.8),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.6));

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(DreamStarsPainter oldDelegate) => false;
}
