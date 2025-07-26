import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 18,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}