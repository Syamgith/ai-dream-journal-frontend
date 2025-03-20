import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => onTap(0),
            icon: Icon(
              Icons.menu,
              color:
                  currentIndex == 0 ? AppColors.primaryBlue : AppColors.white,
            ),
            label: Text(
              'Dreams',
              style: TextStyle(
                color:
                    currentIndex == 0 ? AppColors.primaryBlue : AppColors.white,
              ),
            ),
          ),
          _AddDreamButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addDream);
            },
          ),
          TextButton.icon(
            onPressed: () => onTap(1),
            icon: Icon(
              Icons.person,
              color:
                  currentIndex == 1 ? AppColors.primaryBlue : AppColors.white,
            ),
            label: Text(
              'Profile',
              style: TextStyle(
                color:
                    currentIndex == 1 ? AppColors.primaryBlue : AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            scale: _isHovered ? 1.15 : _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue
                        .withOpacity(_isHovered ? 0.7 : 0.45),
                    blurRadius: _isHovered ? 20 : 15,
                    spreadRadius: _isHovered ? 3 : 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  customBorder: const CircleBorder(),
                  child: Ink(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00B0FF), // Bright electric blue
                      border: Border.all(
                        color: Colors.white.withOpacity(_isHovered ? 0.6 : 0.3),
                        width: 2,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_isHovered ? 12 : 14),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isHovered
                            ? Image.asset(
                                'assets/images/add_dream_icon.png',
                                key: const ValueKey('hovered'),
                                color: Colors.white,
                                // Fallback to a beautiful icon if the asset doesn't exist
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              )
                            : const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 28,
                                key: ValueKey('default'),
                              ),
                      ),
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
