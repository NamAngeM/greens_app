import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class AppPerformance {
  // Optimisation de la mémoire
  static void disposeControllers(List<dynamic> controllers) {
    for (var controller in controllers) {
      if (controller is TextEditingController) {
        controller.dispose();
      } else if (controller is ScrollController) {
        controller.dispose();
      } else if (controller is PageController) {
        controller.dispose();
      } else if (controller is TabController) {
        controller.dispose();
      } else if (controller is AnimationController) {
        controller.dispose();
      }
    }
  }

  // Optimisation des images
  static Widget optimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool isAsset = true,
  }) {
    if (isAsset) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width != null ? (width * 2).toInt() : null,
        cacheHeight: height != null ? (height * 2).toInt() : null,
      );
    } else {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width != null ? (width * 2).toInt() : null,
        cacheHeight: height != null ? (height * 2).toInt() : null,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          );
        },
      );
    }
  }

  // Optimisation des listes
  static Widget optimizedListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      physics: physics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
    );
  }

  // Optimisation des grilles
  static Widget optimizedGridView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      physics: physics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
    );
  }

  // Optimisation des animations
  static Widget fadeInAnimation({
    required Widget child,
    required AnimationController controller,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeIn,
        ),
      ),
      child: child,
    );
  }

  // Optimisation du rendu
  static Widget optimizedContainer({
    required Widget child,
    Color? color,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Alignment? alignment,
  }) {
    return RepaintBoundary(
      child: Container(
        color: color,
        decoration: decoration,
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        alignment: alignment,
        child: child,
      ),
    );
  }
}
