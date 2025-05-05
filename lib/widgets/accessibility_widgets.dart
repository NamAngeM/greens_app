import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Pour HapticFeedback
import 'package:provider/provider.dart';
import 'package:greens_app/services/accessibility_service.dart';

/// Widget de texte accessible qui s'adapte automatiquement aux paramètres d'accessibilité
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  final bool excludeFromSemantics;
  
  const AccessibleText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = Provider.of<AccessibilityService>(context);
    
    // Calculer le style adapté
    final TextStyle baseStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final TextStyle adaptedStyle = baseStyle.copyWith(
      fontSize: accessibilityService.getAdaptiveTextSize(baseStyle.fontSize ?? 14),
      color: accessibilityService.getAdaptiveColor(
        baseStyle.color ?? Theme.of(context).textTheme.bodyMedium!.color!,
        accessibilityService.isHighContrastEnabled ? Colors.white : baseStyle.color ?? Theme.of(context).textTheme.bodyMedium!.color!,
      ),
      fontWeight: accessibilityService.isLargeTextEnabled ? FontWeight.bold : baseStyle.fontWeight,
      letterSpacing: accessibilityService.isLargeTextEnabled ? 0.5 : baseStyle.letterSpacing,
    );
    
    return Semantics(
      label: semanticsLabel ?? text,
      excludeSemantics: excludeFromSemantics,
      child: Text(
        text,
        style: adaptedStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Widget d'image accessible avec description pour les lecteurs d'écran
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String? semanticLabel;
  final String? altText;
  final String imageName;
  final double? width;
  final double? height;
  final BoxFit? fit;
  
  const AccessibleImage({
    Key? key,
    required this.image,
    required this.imageName,
    this.semanticLabel,
    this.altText,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = Provider.of<AccessibilityService>(context);
    final String description = semanticLabel ?? 
                               accessibilityService.getDescriptiveTextForImage(imageName, altText: altText);
    
    return Semantics(
      label: description,
      image: true,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}

/// Bouton accessible avec feedback haptique et étiquette sémantique
class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? semanticLabel;
  final bool withHapticFeedback;
  final ButtonStyle? style;

  const AccessibleButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.withHapticFeedback = true,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ElevatedButton(
        onPressed: () {
          if (withHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          onPressed();
        },
        style: style,
        child: child,
      ),
    );
  }
}

/// Carte de produit accessible avec étiquettes sémantiques complètes
class AccessibleProductCard extends StatelessWidget {
  final String productName;
  final String description;
  final String category;
  final double price;
  final bool isEcoFriendly;
  final ImageProvider? image;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final String? imageName;

  const AccessibleProductCard({
    Key? key,
    required this.productName,
    required this.description,
    required this.category,
    required this.price,
    required this.isEcoFriendly,
    required this.onTap,
    this.image,
    this.onAddToCart,
    this.imageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = Provider.of<AccessibilityService>(context);
    
    // Construire une description détaillée pour les lecteurs d'écran
    final String semanticDescription = 
        '$productName, $category, Prix: ${price.toStringAsFixed(2)} euros'
        '${isEcoFriendly ? ', Produit écologique' : ''}. $description';
    
    return Semantics(
      label: semanticDescription,
      button: true,
      enabled: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: accessibilityService.getAdaptiveColor(
              Colors.white,
              const Color(0xFF222222), // Fond foncé pour le contraste élevé
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la carte avec l'image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: accessibilityService.getAdaptiveColor(
                          Colors.grey.shade200,
                          Colors.grey.shade800, // Plus foncé pour contraste élevé
                        ),
                      ),
                      child: image != null
                          ? ExcludeSemantics( // On exclut l'image des sémantiques car on a déjà une description complète
                              child: Image(
                                image: image!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.image_not_supported_outlined,
                              color: accessibilityService.getAdaptiveColor(
                                Colors.grey,
                                Colors.grey.shade400, // Plus clair pour contraste élevé
                              ),
                              size: 40,
                            ),
                    ),
                    // Badge écologique
                    if (isEcoFriendly)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Semantics(
                          container: true,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accessibilityService.getAdaptiveColor(
                                const Color(0xFF4CAF50).withOpacity(0.9),
                                Colors.lightGreen, // Plus vif pour contraste élevé
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.eco_outlined,
                              color: accessibilityService.getAdaptiveColor(
                                Colors.white,
                                Colors.black, // Noir sur fond clair pour contraste élevé
                              ),
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Informations sur le produit
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Catégorie
                      AccessibleText(
                        category,
                        style: TextStyle(
                          color: accessibilityService.getAdaptiveColor(
                            Colors.grey.shade600,
                            Colors.grey.shade300, // Plus clair pour contraste élevé
                          ),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      
                      // Nom du produit
                      AccessibleText(
                        productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: accessibilityService.getAdaptiveColor(
                            Colors.black87,
                            Colors.white, // Blanc pour contraste élevé
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      
                      // Description
                      Expanded(
                        child: AccessibleText(
                          description,
                          style: TextStyle(
                            color: accessibilityService.getAdaptiveColor(
                              Colors.grey.shade700,
                              Colors.grey.shade300, // Plus clair pour contraste élevé
                            ),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Prix et bouton d'achat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AccessibleText(
                            '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: accessibilityService.getAdaptiveColor(
                                const Color(0xFF4CAF50),
                                Colors.lightGreen, // Plus vif pour contraste élevé
                              ),
                            ),
                          ),
                          if (onAddToCart != null)
                            Semantics(
                              button: true,
                              label: 'Ajouter au panier',
                              onTap: onAddToCart,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  onAddToCart!();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: accessibilityService.getAdaptiveColor(
                                      const Color(0xFF4CAF50),
                                      Colors.lightGreen, // Plus vif pour contraste élevé
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.add_shopping_cart_outlined,
                                    color: accessibilityService.getAdaptiveColor(
                                      Colors.white,
                                      Colors.black, // Noir sur fond clair pour contraste élevé
                                    ),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 