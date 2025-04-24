import 'package:flutter/material.dart';

/// Widget de carte personnalisé pour afficher des informations
class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const CustomCard({
    Key? key,
    required this.child,
    this.color,
    this.elevation = 2.0,
    this.padding,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      color: color ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

/// Widget d'icône avec badge
class IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final Color? iconColor;
  final Color? badgeColor;
  final double iconSize;
  final VoidCallback? onTap;

  const IconWithBadge({
    Key? key,
    required this.icon,
    this.badgeCount = 0,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(iconSize),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
            size: iconSize,
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 9 ? '9+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget de conteneur avec gradient
class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const GradientContainer({
    Key? key,
    required this.child,
    required this.gradient,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// Widget de texte sur deux lignes avec titre et sous-titre
class TwoLineText extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextAlign? textAlign;

  const TwoLineText({
    Key? key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: titleStyle ?? Theme.of(context).textTheme.titleMedium,
          textAlign: textAlign,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: subtitleStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          textAlign: textAlign,
        ),
      ],
    );
  }
}

/// Widget pour afficher un séparateur avec texte
class TextDivider extends StatelessWidget {
  final String text;
  final Color? color;
  final TextStyle? textStyle;

  const TextDivider({
    Key? key, 
    required this.text,
    this.color,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color ?? Colors.grey.shade300,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: textStyle ?? TextStyle(color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Divider(
            color: color ?? Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
} 