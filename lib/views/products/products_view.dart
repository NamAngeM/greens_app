import 'package:flutter/material.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/utils/app_router.dart';

import '../../utils/app_router.dart';
import '../../widgets/menu.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeProducts();
    _filteredProducts = _products;
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
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF1F3140),
            ),
            onPressed: () {
              // Action pour les paramètres
            },
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
      body: Column(
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
                        color: Color(0xFF1F3140),
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
                        color: Color(0xFF1F3140),
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

  Widget _buildProductCard(Product product) {
    return Container(
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  product.imageAsset,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (product.isEcoFriendly)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
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
          Padding(
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
                Text(
                  product.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F3140),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final String imageAsset;
  final String category;
  final bool isEcoFriendly;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageAsset,
    required this.category,
    this.isEcoFriendly = false,
  });
}
