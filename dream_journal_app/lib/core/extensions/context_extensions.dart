import 'package:flutter/material.dart';
import '../utils/keyboard_utils.dart';

/// Extensions on BuildContext to provide easier access to common functionality
extension BuildContextExtensions on BuildContext {
  /// Hides the keyboard
  void hideKeyboard() => KeyboardUtils.hideKeyboard(this);

  /// Executes the callback after hiding the keyboard
  void hideKeyboardThen(VoidCallback callback) =>
      KeyboardUtils.hideKeyboardThen(this, callback);

  /// Media queries shortcuts
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  bool get isKeyboardVisible => viewInsets.bottom > 0;
}
