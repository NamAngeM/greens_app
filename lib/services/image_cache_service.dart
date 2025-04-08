// File: lib/services/image_cache_service.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:greens_app/utils/app_colors.dart';

/// Service pour gérer la mise en cache des images et optimiser les performances
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  
  // Singleton pattern
  factory ImageCacheService() {
    return _instance;
  }
  
  ImageCacheService._internal();
  
  // Gestionnaire de cache personnalisé avec durée de vie plus longue
  final customCacheManager = CacheManager(
    Config(
      'greensAppCustomCache',
      stalePeriod: const Duration(days: 7), // Garde les images en cache pendant 7 jours
      maxNrOfCacheObjects: 100,             // Limite le nombre d'objets en cache
      repo: JsonCacheInfoRepository(databaseName: 'greensAppImageCache'),
      fileService: HttpFileService(),
    ),
  );
  
  /// Charge une image réseau avec mise en cache
  Widget getNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: customCacheManager,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(width, height),
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(width, height),
    );
    
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }
    
    return image;
  }
  
  /// Widget de chargement par défaut
  Widget _defaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      ),
    );
  }
  
  /// Widget d'erreur par défaut
  Widget _defaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red.shade300,
          size: 30,
        ),
      ),
    );
  }
  
  /// Précharge une liste d'images pour améliorer l'expérience utilisateur
  Future<void> precacheImages(List<String> imageUrls, BuildContext context) async {
    for (final url in imageUrls) {
      await precacheImage(
        CachedNetworkImageProvider(url, cacheManager: customCacheManager),
        context,
      );
    }
  }
  
  /// Vide le cache d'images
  Future<void> clearCache() async {
    await customCacheManager.emptyCache();
  }
}