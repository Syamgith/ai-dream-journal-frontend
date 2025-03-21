import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/error_formatter.dart';

class ErrorMessageDisplay extends StatelessWidget {
  final String message;
  final bool compact;
  final EdgeInsets padding;
  final bool formatMessage;

  const ErrorMessageDisplay({
    Key? key,
    required this.message,
    this.compact = false,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    this.formatMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayMessage =
        formatMessage ? ErrorFormatter.format(message) : message;

    return Padding(
      padding: padding,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 10.0 : 12.0,
          horizontal: compact ? 14.0 : 16.0,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.darkBlue,
              AppColors.primaryBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(compact ? 0.3 : 0.4),
              blurRadius: compact ? 6 : 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              Icons.cloud_outlined,
              color: AppColors.white,
              size: compact ? 18 : 20,
            ),
            SizedBox(width: compact ? 10 : 12),
            Flexible(
              child: Text(
                displayMessage,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: compact ? 14 : 16,
                ),
                textAlign: compact ? TextAlign.center : TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
