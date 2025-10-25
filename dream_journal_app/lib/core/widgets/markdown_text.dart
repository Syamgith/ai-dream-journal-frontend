import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../constants/app_colors.dart';

class MarkdownText extends StatelessWidget {
  final String data;
  final double fontSize;
  final Color? textColor;
  final EdgeInsets padding;

  const MarkdownText({
    super.key,
    required this.data,
    this.fontSize = 15,
    this.textColor,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.white;

    // Use dark config as base and customize
    final config = MarkdownConfig.darkConfig.copy(
      configs: [
        // Paragraph styling
        PConfig(
          textStyle: TextStyle(
            fontSize: fontSize,
            height: 1.5,
            color: color,
          ),
        ),
        // Heading styles
        H1Config(
          style: TextStyle(
            fontSize: fontSize + 8,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.5,
          ),
        ),
        H2Config(
          style: TextStyle(
            fontSize: fontSize + 6,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.5,
          ),
        ),
        H3Config(
          style: TextStyle(
            fontSize: fontSize + 4,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.5,
          ),
        ),
        H4Config(
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.5,
          ),
        ),
        H5Config(
          style: TextStyle(
            fontSize: fontSize + 1,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.5,
          ),
        ),
        H6Config(
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.5,
          ),
        ),
        // Code styling
        CodeConfig(
          style: TextStyle(
            fontSize: fontSize - 1,
            backgroundColor: AppColors.darkBlue.withAlpha(128),
            color: AppColors.lightBlue,
          ),
        ),
        // Links
        LinkConfig(
          style: TextStyle(
            color: AppColors.primaryBlue,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: MarkdownWidget(
        data: data,
        shrinkWrap: true,
        selectable: true,
        config: config,
      ),
    );
  }
}
