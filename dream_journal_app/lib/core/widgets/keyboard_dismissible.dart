import 'package:flutter/material.dart';
import '../utils/keyboard_utils.dart';

/// A widget that dismisses the keyboard when tapped outside of any input field
class KeyboardDismissible extends StatelessWidget {
  final Widget child;
  final bool excludeFromSemantics;

  const KeyboardDismissible({
    Key? key,
    required this.child,
    this.excludeFromSemantics = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => KeyboardUtils.hideKeyboard(context),
      excludeFromSemantics: excludeFromSemantics,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
