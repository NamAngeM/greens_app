import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final double elevation;
  final Color? backgroundColor;
  final bool centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.elevation = 0,
    this.backgroundColor,
    this.centerTitle = true,
    this.leading,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      elevation: elevation,
      leading: leading ?? (showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => bottom == null 
      ? const Size.fromHeight(kToolbarHeight)
      : Size.fromHeight(kToolbarHeight + bottom!.preferredSize.height);
} 