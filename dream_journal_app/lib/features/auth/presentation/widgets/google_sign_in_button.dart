import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : _getGoogleIcon(),
        label: Text(
          'Sign in with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _getGoogleIcon() {
    try {
      // Try to load the image
      return Image.asset(
        'assets/images/google_logo.png',
        height: 24.0,
        errorBuilder: (context, error, stackTrace) {
          // If there's an error loading the image, show a Google "G" icon
          return const Icon(
            Icons.g_mobiledata,
            size: 24.0,
            color: Colors.red,
          );
        },
      );
    } catch (e) {
      // Fallback if there's an exception
      return const Icon(
        Icons.g_mobiledata,
        size: 24.0,
        color: Colors.red,
      );
    }
  }
}
