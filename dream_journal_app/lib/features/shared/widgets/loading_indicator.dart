import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                message!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
