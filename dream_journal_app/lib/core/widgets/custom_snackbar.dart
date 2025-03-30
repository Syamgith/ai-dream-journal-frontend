import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: _CustomSnackbarContent(
        message: message,
        type: type,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

enum SnackBarType { success, error, info }

class _CustomSnackbarContent extends StatefulWidget {
  final String message;
  final SnackBarType type;

  const _CustomSnackbarContent({
    required this.message,
    required this.type,
  });

  @override
  State<_CustomSnackbarContent> createState() => _CustomSnackbarContentState();
}

class _CustomSnackbarContentState extends State<_CustomSnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: _getGradientColors(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _getShadowColor()
                    .withAlpha((_glowAnimation.value * 255).toInt()),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _getIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getIcon() {
    final IconData iconData;
    switch (widget.type) {
      case SnackBarType.success:
        iconData = Icons.star_outline;
        break;
      case SnackBarType.error:
        iconData = Icons.nightlight_outlined;
        break;
      case SnackBarType.info:
        iconData = Icons.wb_twilight_outlined;
        break;
    }

    return Icon(
      iconData,
      color: AppColors.white,
      size: 24,
    );
  }

  List<Color> _getGradientColors() {
    switch (widget.type) {
      case SnackBarType.success:
        return [
          const Color(0xFF6A67CE), // Purple
          const Color(0xFF93B5C6), // Light Blue-Gray
        ];
      case SnackBarType.error:
        return [
          const Color(0xFFE86A92), // Pink
          const Color(0xFFA641A6), // Purple
        ];
      case SnackBarType.info:
        return [
          AppColors.primaryBlue,
          AppColors.lightBlue,
        ];
    }
  }

  Color _getShadowColor() {
    switch (widget.type) {
      case SnackBarType.success:
        return const Color(0xFF6A67CE);
      case SnackBarType.error:
        return const Color(0xFFE86A92);
      case SnackBarType.info:
        return AppColors.primaryBlue;
    }
  }
}
