import 'package:flutter/material.dart';

class RelevanceScoreIndicator extends StatelessWidget {
  final double score;

  const RelevanceScoreIndicator({
    super.key,
    required this.score,
  });

  Color _getScoreColor() {
    if (score >= 0.7) {
      return Colors.green;
    } else if (score >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).toInt();
    final color = _getScoreColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
