import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/controllers/article_controller.dart';
import 'package:greens_app/controllers/product_controller.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/utils/merchant_urls.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/widgets/eco_progress_tree.dart';
import 'package:greens_app/views/products/products_view.dart';
import 'package:greens_app/views/product_detail_view.dart';
import 'package:greens_app/services/favorites_service.dart';
import 'package:greens_app/services/eco_journey_service.dart';
import 'package:greens_app/services/eco_metrics_service.dart';
import 'package:greens_app/models/product.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/models/article_model.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

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
      final ecoGoalController = Provider.of<EcoGoalController>(context, listen: false);
      final communityController = Provider.of<CommunityController>(context, listen: false);
      
      articleController.getRecentArticles();
      productController.getEcoFriendlyProducts();
      
      // Charger les objectifs écologiques et défis communautaires
      final authController = Provider.of<AuthController>(context, listen: false);
      if (authController.currentUser != null) {
        ecoGoalController.getUserGoals(authController.currentUser!.uid);
        communityController.getUserChallenges(authController.currentUser!.uid);
      }
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
        title: Consumer<AuthController>(
          builder: (context, authController, _) {
            final String userName = authController.currentUser != null 
                ? "${authController.currentUser!.firstName ?? ''} ${authController.currentUser!.lastName ?? ''}"
                : "Invité";
            
            return Row(
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
                  userName.trim(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
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
          // Page d'accueil (index 0)
          _buildHomePage(),
          
          // Page des articles (index 1)
          const Center(child: Text('Page Articles - À implémenter')),
          
          // Page des produits (index 2)
          const Center(child: Text('Page Produits - À implémenter')),
          
          // Page de profil (index 3)
          _buildProfilePage(authController),
          
          // Page du chatbot (index 4)
          const Center(child: Text('Page Chatbot - À implémenter')),
        ],
      ),
      bottomNavigationBar: CustomMenu(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Gérer la navigation spéciale pour le chatbot (index 4)
          if (index == 4) {
            Navigator.pushNamed(context, AppRoutes.ecoChatbot);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // Section: Green tips of the day
            _buildSectionHeader('Green tips of the day'),
            const SizedBox(height: 16),
            _buildTipCard(),
            const SizedBox(height: 32),
            
            // Section: Latest articles
            _buildSectionHeader('Latest articles', showSeeAll: true),
            const SizedBox(height: 16),
            _buildLatestArticleCard(),
            const SizedBox(height: 32),
            
            // Section: Products you'll love
            _buildSectionHeader('Products you\'ll love', showSeeAll: true),
            const SizedBox(height: 16),
            _buildProductFilters(),
            const SizedBox(height: 16),
            _buildProductGrid(),
            const SizedBox(height: 32),
            
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
            const SizedBox(height: 40),
            
            // Chatbot section with background image
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/backgrounds/footer_background2.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                      decoration: const BoxDecoration(
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
                          _currentIndex = 4; // Index for chatbot page
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
            const SizedBox(height: 40),
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
          imageUrl: 'https://images.unsplash.com/photo-1508514177221-188c53300491e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
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
    List<Product> productsToShow = [];
    
    // Convertir les ProductModel en Product
    if (productController.ecoFriendlyProducts.isNotEmpty) {
      for (var productModel in productController.ecoFriendlyProducts) {
        // Créer un objet Product à partir du ProductModel
        productsToShow.add(
          Product(
            id: productModel.id,
            name: productModel.name,
            description: productModel.description ?? "",
            price: productModel.price,
            imageAsset: productModel.imageUrl,
            category: productModel.categories.isNotEmpty ? productModel.categories[0] : 'Divers',
            isEcoFriendly: productModel.isEcoFriendly,
            brand: productModel.brand ?? 'GreenMinds',
            ecoRating: 4.0, // Valeur par défaut
            certifications: [],
            ecoCriteria: {},
            nutritionalInfo: {},
            environmentalImpact: {},
            ingredients: [],
            packagingType: '',
            isRecyclable: true,
            origin: 'N/A',
            carbonFootprint: 0.0,
            manufacturingInfo: {},
            imageUrl: productModel.imageUrl ?? '',
          )
        );
      }
    }
    
    // Si la liste est toujours vide, utiliser les produits de test
    if (productsToShow.isEmpty) {
      productsToShow = [
        Product(
          id: 'product-1',
          name: 'Gourde écologique',
          description: 'Gourde réutilisable en acier inoxydable',
          price: 19.99,
          imageAsset: 'assets/images/products/botle.png',
          category: 'Accessoires',
          isEcoFriendly: true,
          brand: 'GreenMinds',
          ecoRating: 4.0,
          certifications: [],
          ecoCriteria: {},
          nutritionalInfo: {},
          environmentalImpact: {},
          ingredients: [],
          packagingType: '',
          isRecyclable: true,
          origin: 'N/A',
          carbonFootprint: 0.0,
          manufacturingInfo: {},
          imageUrl: 'assets/images/products/botle.png',
        ),
        Product(
          id: 'product-2',
          name: 'Brosse à dents bambou',
          description: 'Brosse à dents biodégradable',
          price: 6.50,
          imageAsset: 'assets/images/products/brosse-a-dents-en-bois.png',
          category: 'Hygiène',
          isEcoFriendly: true,
          brand: 'GreenMinds',
          ecoRating: 4.0,
          certifications: [],
          ecoCriteria: {},
          nutritionalInfo: {},
          environmentalImpact: {},
          ingredients: [],
          packagingType: '',
          isRecyclable: true,
          origin: 'N/A',
          carbonFootprint: 0.0,
          manufacturingInfo: {},
          imageUrl: 'assets/images/products/brosse-a-dents-en-bois.png',
        ),
        Product(
          id: 'product-3',
          name: 'Sacs fruits et légumes',
          description: 'Lot de 5 sacs réutilisables',
          price: 9.99,
          imageAsset: 'assets/images/products/panier.png',
          category: 'Cuisine',
          isEcoFriendly: true,
          brand: 'GreenMinds',
          ecoRating: 4.0,
          certifications: [],
          ecoCriteria: {},
          nutritionalInfo: {},
          environmentalImpact: {},
          ingredients: [],
          packagingType: '',
          isRecyclable: true,
          origin: 'N/A',
          carbonFootprint: 0.0,
          manufacturingInfo: {},
          imageUrl: 'assets/images/products/panier.png',
        ),
        Product(
          id: 'product-4',
          name: 'Coffret soin cheveux',
          description: 'Soins capillaires naturels',
          price: 24.50,
          imageAsset: 'assets/images/products/coffret-soin-cheveux.png',
          category: 'Hygiène',
          isEcoFriendly: true,
          brand: 'GreenMinds',
          ecoRating: 4.0,
          certifications: [],
          ecoCriteria: {},
          nutritionalInfo: {},
          environmentalImpact: {},
          ingredients: [],
          packagingType: '',
          isRecyclable: true,
          origin: 'N/A',
          carbonFootprint: 0.0,
          manufacturingInfo: {},
          imageUrl: 'assets/images/products/coffret-soin-cheveux.png',
        ),
      ];
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55, // Modifié de 0.7 à 0.55 pour donner plus d'espace vertical
        crossAxisSpacing: 12,
        mainAxisSpacing: 16, // Augmenté l'espacement vertical
      ),
      itemCount: math.min(4, productsToShow.length), // Limiter à 4 produits maximum
      itemBuilder: (context, index) {
        final product = productsToShow[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
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
                    height: 120, // Réduit de 130px à 120px
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: product.imageAsset != null && product.imageAsset!.isNotEmpty
                        ? Image.asset(
                            product.imageAsset!,
                            fit: BoxFit.cover,
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
                ],
              ),
            ),
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8), // Réduit de 10px à 8px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.category,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10, // Réduit de 11px à 10px
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Réduit de 13px à 12px
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 10, // Réduit de 11px à 10px
                      ),
                      maxLines: 1, // Réduit de 2 à 1 ligne
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14, // Réduit de 16px à 14px
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6), // Réduit de 8px à 6px
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(10), // Réduit de 12px à 10px
                          ),
                          child: InkWell(
                            onTap: () => _showAddToCartOptions(product),
                            child: const Icon(
                              Icons.add_shopping_cart_outlined,
                              color: Colors.white,
                              size: 16, // Réduit de 18px à 16px
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

  void _showAddToCartOptions(Product product) {
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
                    'Ajouter aux favoris',
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
                      image: product.imageAsset != null && product.imageAsset!.isNotEmpty
                          ? DecorationImage(
                              image: AssetImage(product.imageAsset!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/backgrounds/latest_article_background.png'),
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
                          product.category,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
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
            // Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Bouton Acheter directement
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Récupérer l'URL du marchand pour ce produit
                        final merchantInfo = MerchantUrls.getMerchantForProduct(product.id);
                        if (merchantInfo != null) {
                          _openMerchantUrl(merchantInfo.url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Aucun marchand disponible pour ce produit'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Acheter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bouton Ajouter aux favoris
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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
                          merchantUrl: product.merchantUrl,
                        );
                        
                        // Ajouter aux favoris
                        Provider.of<FavoritesService>(context, listen: false).addItem(productModel);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ajouté aux favoris'),
                            backgroundColor: const Color(0xFF4CAF50),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            action: SnackBarAction(
                              label: 'Voir',
                              textColor: Colors.white,
                              onPressed: () {
                                // Naviguer vers la vue des favoris
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProductsView()),
                                );
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
                      ),
                      child: const Text(
                        'Ajouter aux favoris',
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
          ],
        ),
      ),
    );
  }

  // Fonction pour ouvrir l'URL du marchand
  Future<void> _openMerchantUrl(String url) async {
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

  void _showProductDetails(Product product) {
    // Naviguer vers la vue détaillée du produit avec une transition fluide
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProductDetailView(
            product: product,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      // Rafraîchir l'interface après le retour de la vue détaillée
      setState(() {});
    });
  }

  Widget _buildProfilePage(AuthController authController) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section d'en-tête de profil avec image de couverture
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Image de couverture
              Container(
                height: 160, // Réduit de 180px à 160px
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/backgrounds/mountain_background.png'),
                    fit: BoxFit.cover,
                  ),
                  color: Color(0xFF4CAF50),
                ),
              ),
              
              // Photo de profil
              Positioned(
                bottom: -40, // Réduit de -50px à -40px
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3), // Réduit de 4px à 3px
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 40, // Réduit de 50px à 40px
                    backgroundImage: AssetImage('assets/images/profile/profile_placeholder.png'),
                  ),
                ),
              ),
              
              // Bouton d'édition du profil
              Positioned(
                bottom: -25, // Ajusté de -30px à -25px
                right: 20,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigation vers l'édition du profil
                  },
                  icon: const Icon(Icons.edit, size: 14), // Réduit de 16px à 14px
                  label: const Text('Éditer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4CAF50),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Réduit le padding
                  ),
                ),
              ),
            ],
          ),
          
          // Espace pour la photo de profil
          const SizedBox(height: 50), // Réduit de 60px à 50px
          
          // Informations principales
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Leah Ward',
                  style: TextStyle(
                    fontSize: 22, // Réduit de 24px à 22px
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3140),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Réduit vertical de 4px à 3px
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.eco,
                            size: 12, // Réduit de 14px à 12px
                            color: Color(0xFF4CAF50),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Éco-enthusiaste',
                            style: TextStyle(
                              fontSize: 11, // Réduit de 12px à 11px
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Membre depuis 2023',
                      style: TextStyle(
                        fontSize: 11, // Réduit de 12px à 11px
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20), // Réduit de 24px à 20px
          
          // Statistiques d'impact
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14), // Réduit de 16px à 14px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.bar_chart,
                          color: Color(0xFF1F3140),
                          size: 18, // Ajout d'une taille d'icône plus petite
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Votre impact écologique',
                          style: TextStyle(
                            fontSize: 15, // Réduit de 16px à 15px
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F3140),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14), // Réduit de 16px à 14px
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('28', 'Produits\nécologiques', Icons.shopping_bag_outlined),
                        _buildStatItem('12.5kg', 'CO₂\névité', Icons.eco_outlined),
                        _buildStatItem('85%', 'Score\nvert', Icons.insert_chart_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20), // Réduit de 24px à 20px
          
          // Badges et réalisations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Badges et réalisations',
                      style: TextStyle(
                        fontSize: 16, // Réduit de 18px à 16px
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3140),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Réduit le padding
                      ),
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 13, // Ajout d'une taille de police plus petite
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Réduit de 12px à 10px
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBadge('Débutant', Icons.eco_outlined, 'Premier pas écologique'),
                      _buildBadge('Recycleur', Icons.recycling, '10 produits recyclables'),
                      _buildBadge('Expert', Icons.star, '30 jours d\'activité'),
                      _buildBadge('Champion', Icons.military_tech, '50 articles consultés'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20), // Réduit de 24px à 20px
          
          // Favoris récents
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vos favoris récents',
                      style: TextStyle(
                        fontSize: 16, // Réduit de 18px à 16px
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3140),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Réduit le padding
                      ),
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 13, // Ajout d'une taille de police plus petite
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Réduit de 12px à 10px
                _buildFavoritesPreview(),
              ],
            ),
          ),
          
          const SizedBox(height: 20), // Réduit de 24px à 20px
          
          // Menu de paramètres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6), // Réduit de 8px à 6px
                child: Column(
                  children: [
                    _buildSettingsItem(
                      'Paramètres du compte',
                      'Gérer vos informations personnelles',
                      Icons.person_outline,
                      () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsItem(
                      'Notifications',
                      'Gérer vos préférences de notification',
                      Icons.notifications_none,
                      () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsItem(
                      'Confidentialité et sécurité',
                      'Gérer vos paramètres de confidentialité',
                      Icons.lock_outline,
                      () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsItem(
                      'Aide et support',
                      'Obtenir de l\'aide ou contacter le support',
                      Icons.help_outline,
                      () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsItem(
                      'Déconnexion',
                      'Se déconnecter de votre compte',
                      Icons.logout,
                      () {
                        authController.signOut();
                      },
                      textColor: Colors.red,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30), // Réduit de 40px à 30px
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3140),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildBadge(String title, IconData icon, String description) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3140),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFavoritesPreview() {
    // Simuler quelques produits favoris pour la prévisualisation
    List<Product> favorites = [
      Product(
        id: 'product-1',
        name: 'Gourde écologique',
        description: 'Gourde réutilisable en acier',
        price: 19.99,
        imageAsset: 'assets/images/products/botle.png',
        category: 'Accessoires',
        isEcoFriendly: true,
        brand: 'GreenMinds',
        ecoRating: 4.0,
        certifications: [],
        ecoCriteria: {},
        nutritionalInfo: {},
        environmentalImpact: {},
        ingredients: [],
        packagingType: '',
        isRecyclable: true,
        origin: 'N/A',
        carbonFootprint: 0.0,
        manufacturingInfo: {},
        imageUrl: 'assets/images/products/botle.png',
      ),
      Product(
        id: 'product-2',
        name: 'Brosse à dents bambou',
        description: 'Brosse à dents biodégradable',
        price: 6.50,
        imageAsset: 'assets/images/products/brosse-a-dents-en-bois.png',
        category: 'Hygiène',
        isEcoFriendly: true,
        brand: 'EcoBrush',
        ecoRating: 4.5,
        certifications: [],
        ecoCriteria: {},
        nutritionalInfo: {},
        environmentalImpact: {},
        ingredients: [],
        packagingType: '',
        isRecyclable: true,
        origin: 'N/A',
        carbonFootprint: 0.0,
        manufacturingInfo: {},
        imageUrl: 'assets/images/products/brosse-a-dents-en-bois.png',
      ),
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final product = favorites[index];
          return GestureDetector(
            onTap: () => _showProductDetails(product),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
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
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.asset(
                      product.imageAsset!,
                      width: 70,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F3140),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Éco',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.bold,
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
        },
      ),
    );
  }
  
  Widget _buildSettingsItem(String title, String subtitle, IconData icon, VoidCallback onTap, {
    Color iconColor = const Color(0xFF1F3140),
    Color textColor = const Color(0xFF1F3140),
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    const SizedBox(height: 2),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
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
