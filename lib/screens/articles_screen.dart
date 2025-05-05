import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/article_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/widgets/bottom_navigation.dart';
import 'package:greens_app/widgets/menu.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({Key? key}) : super(key: key);
  
  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> with AutomaticKeepAliveClientMixin {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Ecology', 'Waste', 'Energy', 'Food'];

  @override
  void initState() {
    super.initState();
    // Charger les articles au démarrage si la liste est vide
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articleController = Provider.of<ArticleController>(context, listen: false);
      if (articleController.articles.isEmpty) {
        articleController.fetchArticles();
      }
    });
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 24),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primaryColor),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.eco, color: AppColors.primaryColor),
              title: const Text('Objectifs écologiques'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/goals');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryColor),
              title: const Text('Assistant écologique'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/eco_chatbot');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.primaryColor),
              title: const Text('Tableau de bord carbone'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/carbon_dashboard');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.primaryColor),
              title: const Text('Aide et support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire pour AutomaticKeepAliveClientMixin
    
    return Consumer<ArticleController>(
      builder: (context, articleController, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Stack(
            children: [
              // Main content
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec "Explore a green lifestyle" et icône de paramètres
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Explore a green lifestyle',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              // Navigation vers les paramètres
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Titre "Our latest articles"
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        'Our latest articles',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Filtres de catégories
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category == _selectedCategory;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                // Filtrer les articles par catégorie
                                if (category == 'All') {
                                  articleController.fetchArticles();
                                } else {
                                  articleController.getArticlesByCategory(category);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.green : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Articles
                    Expanded(
                      child: Stack(
                        children: [
                          // Section 1: Tips avec background spécifique
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/backgrounds/tips_background.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Eco Tips',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Daily suggestions to help you live greener',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigation vers la page des tips
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('View All Tips'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Section 2: Latest Articles avec background spécifique
                          Positioned(
                            top: 180,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/backgrounds/latest_articles_background.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Latest Articles',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'See All',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Liste d'articles
                                  Expanded(
                                    child: articleController.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.green,
                                          ),
                                        )
                                      : articleController.error.isNotEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  size: 48,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Erreur: ${articleController.error}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () => articleController.fetchArticles(),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                  ),
                                                  child: const Text('Réessayer'),
                                                ),
                                              ],
                                            ),
                                          )
                                        : articleController.articles.isNotEmpty
                                          ? ListView.builder(
                                              physics: const BouncingScrollPhysics(),
                                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                              itemCount: articleController.articles.length,
                                              itemBuilder: (context, index) {
                                                final article = articleController.articles[index];
                                                // Afficher les articles en rangées de 2 pour les grands écrans
                                                if (index % 2 == 0 && index + 1 < articleController.articles.length) {
                                                  final nextArticle = articleController.articles[index + 1];
                                                  return Row(
                                                    children: [
                                                      Expanded(
                                                        child: _buildArticleCard(
                                                          title: article.title,
                                                          imageUrl: article.imageUrl,
                                                          duration: '${article.readTimeMinutes} Min',
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: _buildArticleCard(
                                                          title: nextArticle.title,
                                                          imageUrl: nextArticle.imageUrl,
                                                          duration: '${nextArticle.readTimeMinutes} Min',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else if (index % 2 == 0) {
                                                  // Dernier article s'il y a un nombre impair
                                                  return _buildArticleCard(
                                                    title: article.title,
                                                    imageUrl: article.imageUrl,
                                                    duration: '${article.readTimeMinutes} Min',
                                                  );
                                                }
                                                // Skip les articles pairs car ils sont déjà affichés
                                                return const SizedBox.shrink();
                                              },
                                            )
                                          : ListView(
                                              physics: const BouncingScrollPhysics(),
                                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _buildArticleCard(
                                                        title: '5 easy steps to go green today',
                                                        imageUrl: 'assets/images/article1.jpg',
                                                        duration: '20 Min',
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: _buildArticleCard(
                                                        title: 'Eco hacks for daily life',
                                                        imageUrl: 'assets/images/article2.jpg',
                                                        duration: '10 Min',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                _buildArticleCard(
                                                  title: 'How to reduce your carbon footprint',
                                                  imageUrl: 'assets/images/article3.jpg',
                                                  duration: '15 Min',
                                                ),
                                              ],
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Logo et footer en bas
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/backgrounds/footer_background2.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Logo Greens
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/logo/green_minds_logo.png',
                                            width: 80,
                                            height: 80,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'sustainable future',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Bouton chatbot
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, AppRoutes.ecoChatbot);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Discuss with our chatbot',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Liens légaux
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'Legal Notices',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          '|',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomMenu(
            currentIndex: 1,
            onTap: (index) {
              // La navigation est gérée à l'intérieur de CustomMenu
            },
          ),
        );
      },
    );
  }

  Widget _buildArticleCard({
    required String title,
    String? imageUrl,
    required String duration,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          // Navigation vers le détail de l'article
        },
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Image de fond
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? Image.asset(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              
              // Overlay gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Contenu (durée et titre)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Durée
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Titre
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}