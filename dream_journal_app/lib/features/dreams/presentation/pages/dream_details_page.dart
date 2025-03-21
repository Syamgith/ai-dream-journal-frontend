import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/dream_entry.dart';
import '../../providers/dreams_provider.dart';
import 'add_dream_page.dart';

class DreamDetailsPage extends ConsumerWidget {
  final DreamEntry dream;

  const DreamDetailsPage({
    super.key,
    required this.dream,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Dream Details',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          // Delete action moved to the right side of the app bar
          _AnimatedActionIcon(
            icon: Icons.delete_outline,
            activeIcon: Icons.delete,
            tooltip: 'Delete Dream',
            onTap: () {
              _showDeleteConfirmationDialog(context, ref);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date display
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.white.withAlpha(179),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(dream.timestamp),
                    style: TextStyle(
                      color: AppColors.white.withAlpha(230),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dream content
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
                    // Title
                    Text(
                      dream.title ?? 'Untitled Dream',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      dream.description,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Interpretation section if available
              if (dream.interpretation != null) ...[
                const SizedBox(height: 24),
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
                        dream.interpretation!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(
                  height:
                      40), // Reduced extra space at the bottom for the smaller floating action bar
            ],
          ),
        ),
      ),
      // Floating edit button at the bottom of the screen
      floatingActionButton: _DreamEditButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDreamPage(dream: dream),
            ),
          ).then((_) {
            // Refresh the dream when coming back from edit page
            if (dream.id != null) {
              ref.read(dreamsProvider.notifier).refreshDream(dream.id!);
              // Pop back to the dreams list after refreshing
              Navigator.pop(context);
            }
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Dream',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this dream?',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                try {
                  await ref.read(dreamsProvider.notifier).deleteDream(dream.id);
                  if (context.mounted) {
                    // Show success message with custom snackbar
                    CustomSnackbar.show(
                      context: context,
                      message: 'Dream deleted successfully',
                      type: SnackBarType.success,
                    );
                    // Go back to dreams list
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    // Show error message with custom snackbar
                    CustomSnackbar.show(
                      context: context,
                      message: 'Error deleting dream: ${e.toString()}',
                      type: SnackBarType.error,
                    );
                  }
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Animated Icon button for app bar actions
class _AnimatedActionIcon extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final VoidCallback onTap;

  const _AnimatedActionIcon({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_AnimatedActionIcon> createState() => _AnimatedActionIconState();
}

class _AnimatedActionIconState extends State<_AnimatedActionIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.reverse();
        });
      },
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _isHovered ? Colors.red.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedCrossFade(
                firstChild: Icon(
                  widget.icon,
                  color: _isHovered ? Colors.red : AppColors.white,
                  size: 24,
                ),
                secondChild: Icon(
                  widget.activeIcon,
                  color: Colors.red,
                  size: 24,
                ),
                crossFadeState: _isHovered
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Floating edit button with creative design
class _DreamEditButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DreamEditButton({
    required this.onTap,
  });

  @override
  State<_DreamEditButton> createState() => _DreamEditButtonState();
}

class _DreamEditButtonState extends State<_DreamEditButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 170,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkBlue.withOpacity(_isHovered ? 0.9 : 0.7),
              AppColors.primaryBlue.withOpacity(_isHovered ? 0.9 : 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(_isHovered ? 0.6 : 0.2),
              blurRadius: _isHovered ? 16 : 8,
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: Colors.white24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: AppColors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Edit Dream',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
