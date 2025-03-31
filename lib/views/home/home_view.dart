import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/controllers/article_controller.dart';
import 'package:greens_app/controllers/product_controller.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/views/products/products_view.dart';
import 'package:greens_app/services/cart_service.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/article_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articleController = Provider.of<ArticleController>(context, listen: false);
      final productController = Provider.of<ProductController>(context, listen: false);
      
      articleController.getRecentArticles();
      productController.getEcoFriendlyProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'Leah Ward',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Page d'accueil
          _buildHomePage(),
          
          // Page des produits
          const Center(child: Text('Page Produits - À implémenter')),
          
          // Page du chatbot (placeholder)
          const Center(child: Text('Page Chatbot - À implémenter')),
          
          // Page de profil
          _buildProfilePage(authController),
        ],
      ),
      bottomNavigationBar: CustomMenu(
        currentIndex: 0, // Mettre à jour l'indice du menu
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Section: Green tips of the day
            _buildSectionHeader('Green tips of the day'),
            const SizedBox(height: 12),
            _buildTipCard(),
            const SizedBox(height: 24),
            
            // Section: Latest articles
            _buildSectionHeader('Latest articles', showSeeAll: true),
            const SizedBox(height: 12),
            _buildLatestArticleCard(),
            const SizedBox(height: 24),
            
            // Section: Products you'll love
            _buildSectionHeader('Products you\'ll love', showSeeAll: true),
            const SizedBox(height: 12),
            _buildProductFilters(),
            const SizedBox(height: 16),
            _buildProductGrid(),
            const SizedBox(height: 24),
            
            // Keep exploring button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3246),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Keep exploring',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Chatbot section with background image
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/backgrounds/footer_background2.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        color: Color(0xFF4CAF50),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Heading text
                    const Text(
                      'Shaping a sustainable future',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Chatbot button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to chatbot
                        setState(() {
                          _currentIndex = 2; // Index for chatbot page
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Discuss with our chatbot',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Footer
            _buildFooter(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSingleTipCard(
            title: 'Ecologie',
            description: 'Échangez les sacs en plastique contre des sacs en tissu pour réduire les déchets. Un seul sac réutilisable peut remplacer des centaines de sacs en plastique à usage unique.',
            color: const Color(0xFF4CAF50).withOpacity(0.8),
            icon: Icons.eco,
            backgroundImage: 'assets/images/backgrounds/tips_background.png',
          ),
          const SizedBox(width: 12),
          _buildSingleTipCard(
            title: 'Énergie',
            description: 'Éteignez les lumières lorsque vous ne les utilisez pas pour économiser l\'énergie. Les ampoules LED utilisent jusqu\'à 80% moins d\'énergie que les ampoules à incandescence traditionnelles.',
            color: const Color(0xFF2196F3).withOpacity(0.8),
            icon: Icons.lightbulb_outline,
            backgroundImage: 'assets/images/backgrounds/tips_background.png',
          ),
          const SizedBox(width: 12),
          _buildSingleTipCard(
            title: 'Eau',
            description: 'Réparez les robinets qui fuient pour conserver les ressources en eau. Un robinet qui fuit peut gaspiller jusqu\'à 3 000 gallons d\'eau par an.',
            color: const Color(0xFF00BCD4).withOpacity(0.8),
            icon: Icons.water_drop_outlined,
            backgroundImage: 'assets/images/backgrounds/tips_background.png',
          ),
          const SizedBox(width: 12),
          _buildSingleTipCard(
            title: 'Nourriture',
            description: 'Réduisez les déchets alimentaires en planifiant vos repas et en stockant correctement les restes. Environ un tiers de toute la nourriture produite dans le monde est gaspillée.',
            color: const Color(0xFFFF9800).withOpacity(0.8),
            icon: Icons.restaurant_outlined,
            backgroundImage: 'assets/images/backgrounds/tips_background.png',
          ),
          const SizedBox(width: 12),
          _buildSingleTipCard(
            title: 'Transport',
            description: 'Choisissez la marche, le vélo ou les transports en commun lorsque cela est possible. Un seul bus peut remplacer des dizaines de voitures sur la route.',
            color: const Color(0xFF9C27B0).withOpacity(0.8),
            icon: Icons.directions_bike_outlined,
            backgroundImage: 'assets/images/backgrounds/tips_background.png',
          ),
        ],
      ),
    );
  }

  Widget _buildSingleTipCard({
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required String backgroundImage,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white.withOpacity(0.7),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestArticleCard() {
    final articleController = Provider.of<ArticleController>(context);
    
    if (articleController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Use test articles if no articles are available
    List<ArticleModel> articlesToShow = articleController.filteredArticles;
    
    if (articlesToShow.isEmpty) {
      // Test articles data
      articlesToShow = [
        ArticleModel(
          id: 'test-article-1',
          title: 'Comment réduire votre empreinte carbone à la maison',
          content: '''Faire de petits changements dans vos habitudes quotidiennes peut réduire considérablement votre empreinte carbone. Commencez par passer aux ampoules LED, réduire la consommation d'eau et composter les déchets alimentaires.''',
          // Image montrant une maison écologique avec panneaux solaires et jardin durable
          imageUrl: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          categories: ['Développement durable', 'Maison'],
          readTimeMinutes: 4,
          publishDate: DateTime.now().subtract(const Duration(days: 2)),
          authorName: 'Emma Green',
        ),
        ArticleModel(
          id: 'test-article-2',
          title: 'Les avantages de passer aux énergies renouvelables',
          content: '''Les sources d'énergie renouvelable comme l'énergie solaire et éolienne peuvent aider à réduire les émissions de gaz à effet de serre et à lutter contre le changement climatique. Découvrez comment vous pouvez faire la transition dans votre maison.''',
          // Image illustrant des panneaux solaires et des éoliennes dans un paysage verdoyant
          imageUrl: 'https://images.unsplash.com/photo-1508514177221-188b1cf16e9d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          categories: ['Énergie', 'Développement durable'],
          readTimeMinutes: 5,
          publishDate: DateTime.now().subtract(const Duration(days: 5)),
          authorName: 'Michael Sun',
        ),
        ArticleModel(
          id: 'test-article-3',
          title: 'La mode durable : au-delà des tendances',
          content: '''La mode rapide a un impact environnemental significatif. Découvrez comment construire une garde-robe durable qui est à la fois élégante et respectueuse de l'environnement.''',
          // Image présentant des vêtements fabriqués à partir de matériaux durables et recyclés
          imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          categories: ['Mode', 'Développement durable'],
          readTimeMinutes: 6,
          publishDate: DateTime.now().subtract(const Duration(days: 7)),
          authorName: 'Sophia Styles',
        ),
      ];
    }
    
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: articlesToShow.length,
        itemBuilder: (context, index) {
          final article = articlesToShow[index];
          return Container(
            width: 300,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: article.imageUrl != null && article.imageUrl!.isNotEmpty
                    ? NetworkImage(article.imageUrl!) 
                    : const AssetImage('assets/images/backgrounds/latest_article_background.png') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Extraire un court extrait du contenu pour l'utiliser comme sous-titre
                    article.content.length > 100 
                        ? '${article.content.substring(0, 100)}...' 
                        : article.content,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3246),
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: () {
              // Navigate to see all page
            },
            child: const Text(
              'See all',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', isSelected: true),
          _buildFilterChip('Bathroom'),
          _buildFilterChip('Kitchen'),
          _buildFilterChip('Cleaning'),
          _buildFilterChip('Fashion'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool selected) {
          // Handle filter selection
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
        checkmarkColor: const Color(0xFF4CAF50),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildProductGrid() {
    final productController = Provider.of<ProductController>(context);
    
    if (productController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Use test products if no products are available
    List<ProductModel> productsToShow = productController.ecoFriendlyProducts;
    
    if (productsToShow.isEmpty) {
      // Test products data
      productsToShow = [
        ProductModel(
          id: 'test-product-1',
          name: 'Brosse à dents en bambou',
          brand: 'EcoSmile',
          description: 'Set de 4 brosses à dents en bambou biologique avec des poils au charbon.',
          price: 12.99,
          imageUrl: 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          categories: ['Bathroom', 'Personal Care'],
          isEcoFriendly: true,
          hasCoupon: false,
        ),
        ProductModel(
          id: 'test-product-2',
          name: 'Sacs de fruits et légumes réutilisables',
          brand: 'GreenCarry',
          description: 'Set de 5 sacs de fruits et légumes en mesh fabriqués à partir de matériaux recyclés. Parfait pour faire les courses.',
          price: 9.99,
          imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          categories: ['Kitchen', 'Shopping'],
          isEcoFriendly: true,
          discountPercentage: 15,
          hasCoupon: true,
        ),
        ProductModel(
          id: 'test-product-3',
          name: 'Bouteille d\'eau en acier inoxydable',
          brand: 'HydroEco',
          description: 'Bouteille d\'eau à double paroi isolée qui garde les boissons froides pendant 24 heures ou chaudes pendant 12 heures.',
          price: 24.99,
          imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          categories: ['Kitchen', 'Outdoor'],
          isEcoFriendly: true,
          hasCoupon: false,
        ),
        ProductModel(
          id: 'test-product-4',
          name: 'T-shirt en coton biologique',
          brand: 'NatureWear',
          description: 'T-shirt doux et respirant fabriqué à partir de 100% de coton biologique. Produit de manière éthique et teint avec des couleurs naturelles.',
          price: 19.99,
          imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          categories: ['Fashion', 'Clothing'],
          isEcoFriendly: true,
          discountPercentage: 10,
          hasCoupon: true,
        ),
      ];
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: productsToShow.length,
      itemBuilder: (context, index) {
        final product = productsToShow[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        // Navigate to product details
        _showProductDetails(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / 
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                                ),
                              );
                            },
                          )
                        : const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                  ),
                  // Overlay gradient for better text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Eco-friendly badge
                  if (product.isEcoFriendly)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  if (product.discountPercentage != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '-${product.discountPercentage!.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (product.hasCoupon)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.local_offer_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Coupon',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.discountPercentage != null)
                              Text(
                                '\$${(product.price * (1 + product.discountPercentage! / 100)).toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showAddToCartOptions(product),
                            child: const Icon(
                              Icons.add_shopping_cart_outlined,
                              color: Colors.white,
                              size: 18,
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

  void _showAddToCartOptions(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajouter au panier',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(),
            // Product info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Product image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? NetworkImage(product.imageUrl!)
                            : const AssetImage('assets/images/backgrounds/latest_article_background.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.brand,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (product.discountPercentage != null)
                              Text(
                                '\$${(product.price * (1 + product.discountPercentage! / 100)).toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            if (product.discountPercentage != null)
                              const SizedBox(width: 8),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF4CAF50),
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
            const SizedBox(height: 24),
            // Quantity selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quantité',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantityButton(Icons.remove),
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _buildQuantityButton(Icons.add),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    'Emballage sans plastique',
                    'Livré dans un emballage 100% recyclable',
                    Icons.eco_outlined,
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 8),
                  _buildOptionTile(
                    'Livraison express',
                    'Recevez votre commande en 24h',
                    Icons.local_shipping_outlined,
                    Colors.blue,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Add to cart button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} ajouté au panier'),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: 'Voir',
                        textColor: Colors.white,
                        onPressed: () {
                          // Navigate to cart
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Ajouter au panier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon),
        color: const Color(0xFF4CAF50),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildOptionTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: true,
            onChanged: (value) {},
            activeColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
    // Implement product details view navigation
  }

  Widget _buildProfilePage(AuthController authController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Leah Ward',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Eco-enthusiaste depuis 2023',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Handle logout
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.facebook, color: Colors.blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.pink),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.email_outlined, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          ' 2023 GreenApp. Tous droits réservés.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
