import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class _DreamCardState extends State<DreamCard> {
  bool _isHovered = false;

  String _formatDayNumber() {
    return DateFormat('d').format(widget.dream.timestamp);
  }

  String _formatMonth() {
    return DateFormat('MMM').format(widget.dream.timestamp).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 140),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _isHovered
              ? AppColors.darkBlue.withOpacity(0.9)
              : AppColors.darkBlue.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primaryBlue.withOpacity(0.2)
                  : Colors.black.withAlpha(40),
              blurRadius: _isHovered ? 10 : 8,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DreamDetailsPage(dream: widget.dream),
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
                            color: AppColors.primaryBlue.withAlpha(80),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Day number
                          Text(
                            _formatDayNumber(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white.withAlpha(230),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Month
                          Text(
                            _formatMonth(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white.withAlpha(230),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
                          Text(
                            widget.dream.title ?? 'Untitled Dream',
                            style: TextStyle(
                              color: AppColors.white.withAlpha(230),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              widget.dream.description.length > 100
                                  ? '${widget.dream.description.substring(0, 100)}...'
                                  : widget.dream.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.white.withAlpha(200),
                                fontSize: 16,
                                height: 1.4,
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
      ),
    );
  }
}
