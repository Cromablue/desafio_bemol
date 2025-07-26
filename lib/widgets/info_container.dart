import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class InfoContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? iconSize;
  final double? fontSize;

  const InfoContainer({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 20,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.white70,
            size: iconSize,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: AppColors.white70,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}