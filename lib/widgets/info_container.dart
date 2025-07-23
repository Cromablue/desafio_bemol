import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class InfoContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? iconSize;
  final double? fontSize;

  const InfoContainer({
    Key? key,
    required this.icon,
    required this.text,
    this.iconSize = 20,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
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
          SizedBox(width: 10),
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