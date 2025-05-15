import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

/// Widget d'AppBar personnalisé avec un bouton de retour
class AppBarWithBackButton extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final double elevation;
  final bool centerTitle;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const AppBarWithBackButton({
    Key? key,
    this.title = '',
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.leading,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? const Color(0xFF1F3140),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: leading ?? IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: iconColor ?? const Color(0xFF1F3140),
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 