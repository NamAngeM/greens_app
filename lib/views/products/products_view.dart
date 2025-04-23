import 'package:flutter/material.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/services/favorites_service.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/favorite_item_model.dart';
import 'package:greens_app/views/product_detail_view.dart';
import 'package:greens_app/models/product.dart';
import 'package:greens_app/utils/merchant_urls.dart';
import 'package:greens_app/views/favorites/favorites_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String _selectedCategory = 'All';
  List<String> _categories = ['All', 'Health & Food', 'Fashion', 'Essentials'];
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  int _currentIndex = 2; // Index pour la page products (2 = Shop)
  
  // Affichage des favoris
  bool _isFavoritesVisible = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Initialisation de ProductsView');
    setState(() {
      _isLoading = true;
    });
    
    _initializeProducts();
    
    // Charger les favoris depuis le service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesService>(context, listen: false).loadFavorites();
      
      // Vérifier les arguments de navigation pour l'ajout aux favoris
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        final productToAdd = arguments['addToCart'];
        if (productToAdd != null && productToAdd is Product) {
          _addToFavorites(productToAdd);
          // Afficher les favoris
          setState(() {
            _isFavoritesVisible = true;
          });
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeProducts() {
    print('Initialisation des produits');
    
    _categories = ['All', 'Health & Food', 'Fashion', 'Essentials'];
    
    _products = [
      // Health & Food products
      Product(
        id: 'amoseeds-1',
        name: 'Amoseeds',
        description: 'Healthy Premium Organic Chia Seeds',
        price: 21.99,
        imageAsset: 'assets/images/products/amandes.png',
        category: 'Health & Food',
        isEcoFriendly: true,
      ),
      Product(
        id: 'juneshine-1',
        name: 'June Shine',
        description: 'Hard Kombucha Acai Berry',
        price: 14,
        imageAsset: 'assets/images/products/shine-juice.png',
        category: 'Health & Food',
      ),
      Product(
        id: 'jens-sorbet-1',
        name: 'Jen\'s Sorbet',
        description: 'Fruit sorbet with pear & strawberry',
        price: 9,
        imageAsset: 'assets/images/products/pomade.png',
        category: 'Health & Food',
      ),
      Product(
        id: 'amoseeds-2',
        name: 'Amoseeds',
        description: 'Zen Bio Complex Vitamins & Minerals (60ct)',
        price: 17.99,
        imageAsset: 'assets/images/products/vitamine.png',
        category: 'Health & Food',
        isEcoFriendly: true,
      ),
      
      // Fashion products
      Product(
        id: 'allbirds-1',
        name: 'Allbirds',
        description: 'Women\'s Tree Runners Shoes',
        price: 69,
        imageAsset: 'assets/images/products/chaussures.png',
        category: 'Fashion',
      ),
      Product(
        id: 'organic-basics-1',
        name: 'Organic Basics',
        description: 'Organic Cotton Tee',
        price: 14,
        imageAsset: 'assets/images/products/tee-shirt.png',
        category: 'Fashion',
      ),
      Product(
        id: 'qapel-1',
        name: 'Qapel',
        description: 'Red Leather Bag Sustainable print',
        price: 79.99,
        imageAsset: 'assets/images/products/sac.png',
        category: 'Fashion',
      ),
      Product(
        id: 'organic-basics-2',
        name: 'Organic Basics',
        description: 'Organic Cotton Tee Black',
        price: 14,
        imageAsset: 'assets/images/products/tee-shirt.png',
        category: 'Fashion',
      ),
      
      // Essentials
      Product(
        id: 'ecobottle-1',
        name: 'EcoBottle',
        description: 'Bottle/Thunk EcoBottle (500ml)',
        price: 16,
        imageAsset: 'assets/images/products/botle.png',
        category: 'Essentials',
      ),
      Product(
        id: 'lift-1',
        name: 'Lift',
        description: 'Ergonomic Lift Keyboard Mouse',
        price: 79.99,
        imageAsset: 'assets/images/products/mousse.png',
        category: 'Essentials',
      ),
      Product(
        id: 'mofpw-1',
        name: 'MOFPW',
        description: 'Eco Mechanical Keyboard Cherry 7',
        price: 99.99,
        imageAsset: 'assets/images/products/panier.png',
        category: 'Essentials',
      ),
      Product(
        id: 'lenovo-1',
        name: 'Lenovo ThinkPad',
        description: 'X1 Carbon G12 i7-1355U 32GB RAM',
        price: 1099.99,
        imageAsset: 'assets/images/products/panier.png',
        category: 'Essentials',
      ),
    ];
    
    print('Nombre total de produits chargés: ${_products.length}');
    
    setState(() {
      _filteredProducts = _products;
      _selectedCategory = 'All';
    });
    
    print('Produits filtrés: ${_filteredProducts.length}');
  }

  void _filterProductsByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) => product.category == category).toList();
      }
    });
  }

  // Ajouter un produit aux favoris
  void _addToFavorites(Product product) {
    try {
      final favoriteService = Provider.of<FavoritesService>(context, listen: false);
      
      // Convertir le Product en ProductModel
      final productModel = ProductModel(
        id: product.id,
        name: product.name,
        brand: product.brand,
        description: product.description,
        price: product.price,
        imageUrl: product.imageAsset,
        categories: [product.category],
        isEcoFriendly: product.isEcoFriendly,
      );
      
      favoriteService.addItem(productModel);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajouté aux favoris'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VOIR',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesView()),
              );
            },
          ),
        ),
      );
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout aux favoris: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Supprimer un élément des favoris
  void _removeFromFavorites(int index) {
    final favoritesService = Provider.of<FavoritesService>(context, listen: false);
    final removedItem = favoritesService.removeItem(index);
    
    // Afficher un message de confirmation avec option d'annulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.product.name} supprimé des favoris'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'ANNULER',
          onPressed: () {
            final favoritesService = Provider.of<FavoritesService>(context, listen: false);
            favoritesService.addItem(removedItem.product);
          },
        ),
      ),
    );
  }

  // Vider les favoris
  void _clearFavorites() {
    final favoritesService = Provider.of<FavoritesService>(context, listen: false);
    final oldItems = favoritesService.clearFavorites();
    
    // Afficher un message avec option d'annulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Favoris vidés'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'ANNULER',
          onPressed: () {
            final favoritesService = Provider.of<FavoritesService>(context, listen: false);
            favoritesService.restoreItems(oldItems);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building ProductsView, isLoading: $_isLoading, products: ${_products.length}, filtered: ${_filteredProducts.length}');
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.eco,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Explore a green lifestyle",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _isFavoritesVisible ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: _isFavoritesVisible ? const Color(0xFF4CAF50) : const Color(0xFF1F3140),
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavoritesVisible = !_isFavoritesVisible;
                    });
                  },
                  tooltip: 'Voir mes favoris',
                ),
              ),
              if (Provider.of<FavoritesService>(context).itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      Provider.of<FavoritesService>(context).itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: const Text(
              "Our latest products",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: _isFavoritesVisible
          ? _buildCartView()
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    _initializeProducts();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Column(
                    children: [
                      // Category filter
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = category == _selectedCategory;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () => _filterProductsByCategory(category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Products grid
                      Expanded(
                        child: _filteredProducts.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aucun produit disponible',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  // Calculer le ratio optimal en fonction de la largeur disponible
                                  // Plus l'écran est petit, plus on réduit le ratio pour éviter les débordements
                                  final screenWidth = MediaQuery.of(context).size.width;
                                  // Ratio adaptatif: plus petit sur les petits écrans
                                  double adaptiveRatio;
                                  if (screenWidth < 360) {  // Très petits écrans (Galaxy A15, etc.)
                                    adaptiveRatio = 0.65; // Réduire encore plus pour éviter les débordements
                                  } else if (screenWidth < 400) {  // Petits écrans
                                    adaptiveRatio = 0.68;
                                  } else {  // Écrans moyens et grands
                                    adaptiveRatio = 0.72;
                                  }
                                  
                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: adaptiveRatio,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      print('Construction du produit ${product.name} à l\'index $index');
                                      return _buildProductCard(product);
                                    },
                                  );
                                }
                              ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: CustomMenu(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  // Construire la vue des favoris avec un design amélioré
  Widget _buildCartView() {
    final favoritesService = Provider.of<FavoritesService>(context);
    final favoriteItems = favoritesService.items;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/icons/basket.png',
                      width: 24,
                      height: 24,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Favoris',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F3140),
                        ),
                      ),
                      Text(
                        '${favoritesService.itemCount} article${favoritesService.itemCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Retour'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  setState(() {
                    _isFavoritesVisible = false;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: favoriteItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/icons/basket.png',
                          width: 60,
                          height: 60,
                          color: const Color(0xFF4CAF50).withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Votre liste de favoris est vide',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F3140),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des produits à vos favoris\npour les retrouver ici',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text(
                          'Découvrir nos produits',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavoritesVisible = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteItems.length,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Image du produit avec bordure
                            Container(
                              width: 60, // Réduire davantage la taille de l'image
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: item.product.imageUrl != null
                                          ? item.product.imageUrl!.startsWith('http')
                                              ? Image.network(
                                                  item.product.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => 
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 30, // Réduire la taille de l'icône
                                                    ),
                                                )
                                              : Image.asset(
                                                  item.product.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => 
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 30, // Réduire la taille de l'icône
                                                    ),
                                                )
                                          : Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Colors.grey,
                                              size: 30, // Réduire la taille de l'icône
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // Réduire davantage l'espacement
                            // Informations du produit
                            Expanded( // Utiliser Expanded au lieu de Flexible pour mieux contrôler l'espace
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14, // Réduire la taille de police
                                      color: Color(0xFF1F3140),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2), // Réduire l'espacement vertical
                                  if (item.product.isEcoFriendly)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.eco,
                                          size: 12, // Réduire la taille de l'icône
                                          color: Color(0xFF4CAF50),
                                        ),
                                        const SizedBox(width: 2), // Réduire l'espacement
                                        Text(
                                          'Éco',
                                          style: TextStyle(
                                            fontSize: 10, // Réduire la taille de police
                                            color: const Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 2), // Réduire l'espacement vertical
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14, // Réduire la taille de police
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Boutons d'action compactés en ligne
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Bouton d'achat plus compact
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: IconButton(
                                    iconSize: 18, // Réduire la taille de l'icône
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.shopping_bag_outlined),
                                    color: Colors.blue,
                                    onPressed: () {
                                      _openMerchantUrl(item.product.merchantUrl);
                                    },
                                    tooltip: 'Acheter',
                                  ),
                                ),
                                // Bouton de suppression plus compact
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: IconButton(
                                    iconSize: 18, // Réduire la taille de l'icône
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      _removeFromFavorites(index);
                                    },
                                    tooltip: 'Supprimer',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Bouton pour acheter tous les produits favoris
        if (favoriteItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Nombre de produits
                  Text(
                    '${favoritesService.itemCount} produit${favoritesService.itemCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Bouton "Acheter tout"
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Acheter tout'),
                      onPressed: favoritesService.isEmpty ? null : _buyAllFavorites,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Ouvrir l'URL du marchand
  Future<void> _openMerchantUrl(String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune URL de marchand disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Impossible d'ouvrir le site marchand"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de l\'URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Acheter tous les produits favoris
  Future<void> _buyAllFavorites() async {
    final favoritesService = Provider.of<FavoritesService>(context, listen: false);
    final urls = favoritesService.getBuyUrls();
    
    if (urls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune URL de marchand disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ouvrir seulement la première URL pour l'instant
    await _openMerchantUrl(urls.first);
    
    // Afficher un message pour indiquer combien d'URLs restent à ouvrir
    if (urls.length > 1 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${urls.length - 1} autres produits à acheter'),
          action: SnackBarAction(
            label: 'SUIVANT',
            onPressed: () {
              _openMerchantUrl(urls[1]);
            },
          ),
        ),
      );
    }
  }

  Widget _buildProductCard(Product product) {
    final merchantInfo = MerchantUrls.getMerchantForProduct(product.id);
    
    return GestureDetector(
      onTap: () {
        // Navigation vers la page de détail du produit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailView(product: product),
          ),
        ).then((showCart) {
          // Si showCart est true, afficher les favoris
          if (showCart == true) {
            setState(() {
              _isFavoritesVisible = true;
            });
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Utiliser un layout plus adaptable avec des tailles relatives
        child: LayoutBuilder(
          builder: (context, constraints) {
            // La hauteur maximale disponible pour la carte
            final cardHeight = constraints.maxHeight;
            // Allouer 55% pour l'image et 45% pour les infos
            final imageHeight = cardHeight * 0.55;
            final infoHeight = cardHeight * 0.45;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image - hauteur fixe pour éviter les débordements
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'product-${product.id}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey.shade100,
                            child: product.imageAsset != null
                                ? Image.asset(
                                    product.imageAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Erreur de chargement de l\'image produit: ${product.name}, erreur: $error');
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey,
                                          size: 48,
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (product.isEcoFriendly)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.eco,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Product info - hauteur fixe basée sur le layout
                SizedBox(
                  height: infoHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nom du produit
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1F3140),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        // Description - hauteur flexible limitée
                        Flexible(
                          child: Text(
                            product.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        // Prix et boutons - hauteur fixe
                        SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Prix avec contrainte de largeur
                              Flexible(
                                child: Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1F3140),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Boutons d'action compacts
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Bouton d'ajout aux favoris
                                  InkWell(
                                    onTap: () => _addToFavorites(product),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Si un marchand existe pour ce produit, montrer le bouton Acheter
                                  if (merchantInfo != null) 
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: InkWell(
                                        onTap: () async {
                                          try {
                                            final url = Uri.parse(merchantInfo.url);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Impossible d'ouvrir le site marchand"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            print('Erreur lors de l\'ouverture de l\'URL: $e');
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Erreur: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Buy',
                                            style: TextStyle(
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
