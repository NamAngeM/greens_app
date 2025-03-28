import 'package:flutter/material.dart';
import 'package:greens_app/widgets/menu.dart';

import '../../widgets/menu.dart';

class BlogView extends StatefulWidget {
  const BlogView({Key? key}) : super(key: key);

  @override
  State<BlogView> createState() => _BlogViewState();
}

class _BlogViewState extends State<BlogView> {
  final List<Product> _recommendedProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  void _initializeProducts() {
    _recommendedProducts.addAll([
      Product(
        name: "Jen's Sorbet",
        description: "Rosé sorbet with pear & strawberry",
        price: 11.99,
        imageAsset: 'assets/images/products/sorbet.png',
        isEcoFriendly: true,
      ),
      Product(
        name: "Amoseeds",
        description: "Complete Zen Bliss Safran & Mélisse (x60)",
        price: 17.99,
        imageAsset: 'assets/images/products/amandes.png',
        isEcoFriendly: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBlogHeader(),
                  _buildBlogContent(),
                  _buildRecommendedProducts(),
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomMenu(
                currentIndex: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogHeader() {
    return Stack(
      children: [
        // Background image
        Container(
          height: 300,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/articles/eco_steps.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlay
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Logo and title
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '5 easy steps to',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'go green today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '20 Min',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlogContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      transform: Matrix4.translationValues(0, -30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Become Zero Waste',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3140),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Going green doesn\'t have to be difficult. With just a few small changes in your daily life, you can contribute to a healthier planet.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5D6A75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildTipSection(
            'Start by reducing plastic use',
            '– instead of single-use plastics, switch to reusable bags, bottles, and containers.',
          ),
          const SizedBox(height: 20),
          _buildTipSection(
            'Saving energy',
            'is another great way to go green; simply turning off lights when you\'re not using them or unplugging electronics can make a noticeable difference. Recycling and composting are also simple yet effective steps to reduce waste and minimize landfill space.',
          ),
          const SizedBox(height: 20),
          _buildTipSection(
            'Supporting eco-friendly brands',
            'that are committed to promoting sustainability. Finally, opt for eco-friendly products in your daily routine, whether it\'s natural cleaning supplies or organic beauty products.',
          ),
          const SizedBox(height: 20),
          _buildTipSection(
            'Making these simple changes',
            'can lead to a more sustainable lifestyle, and the best part is that every small action counts toward a bigger, greener impact!',
          ),
          const SizedBox(height: 30),
          const Text(
            'You may also like...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3140),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection(String boldText, String regularText) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF5D6A75),
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: boldText + ' ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3140),
            ),
          ),
          TextSpan(text: regularText),
        ],
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _recommendedProducts.map((product) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.asset(
                            product.imageAsset,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          if (product.isEcoFriendly)
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CD964),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco_outlined,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1F3140),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5D6A75),
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
          );
        }).toList(),
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final String imageAsset;
  final bool isEcoFriendly;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageAsset,
    this.isEcoFriendly = false,
  });
}