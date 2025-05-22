import 'package:flutter/material.dart';
import 'package:greens_app/widgets/bottom_navigation.dart';
import 'package:greens_app/screens/articles_screen.dart';
import 'package:greens_app/views/chatbot/chatbot_view.dart';
import 'package:greens_app/views/products/products_view.dart';
import 'package:greens_app/views/profile/profile_view.dart';
import 'package:greens_app/utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  
  // Liste des pages/écrans correspondant à chaque onglet de navigation
  final List<Widget> _screens = [
    const _HomeTab(),
    const ArticlesScreen(),
    const ChatbotView(),
    const ProductsView(),
    const ProfileView(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Utiliser IndexedStack pour préserver l'état des pages
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          
          // Bouton Plus en bas à droite
          Positioned(
            right: 24,
            bottom: 100,
            child: MoreButton(
              onTap: _showMoreOptions,
            ),
          ),
        ],
      ),
      // Implémentation de la barre de navigation
      bottomNavigationBar: BottomNavWithFloatingLogo(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        onLogoTap: () {
          setState(() {
            _selectedIndex = 2; // Index de GreenMinds (logo)
          });
        },
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true; // Garder l'état vivant
}

// Optimisation des onglets individuels pour qu'ils préservent leur état
class _HomeTab extends StatefulWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Sam Green',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Green tips of the day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            // Contenu de l'écran d'accueil...
          ],
        ),
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}

class _GreenMindsTab extends StatefulWidget {
  const _GreenMindsTab({Key? key}) : super(key: key);

  @override
  State<_GreenMindsTab> createState() => _GreenMindsTabState();
}

class _GreenMindsTabState extends State<_GreenMindsTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'g',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Green Minds',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}

class _ProduitsTab extends StatefulWidget {
  const _ProduitsTab({Key? key}) : super(key: key);

  @override
  State<_ProduitsTab> createState() => _ProduitsTabState();
}

class _ProduitsTabState extends State<_ProduitsTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 18),
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
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Our latest products',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Contenu des produits...
          ],
        ),
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({Key? key}) : super(key: key);

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Center(child: Text('Profile'));
  }
  
  @override
  bool get wantKeepAlive => true;
} 