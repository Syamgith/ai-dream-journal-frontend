import 'package:flutter/material.dart';

/// Utility class to help with keyboard operations throughout the app
class KeyboardUtils {
  /// Hides the keyboard by removing focus from the currently focused widget
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Hides the keyboard and then executes the provided callback
  static void hideKeyboardThen(BuildContext context, VoidCallback callback) {
    hideKeyboard(context);
    callback();
  }
}
