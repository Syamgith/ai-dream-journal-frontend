import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dream_entry.dart';
import '../pages/add_dream_page.dart';

class DreamCard extends StatelessWidget {
  final DreamEntry dream;

  const DreamCard({
    super.key,
    required this.dream,
  });

  String _formatDate() {
    return DateFormat('d\nMMM').format(dream.date).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue,
            AppColors.darkBlue.withAlpha(204),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDreamPage(dream: dream),
                ),
              );
            },
            splashColor: AppColors.primaryBlue.withAlpha(26),
            highlightColor: AppColors.primaryBlue.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date section with visual separator
                  Container(
                    width: 60,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: AppColors.primaryBlue.withAlpha(77),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatDate(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white.withAlpha(230),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dream.title,
                          style: TextStyle(
                            color: AppColors.white.withAlpha(242),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dream.description.length > 100
                              ? '${dream.description.substring(0, 100)}...'
                              : dream.description,
                          style: TextStyle(
                            color: AppColors.white.withAlpha(204),
                            fontSize: 16,
                            height: 1.4,
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
    );
  }
}
