import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/services/favorites_service.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/models/product.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/utils/merchant_urls.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;

  const ProductDetailView({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _quantity = 1;
  bool _showEcoFeatures = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      HapticFeedback.lightImpact();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        HapticFeedback.lightImpact();
      });
    }
  }

  void _toggleEcoFeatures() {
    setState(() {
      _showEcoFeatures = !_showEcoFeatures;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ajouté aux favoris'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partage du produit'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image du produit avec un gradient pour améliorer la lisibilité
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Stack(
              children: [
                Hero(
                  tag: 'product-${widget.product.name}',
                  child: widget.product.imageAsset != null 
                    ? Image.asset(
                        widget.product.imageAsset!,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.45,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Afficher une image de remplacement en cas d'erreur
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
                ),
                // Gradient pour améliorer la lisibilité du texte
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu principal avec animation
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espace pour l'image
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                
                // Contenu avec animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge écologique si applicable
                          if (widget.product.isEcoFriendly)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.eco,
                                    color: Color(0xFF4CAF50),
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Produit écologique',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Nom et prix
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F3140),
                                  ),
                                ),
                              ),
                              Text(
                                '${widget.product.price.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Catégorie
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.product.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F3140),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Caractéristiques écologiques avec animation
                          if (widget.product.isEcoFriendly) ...[
                            GestureDetector(
                              onTap: _toggleEcoFeatures,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Caractéristiques écologiques',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F3140),
                                    ),
                                  ),
                                  Icon(
                                    _showEcoFeatures ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedCrossFade(
                              firstChild: const SizedBox(height: 0),
                              secondChild: Column(
                                children: [
                                  _buildEcoFeature(Icons.recycling, 'Matériaux recyclés ou biodégradables'),
                                  _buildEcoFeature(Icons.eco, 'Faible impact environnemental'),
                                  _buildEcoFeature(Icons.water_drop, 'Économie d\'eau dans la production'),
                                  _buildEcoFeature(Icons.co2, 'Réduction des émissions de CO2'),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              crossFadeState: _showEcoFeatures ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Boutons d'action (favoris et achat)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              children: [
                                // Sélecteur de quantité
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: _decrementQuantity,
                                        color: _quantity > 1 ? const Color(0xFF1F3140) : Colors.grey,
                                      ),
                                      Text(
                                        _quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: _incrementQuantity,
                                        color: const Color(0xFF1F3140),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Bouton d'ajout aux favoris
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final favoritesService = Provider.of<FavoritesService>(context, listen: false);
                                      
                                      // Convertir le Product en ProductModel
                                      final productModel = ProductModel(
                                        id: widget.product.id,
                                        name: widget.product.name,
                                        brand: widget.product.brand,
                                        description: widget.product.description,
                                        price: widget.product.price,
                                        imageUrl: widget.product.imageAsset,
                                        categories: [widget.product.category],
                                        isEcoFriendly: widget.product.isEcoFriendly,
                                        merchantUrl: widget.product.merchantUrl,
                                      );
                                      
                                      // Ajouter aux favoris avec la quantité sélectionnée
                                      for (int i = 0; i < _quantity; i++) {
                                        favoritesService.addItem(productModel);
                                      }
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${widget.product.name} ajouté aux favoris (x$_quantity)'),
                                          duration: const Duration(seconds: 1),
                                          action: SnackBarAction(
                                            label: 'VOIR FAVORIS',
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.favorite),
                                    label: const Text('Ajouter aux favoris'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                // Bouton "Acheter" si merchantUrl existe
                                Builder(
                                  builder: (context) {
                                    final merchantInfo = MerchantUrls.getMerchantForProduct(widget.product.id);
                                    if (merchantInfo == null) return const SizedBox.shrink();
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            final url = Uri.parse(merchantInfo.url);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Impossible d'ouvrir le site marchand"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            print('Erreur lors de l\'ouverture de l\'URL: $e');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Erreur: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.shopping_bag),
                                        label: const Text('Acheter'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1F2937),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEcoFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Image non disponible',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.name,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}