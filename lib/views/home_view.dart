import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:greens_app/widgets/carbon_impact_visualization.dart';
import 'package:greens_app/views/eco_challenge_view.dart';
import 'package:greens_app/models/product.dart';
import 'package:greens_app/views/product_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentCarouselIndex = 0;
  bool _isRefreshing = false;

  // Données simulées
  final Map<String, dynamic> _userData = {
    'name': 'Laura',
    'points': 2350,
    'level': 4,
    'impactReduction': 23, // en pourcentage
    'streak': 12, // jours consécutifs
    'carbonData': {
      'totalScore': 12.0,
      'carbonTonnesPerYear': 4.2,
      'detailedBreakdown': {
        'transport': 1.8,
        'alimentation': 1.2,
        'energie': 0.7,
        'consommation': 0.5,
      },
      'comparisons': {
        'vs_moyenne_nationale': 0.95,
        'vs_objectif_2030': 1.76,
        'equivalent_arbres': 210,
      },
      'recommendations': [
        'Privilégiez le vélo ou les transports en commun pour vos trajets courts',
        'Réduisez votre consommation de viande rouge à 1-2 fois par semaine',
        'Isolez mieux votre logement pour économiser l\'énergie',
        'Achetez des produits locaux et de saison',
      ],
    }
  };

  final List<Map<String, dynamic>> _ecoTips = [
    {
      'title': 'Économisez l\'eau',
      'content': 'Prenez des douches plus courtes pour économiser jusqu\'à 150 litres d\'eau par semaine.',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'action': 'En savoir plus',
    },
    {
      'title': 'Transport écologique',
      'content': 'Saviez-vous qu\'utiliser un vélo plutôt qu\'une voiture pour 10 km par jour réduit votre empreinte carbone de 1,3 tonne par an ?',
      'icon': Icons.directions_bike,
      'color': Colors.green,
      'action': 'Conseils transport',
    },
    {
      'title': 'Alimentation durable',
      'content': 'Consommer local et de saison peut réduire jusqu\'à 25% l\'impact carbone de votre alimentation.',
      'icon': Icons.eco,
      'color': Colors.teal,
      'action': 'Trouver des produits locaux',
    },
  ];

  final List<Map<String, dynamic>> _communityActions = [
    {
      'title': 'Nettoyage parc municipal',
      'date': '18 juin 2023',
      'participants': 42,
      'image': 'assets/images/parc.jpg',
    },
    {
      'title': 'Atelier compostage',
      'date': '25 juin 2023',
      'participants': 18,
      'image': 'assets/images/compostage.jpg',
    },
    {
      'title': 'Plantation d\'arbres',
      'date': '2 juillet 2023',
      'participants': 36,
      'image': 'assets/images/arbres.jpg',
    },
  ];

    // Liste des produits recommandés
  final List<Map<String, dynamic>> _recommendedProducts = [
    {
      'name': 'Gourde écologique',
      'description': 'Gourde réutilisable en acier inoxydable, sans BPA',
      'price': 19.99,
      'imageAsset': 'assets/images/products/botle.png',
      'category': 'Accessoires',
      'isEcoFriendly': true,
    },
    {
      'name': 'Brosse à dents bambou',
      'description': 'Brosse à dents en bambou biodégradable avec poils végétaux',
      'price': 6.50,
      'imageAsset': 'assets/images/products/brosse-a-dents-en-bois.png',
      'category': 'Hygiène',
      'isEcoFriendly': true,
    },
    {
      'name': 'Sacs fruits et légumes',
      'description': 'Lot de 5 sacs réutilisables en filet pour vos achats en vrac',
      'price': 9.99,
      'imageAsset': 'assets/images/products/panier.png',
      'category': 'Cuisine',
      'isEcoFriendly': true,
    },
    {
      'name': 'Coffret soin cheveux',
      'description': 'Coffret de soins capillaires naturels et écologiques',
      'price': 24.50,
      'imageAsset': 'assets/images/products/coffret-soin-cheveux.png',
      'category': 'Hygiène',
      'isEcoFriendly': true,
    },
    {
      'name': 'Sac en tissu',
      'description': 'Sac réutilisable en coton bio pour vos courses',
      'price': 12.99,
      'imageAsset': 'assets/images/products/sac.png',
      'category': 'Accessoires',
      'isEcoFriendly': true,
    },
    {
      'name': 'Dentifrice solide',
      'description': 'Dentifrice en comprimés à croquer, zéro déchet',
      'price': 7.90,
      'imageAsset': 'assets/images/products/packshot-dentifrice.png',
      'category': 'Hygiène',
      'isEcoFriendly': true,
    },
    {
      'name': 'Rouge à lèvres naturel',
      'description': 'Rouge à lèvres fabriqué à partir d\'ingrédients naturels',
      'price': 14.95,
      'imageAsset': 'assets/images/products/rouge-a-levres.png',
      'category': 'Cosmétiques',
      'isEcoFriendly': true,
    },
  ];
  
  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    // Simuler un chargement
    await Future.delayed(const Duration(seconds: 1));
    
    // Mise à jour fictive des données
    setState(() {
      _userData['points'] += 5;
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserStats(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Votre impact écologique'),
                    const SizedBox(height: 16),
                    CarbonImpactVisualization(
                      carbonData: _userData['carbonData'],
                      showDetailedBreakdown: true,
                      showComparisons: true,
                      onLearnMorePressed: () {
                        // Navigation vers page détaillée
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Conseils écologiques pour vous'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildTipsCarousel(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Vos défis en cours'),
                    const SizedBox(height: 16),
                    _buildChallengePreview(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Événements communautaires'),
                    const SizedBox(height: 16),
                    _buildCommunityEvents(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Produits recommandés'),
                    const SizedBox(height: 16),
                    _buildRecommendedProducts(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers une nouvelle action
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.green,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Bonjour, ${_userData['name']} 👋',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade800,
                Colors.green,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Navigation vers les notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {
            // Navigation vers le profil
          },
        ),
      ],
    );
  }

  Widget _buildUserStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Niveau',
            '${_userData['level']}',
            Icons.bar_chart,
            Colors.blue,
          ),
          _buildStatItem(
            'Points',
            '${_userData['points']}',
            Icons.emoji_events,
            Colors.amber,
          ),
          _buildStatItem(
            'Impact',
            '-${_userData['impactReduction']}%',
            Icons.eco,
            Colors.green,
          ),
          _buildStatItem(
            'Série',
            '${_userData['streak']} j',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: () {
            // Navigation vers page détaillée
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 20),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Voir plus'),
        ),
      ],
    );
  }

  Widget _buildTipsCarousel() {
    return Column(
      children: [
        // Remplacer temporairement le carousel par une ListView simple
        Container(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _ecoTips.length,
            itemBuilder: (context, index) {
              final tip = _ecoTips[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: tip['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tip['color'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            tip['icon'],
                            color: tip['color'],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tip['title'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: tip['color'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          tip['content'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            // Action
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(20, 20),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: tip['color'],
                          ),
                          child: Text(tip['action']),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Indicateurs de page
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _ecoTips.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == entry.key
                    ? Colors.green
                    : Colors.grey.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChallengePreview() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EcoChallengeView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bike,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transport écologique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Plus que 2 jours restants',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '75%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.75,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Continuez vos efforts !',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EcoChallengeView()),
                    );
                  },
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('Voir tous les défis'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(20, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityEvents() {
    return Column(
      children: [
        for (var event in _communityActions)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigation vers l'événement
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event['date'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event['participants']} participants',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedProducts() {
    return Column(
      children: [
        for (var product in _recommendedProducts)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final productData = product;
                    final productObj = Product(
                      id: productData['name'].hashCode.toString(),
                      name: productData['name'],
                      description: productData['description'],
                      price: productData['price'],
                      imageAsset: productData['imageAsset'],
                      category: productData['category'],
                      isEcoFriendly: productData['isEcoFriendly'],
                    );
                    
                    // Ajouter un retour haptique pour une meilleure expérience utilisateur
                    HapticFeedback.lightImpact();
                    
                    // Utiliser une transition PageRouteBuilder pour une animation personnalisée
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) => 
                          ProductDetailView(product: productObj),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    ).then((value) {
                      // Rafraîchir l'interface si nécessaire après le retour
                      if (value == true) {
                        // Afficher le panier ou effectuer une autre action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Panier mis à jour'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Hero(
                        tag: 'product-${product['name']}',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(product['imageAsset']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${product['price']} €',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  if (product['isEcoFriendly'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.eco,
                                            size: 12,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'Éco',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}