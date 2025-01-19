import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class DreamCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date; // New parameter

  const DreamCard({
    required this.title,
    required this.description,
    required this.date, // Add required date
    super.key,
  });

  String _formatDate() {
    // return "${date.day}\n${_getMonthName(date.month)}";
    String formattedDate = DateFormat('d MMM').format(date).toUpperCase();
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date section
            SizedBox(
              width: 120,
              child: Text(
                _formatDate(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description.length > 100
                        ? '${description.substring(0, 100)}...'
                        : description,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
