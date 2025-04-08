import 'package:flutter/material.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/services/cart_service.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/cart_item_model.dart';
import 'package:greens_app/views/product_detail_view.dart';
import 'package:greens_app/models/product.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String _selectedCategory = 'All';
  List<String> _categories = ['All', 'Health & Food', 'Fashion'];
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  int _currentIndex = 2; // Index pour la page products (2 = Shop)
  
  // Affichage du panier
  bool _isCartVisible = false;
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeProducts();
    
    // Charger le panier depuis le service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartService>(context, listen: false).loadCart();
      
      // Vérifier les arguments de navigation pour l'ajout au panier
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        final productToAdd = arguments['addToCart'];
        if (productToAdd != null && productToAdd is Product) {
          _addToCart(productToAdd);
          // Afficher le panier
          setState(() {
            _isCartVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _initializeProducts() {
    _products = [
      // Health & Food products
      Product(
        name: 'Amoseeds',
        description: 'Healthy Premium Organic Chia Seeds',
        price: 21.99,
        imageAsset: 'assets/images/products/amandes.png',
        category: 'Health & Food',
        isEcoFriendly: true,
      ),
      Product(
        name: 'June Shine',
        description: 'Hard Kombucha Acai Berry',
        price: 14,
        imageAsset: 'assets/images/products/shine-juice.png',
        category: 'Health & Food',
      ),
      Product(
        name: 'Jen\'s Sorbet',
        description: 'Fruit sorbet with pear & strawberry',
        price: 9,
        imageAsset: 'assets/images/products/pomade.png',
        category: 'Health & Food',
      ),
      Product(
        name: 'Amoseeds',
        description: 'Zen Bio Complex Vitamins & Minerals (60ct)',
        price: 17.99,
        imageAsset: 'assets/images/products/vitamine.png',
        category: 'Health & Food',
        isEcoFriendly: true,
      ),
      
      // Fashion products
      Product(
        name: 'Allbirds',
        description: 'Women\'s Tree Runners Shoes',
        price: 69,
        imageAsset: 'assets/images/products/chaussures.png',
        category: 'Fashion',
      ),
      Product(
        name: 'Organic Basics',
        description: 'Organic Cotton Tee',
        price: 14,
        imageAsset: 'assets/images/products/tee-shirt.png',
        category: 'Fashion',
      ),
      Product(
        name: 'Qapel',
        description: 'Red Leather Bag Sustainable print',
        price: 79.99,
        imageAsset: 'assets/images/products/sac.png',
        category: 'Fashion',
      ),
      Product(
        name: 'Organic Basics',
        description: 'Organic Cotton Tee Black',
        price: 14,
        imageAsset: 'assets/images/products/tee-shirt.png',
        category: 'Fashion',
      ),
      
      // Essentials
      Product(
        name: 'EcoBottle',
        description: 'Bottle/Thunk EcoBottle (500ml)',
        price: 16,
        imageAsset: 'assets/images/products/botle.png',
        category: 'Essentials',
      ),
      Product(
        name: 'Lift',
        description: 'Ergonomic Lift Keyboard Mouse',
        price: 79.99,
        imageAsset: 'assets/images/products/mousse.png',
        category: 'Essentials',
      ),
      Product(
        name: 'MOFPW',
        description: 'Eco Mechanical Keyboard Cherry 7',
        price: 99.99,
        imageAsset: 'assets/images/products/panier.png',
        category: 'Essentials',
      ),
      Product(
        name: 'Lenovo ThinkPad',
        description: 'X1 Carbon G12 i7-1355U 32GB RAM',
        price: 1099.99,
        imageAsset: 'assets/images/products/panier.png',
        category: 'Essentials',
      ),
    ];
    _filteredProducts = _products;
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

  // Ajouter un produit au panier
  void _addToCart(Product product) {
    // Convertir le Product local en ProductModel
    final productModel = ProductModel(
      id: product.name.hashCode.toString(), // Génère un ID basé sur le nom
      name: product.name,
      brand: 'GreenMinds', // À adapter selon vos besoins
      description: product.description,
      price: product.price,
      imageUrl: product.imageAsset,
      categories: [product.category],
      isEcoFriendly: product.isEcoFriendly,
    );
    
    // Ajouter au service de panier
    final cartService = Provider.of<CartService>(context, listen: false);
    cartService.addItem(productModel);
    
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'VOIR PANIER',
          onPressed: () {
            setState(() {
              _isCartVisible = true;
            });
          },
        ),
      ),
    );
  }

  // Supprimer un élément du panier
  void _removeFromCart(int index) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final removedItem = cartService.removeItem(index);
    
    // Afficher un message de confirmation avec option d'annulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.product.name} supprimé du panier'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'ANNULER',
          onPressed: () {
            final cartService = Provider.of<CartService>(context, listen: false);
            cartService.addItem(removedItem.product);
          },
        ),
      ),
    );
  }

  // Mettre à jour la quantité d'un élément du panier
  void _updateQuantity(int index, int newQuantity) {
    final cartService = Provider.of<CartService>(context, listen: false);
    cartService.updateQuantity(index, newQuantity);
  }

  // Mettre à jour la quantité directement
  void _updateQuantityDirectly(int index, String value) {
    final parsedValue = int.tryParse(value);
    if (parsedValue != null && parsedValue > 0) {
      _updateQuantity(index, parsedValue);
    }
  }

  // Appliquer un code promo
  void _applyPromoCode() {
    final cartService = Provider.of<CartService>(context);
    
    setState(() {
      // Utiliser le promoCode du TextEditingController
      cartService.applyPromoCode(_promoController.text).then((isValid) {
        // Afficher un message selon la validité du code
        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code promo appliqué avec succès'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code promo invalide'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    });
  }

  // Vider le panier
  void _clearCart() {
    final cartService = Provider.of<CartService>(context, listen: false);
    final oldItems = cartService.clearCart();
    
    // Afficher un message avec option d'annulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Panier vidé'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'ANNULER',
          onPressed: () {
            final cartService = Provider.of<CartService>(context, listen: false);
            cartService.restoreItems(oldItems);
          },
        ),
      ),
    );
  }

  // Sauvegarder le panier pour plus tard
  void _saveCartForLater() {
    // Ici, vous pourriez implémenter la sauvegarde du panier dans un compte utilisateur
    // Pour l'instant, nous affichons simplement un message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Panier sauvegardé pour plus tard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Ajouter un bouton pour afficher le panier avec un design amélioré
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _isCartVisible ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/icons/basket.png',
                    width: 24,
                    height: 24,
                    color: _isCartVisible ? const Color(0xFF4CAF50) : const Color(0xFF1F3140),
                  ),
                  onPressed: () {
                    setState(() {
                      _isCartVisible = !_isCartVisible;
                    });
                  },
                  tooltip: 'Voir mon panier',
                ),
              ),
              if (Provider.of<CartService>(context).itemCount > 0)
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
                      Provider.of<CartService>(context).itemCount.toString(),
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
      body: _isCartVisible
          ? _buildCartView()
          : Column(
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
          
          // Subcategory (Health & Food)
          if (_selectedCategory == 'Health & Food' || _selectedCategory == 'All')
            Container(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Health & Food",
                style: TextStyle(
                  color: Color(0xFF1F3140),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // Products grid
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Health & Food products grid
                if (_selectedCategory == 'Health & Food' || _selectedCategory == 'All')
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.where((p) => p.category == 'Health & Food').length,
                    itemBuilder: (context, index) {
                      final products = _filteredProducts.where((p) => p.category == 'Health & Food').toList();
                      return _buildProductCard(products[index]);
                    },
                  ),
                
                // Fashion category title
                if (_selectedCategory == 'Fashion' || _selectedCategory == 'All')
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: Text(
                      "Fashion",
                      style: TextStyle(
                        color: const Color(0xFF1F3140),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // Fashion products grid
                if (_selectedCategory == 'Fashion' || _selectedCategory == 'All')
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.where((p) => p.category == 'Fashion').length,
                    itemBuilder: (context, index) {
                      final products = _filteredProducts.where((p) => p.category == 'Fashion').toList();
                      return _buildProductCard(products[index]);
                    },
                  ),
                
                // Essentials category title
                if (_selectedCategory == 'All')
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: Text(
                      "Essentials",
                      style: TextStyle(
                        color: const Color(0xFF1F3140),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // Essentials products grid
                if (_selectedCategory == 'All')
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.where((p) => p.category == 'Essentials').length,
                    itemBuilder: (context, index) {
                      final products = _filteredProducts.where((p) => p.category == 'Essentials').toList();
                      return _buildProductCard(products[index]);
                    },
                  ),
                
                // Bottom padding
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomMenu(
        currentIndex: 2, // Index correct pour la page products
        onTap: (index) {
          if (index != 2) { // Ne pas recharger si on est déjà sur cette page
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  // Construire la vue du panier avec un design amélioré
  Widget _buildCartView() {
    final cartService = Provider.of<CartService>(context);
    final cartItems = cartService.items;
    
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
                        'Mon Panier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F3140),
                        ),
                      ),
                      Text(
                        '${cartService.itemCount} article${cartService.itemCount > 1 ? 's' : ''}',
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
                    _isCartVisible = false;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: cartItems.isEmpty
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
                        'Votre panier est vide',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F3140),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des produits pour commencer vos achats',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
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
                            _isCartVisible = false;
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
                  itemCount: cartItems.length,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
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
                              width: 70, // Réduire la largeur pour éviter le débordement
                              height: 70, // Réduire la hauteur pour maintenir le ratio
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item.product.imageUrl ?? 'assets/images/placeholder.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12), // Réduire l'espacement
                            // Informations du produit
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: const Color(0xFF1F3140),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.product.isEcoFriendly)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.eco,
                                          size: 14,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Éco-responsable',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: const Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: const Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Contrôles de quantité avec design amélioré
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: () {
                                      _updateQuantity(index, item.quantity - 1);
                                    },
                                    color: Colors.grey.shade600,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      item.quantity.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1F3140),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () {
                                      _updateQuantity(index, item.quantity + 1);
                                    },
                                    color: const Color(0xFF4CAF50),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bouton de suppression
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                              onPressed: () {
                                _removeFromCart(index);
                              },
                              tooltip: 'Supprimer du panier',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Résumé du panier et bouton de paiement avec design amélioré
        if (cartItems.isNotEmpty)
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sous-total:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '\$${cartService.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F3140),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Livraison:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Gratuite',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${cartService.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text(
                      'Procéder au paiement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Implémenter la logique de paiement ici
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paiement en cours de traitement...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        // Navigation vers la page de détail du produit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailView(product: product),
          ),
        ).then((showCart) {
          // Si showCart est true, afficher le panier
          if (showCart == true) {
            setState(() {
              _isCartVisible = true;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Stack(
              children: [
                Hero(
                  tag: 'product-${product.name}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      product.imageAsset,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
            
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1F3140),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1F3140),
                          ),
                        ),
                        // Bouton d'ajout au panier avec design amélioré
                        InkWell(
                          onTap: () => _addToCart(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/icons/basket.png',
                              width: 18,
                              height: 18,
                              color: Colors.white,
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
    );
  }
}
