import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class EcoLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const EcoLoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color = AppColors.primaryColor,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: strokeWidth,
      ),
    );
  }
} 