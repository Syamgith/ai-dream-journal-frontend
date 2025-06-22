import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:math' show Random;
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dream_entry.dart';
import '../../providers/dreams_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/keyboard_dismissible.dart';
import '../../../../core/utils/keyboard_utils.dart';

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
  int? _interpretedDreamId;
  bool _hasBeenUpdated = false;

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
    return KeyboardDismissible(
      child: Scaffold(
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
                          onEditingComplete: () =>
                              _descriptionFocusNode.requestFocus(),
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () =>
                              KeyboardUtils.hideKeyboard(context),
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
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryBlue.withAlpha(77),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.white.withAlpha(179),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.dream != null &&
                          !_hasBeenUpdated &&
                          !_isLoading)
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 20),
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
                                        color:
                                            AppColors.lightBlue.withAlpha(200),
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
                                            AppColors.primaryBlue
                                                .withAlpha(180),
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
                        // Display the dream title if it's available
                        if (_titleController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _titleController.text,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(
                                  color: AppColors.primaryBlue,
                                  thickness: 0.5,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
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
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _showReportDialog(context),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withAlpha(77),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    color: AppColors.white.withAlpha(179),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Report',
                                    style: TextStyle(
                                      color: AppColors.white.withAlpha(179),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                if (widget.dream == null && !_isLoading)
                  Center(
                    child: _DreamSaveButton(
                      onTap: _interpretation != null
                          ? _navigateToHome
                          : _saveDream,
                      isHomeButton: _interpretation != null,
                    ),
                  ),
                if (widget.dream != null &&
                    _interpretation != null &&
                    !_isLoading)
                  Center(
                    child: _DreamSaveButton(
                      onTap: _navigateToHome,
                      isHomeButton: true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    KeyboardUtils.hideKeyboard(context);
    Navigator.pop(context);
  }

  void _showDatePicker() async {
    KeyboardUtils.hideKeyboard(context);
    final DateTime now = DateTime.now();
    final DateTime oneYearAgo = DateTime(now.year - 1, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: oneYearAgo,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              surface: AppColors.darkBlue,
              onSurface: AppColors.white,
            ),
            dialogTheme: const DialogTheme(
              backgroundColor: AppColors.background,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    }
  }

  void _saveDream() async {
    KeyboardUtils.hideKeyboard(context);

    if (_descriptionController.text.trim().isEmpty) {
      return;
    }

    // Add validation for minimum character length
    if (_descriptionController.text.trim().length < 10) {
      CustomSnackbar.show(
        context: context,
        message: 'Dream description is too short..',
        type: SnackBarType.error,
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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
        final interpretedDream =
            await ref.read(dreamsProvider.notifier).updateDream(dream);

        if (mounted) {
          setState(() {
            _interpretation = interpretedDream.interpretation;
            _interpretedDreamId = interpretedDream.id;
            // Update the title controller if API returned a title and user didn't provide one
            if (_titleController.text.trim().isEmpty &&
                interpretedDream.title != null) {
              _titleController.text = interpretedDream.title!;
            }
            _hasBeenUpdated = true;
          });
        }
        return;
      } else {
        final interpretedDream =
            await ref.read(dreamsProvider.notifier).addDream(dream);

        if (mounted) {
          setState(() {
            _interpretation = interpretedDream.interpretation;
            _interpretedDreamId = interpretedDream.id;
            // Update the title controller if API returned a title and user didn't provide one
            if (_titleController.text.trim().isEmpty &&
                interpretedDream.title != null) {
              _titleController.text = interpretedDream.title!;
            }
            _hasBeenUpdated = true;
          });
        }
        return; // Don't pop the page, show interpretation instead
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Error: ${e.toString()}',
          type: SnackBarType.error,
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

  void _showReportDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Report Dream',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for reporting this dream interpretation.',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLength: 200,
                maxLines: 3,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter reason (optional)',
                  hintStyle: TextStyle(
                    color: AppColors.white.withAlpha(128),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: TextStyle(
                    color: AppColors.white.withAlpha(128),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.white.withAlpha(179),
                ),
              ),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);
                      try {
                        final dreamId = widget.dream?.id ?? _interpretedDreamId;
                        if (dreamId != null) {
                          await ref.read(dreamsProvider.notifier).reportDream(
                                dreamId,
                                reason: reasonController.text.trim(),
                              );
                          if (context.mounted) {
                            CustomSnackbar.show(
                              context: context,
                              message: 'Dream reported successfully',
                              type: SnackBarType.success,
                            );
                            Navigator.of(dialogContext).pop();
                          }
                        } else {
                          throw Exception('Dream ID not available');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          CustomSnackbar.show(
                            context: context,
                            message: 'Error reporting dream: ${e.toString()}',
                            type: SnackBarType.error,
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white.withAlpha(179),
                        ),
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                        color: AppColors.white.withAlpha(179),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
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
          Colors.white.withAlpha(204), // 0.8 * 255 ≈ 204
          color.withAlpha(0), // 0.0 * 255 = 0
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.6));

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(DreamStarsPainter oldDelegate) => false;
}

// Custom Dream Save Button with animation effects
class _DreamSaveButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isHomeButton;

  const _DreamSaveButton({
    required this.onTap,
    required this.isHomeButton,
  });

  @override
  State<_DreamSaveButton> createState() => _DreamSaveButtonState();
}

class _DreamSaveButtonState extends State<_DreamSaveButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
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
        duration: const Duration(milliseconds: 200),
        width: 160, // Slightly smaller width
        height: 42, // Slightly smaller height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isHomeButton
                ? [
                    AppColors.primaryBlue.withAlpha(_isHovered ? 230 : 179),
                    AppColors.lightBlue.withAlpha(_isHovered ? 230 : 179),
                  ]
                : [
                    const Color(0xFF2C3E50).withAlpha(_isHovered ? 242 : 217),
                    AppColors.primaryBlue.withAlpha(_isHovered ? 242 : 217),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(_isHovered ? 102 : 51),
              blurRadius: _isHovered ? 12 : 8,
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(21),
            splashColor: Colors.white24,
            child: Stack(
              children: [
                // Shimmer effect
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withAlpha(204), // 0.8 * 255 ≈ 204
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
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Content
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Moon icon for save, home icon for navigate home
                      Icon(
                        widget.isHomeButton
                            ? Icons.home_rounded
                            : Icons.nightlight_round,
                        color:
                            AppColors.white.withAlpha(230), // 0.9 * 255 = 230
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isHomeButton ? 'Home' : 'Save Dream',
                        style: TextStyle(
                          color:
                              AppColors.white.withAlpha(230), // 0.9 * 255 = 230
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Stars effect (visible on hover)
                if (_isHovered)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: CustomPaint(
                        painter: _StarsPainter(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter to draw small stars in the button background
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(42); // Fixed seed for consistent star pattern
    final paint = Paint()
      ..color = Colors.white.withAlpha(128) // 0.5 * 255 = 128
      ..style = PaintingStyle.fill;

    // Draw tiny stars
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 1.5 + 0.5;

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}
