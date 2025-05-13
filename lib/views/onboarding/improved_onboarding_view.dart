import 'package:flutter/material.dart';
import 'package:greens_app/models/user_preferences_model.dart';
import 'package:greens_app/services/user_preferences_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImprovedOnboardingView extends StatefulWidget {
  const ImprovedOnboardingView({Key? key}) : super(key: key);

  @override
  State<ImprovedOnboardingView> createState() => _ImprovedOnboardingViewState();
}

class _ImprovedOnboardingViewState extends State<ImprovedOnboardingView> {
  final PageController _pageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentPage = 0;
  
  // Intérêts écologiques sélectionnés par l'utilisateur
  List<String> _selectedInterests = [];
  
  // Catégories préférées
  List<String> _selectedCategories = [];
  
  // Habitudes de vie
  Map<String, String> _lifestyleChoices = {
    'transportation': 'none',
    'diet': 'none',
    'housing': 'none',
  };
  
  // Difficultés préférées pour les défis
  String _selectedDifficulty = 'débutant';
  
  // Préférences sociales
  bool _shareOnSocial = false;
  List<String> _socialNetworks = [];
  
  // Indication d'onboarding complété
  bool _onboardingCompleted = false;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navigation vers la page suivante
  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }
  
  // Terminer l'onboarding et enregistrer les préférences
  Future<void> _finishOnboarding() async {
    setState(() {
      _onboardingCompleted = true;
    });
    
    // Enregistrer les préférences utilisateur
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final preferencesService = Provider.of<UserPreferencesService>(context, listen: false);
      
      final userPreferences = UserPreferencesModel(
        ecoInterests: _selectedInterests,
        favoriteCategories: _selectedCategories,
        lifestylePreferences: _lifestyleChoices.map((key, value) => MapEntry(key, value)),
        challengeDifficulty: _selectedDifficulty,
        shareOnSocialMedia: _shareOnSocial,
        connectedSocialNetworks: _socialNetworks,
      );
      
      await _firestore.collection('user_preferences').doc(userId).set(
        userPreferences.toJson(),
        SetOptions(merge: true),
      );
      
      // Marquer l'onboarding comme terminé
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
    }
    
    // Naviguer vers l'écran d'accueil
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
  
  // Ajouter ou supprimer un intérêt de la sélection
  void _toggleInterest(String interestId) {
    setState(() {
      if (_selectedInterests.contains(interestId)) {
        _selectedInterests.remove(interestId);
      } else {
        _selectedInterests.add(interestId);
      }
    });
  }
  
  // Ajouter ou supprimer une catégorie de la sélection
  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }
  
  // Définir le choix de mode de transport
  void _setTransportationChoice(String choice) {
    setState(() {
      _lifestyleChoices['transportation'] = choice;
    });
  }
  
  // Définir le choix de régime alimentaire
  void _setDietChoice(String choice) {
    setState(() {
      _lifestyleChoices['diet'] = choice;
    });
  }
  
  // Définir le choix de logement
  void _setHousingChoice(String choice) {
    setState(() {
      _lifestyleChoices['housing'] = choice;
    });
  }
  
  // Activer/désactiver le partage sur les réseaux
  void _toggleSocialSharing(bool value) {
    setState(() {
      _shareOnSocial = value;
    });
  }
  
  // Ajouter/supprimer un réseau social
  void _toggleSocialNetwork(String network) {
    setState(() {
      if (_socialNetworks.contains(network)) {
        _socialNetworks.remove(network);
      } else {
        _socialNetworks.add(network);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _onboardingCompleted 
          ? _buildCompletionScreen()
          : Column(
            children: [
              // Barre de progression
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
              
              // Pages d'onboarding
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // Page 1: Bienvenue
                    _buildWelcomePage(),
                    
                    // Page 2: Intérêts écologiques
                    _buildInterestsPage(),
                    
                    // Page 3: Catégories préférées
                    _buildCategoriesPage(),
                    
                    // Page 4: Mode de transport
                    _buildTransportationPage(),
                    
                    // Page 5: Habitudes alimentaires
                    _buildDietPage(),
                    
                    // Page 6: Difficulté des défis
                    _buildChallengeDifficultyPage(),
                    
                    // Page 7: Partage social
                    _buildSocialSharingPage(),
                  ],
                ),
              ),
              
              // Boutons de navigation
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage > 0
                        ? TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text(
                              'Précédent',
                              style: TextStyle(
                                color: AppColors.textLightColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox(width: 80),
                    
                    CustomButton(
                      text: _currentPage < 6 ? 'Suivant' : 'Terminer',
                      onPressed: _nextPage,
                      width: 120,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
  
  // Page de bienvenue
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco,
              size: 70,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          
          const Text(
            'Bienvenue sur Green Minds',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Nous allons vous guider à travers quelques étapes pour personnaliser votre expérience.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Ensemble, rendons la planète plus verte !',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Page des intérêts écologiques
  Widget _buildInterestsPage() {
    final interestsList = UserPreferencesModel.getAllEcoInterests();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos intérêts écologiques',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Sélectionnez les sujets qui vous intéressent le plus :',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: interestsList.map((interest) {
              final isSelected = _selectedInterests.contains(interest['id']);
              return GestureDetector(
                onTap: () => _toggleInterest(interest['id']),
                child: Chip(
                  label: Text(interest['name']),
                  backgroundColor: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  // Page des catégories préférées
  Widget _buildCategoriesPage() {
    final categories = UserPreferencesModel.getAllCategories();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contenus préférés',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Quelles catégories de contenu vous intéressent le plus ?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((category) {
              final isSelected = _selectedCategories.contains(category['id']);
              return GestureDetector(
                onTap: () => _toggleCategory(category['id']),
                child: Chip(
                  label: Text(category['name']),
                  backgroundColor: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  // Page du mode de transport
  Widget _buildTransportationPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos habitudes de transport',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Quel est votre mode de transport le plus fréquent ?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildTransportOption(
            'car',
            'Voiture individuelle',
            Icons.directions_car,
            'Vous utilisez principalement une voiture pour vos déplacements.',
          ),
          
          _buildTransportOption(
            'public',
            'Transports en commun',
            Icons.directions_bus,
            'Vous privilégiez le bus, métro, train pour vous déplacer.',
          ),
          
          _buildTransportOption(
            'bike',
            'Vélo',
            Icons.directions_bike,
            'Vous utilisez régulièrement le vélo pour vos trajets.',
          ),
          
          _buildTransportOption(
            'walk',
            'Marche à pied',
            Icons.directions_walk,
            'Vous vous déplacez souvent à pied quand c\'est possible.',
          ),
          
          _buildTransportOption(
            'mix',
            'Mixte / Multimodal',
            Icons.swap_horiz,
            'Vous combinez plusieurs modes de transport selon les besoins.',
          ),
        ],
      ),
    );
  }
  
  // Option de transport (widget réutilisable)
  Widget _buildTransportOption(String id, String title, IconData icon, String description) {
    final isSelected = _lifestyleChoices['transportation'] == id;
    
    return GestureDetector(
      onTap: () => _setTransportationChoice(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
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
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
  
  // Page des habitudes alimentaires
  Widget _buildDietPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos habitudes alimentaires',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Quel type d\'alimentation adoptez-vous principalement ?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Options alimentaires (similaire à transport)
          _buildDietOption(
            'omnivore',
            'Omnivore',
            Icons.restaurant,
            'Vous mangez de tout, viande et légumes.',
          ),
          
          _buildDietOption(
            'flexitarian',
            'Flexitarien',
            Icons.grass,
            'Vous limitez votre consommation de viande.',
          ),
          
          _buildDietOption(
            'vegetarian',
            'Végétarien',
            Icons.eco,
            'Vous ne mangez pas de viande, mais consommez des produits laitiers/œufs.',
          ),
          
          _buildDietOption(
            'vegan',
            'Végétalien',
            Icons.spa,
            'Vous ne consommez aucun produit d\'origine animale.',
          ),
          
          _buildDietOption(
            'other',
            'Autre régime',
            Icons.restaurant_menu,
            'Vous suivez un régime particulier (sans gluten, etc.).',
          ),
        ],
      ),
    );
  }
  
  // Option alimentaire (widget réutilisable)
  Widget _buildDietOption(String id, String title, IconData icon, String description) {
    final isSelected = _lifestyleChoices['diet'] == id;
    
    return GestureDetector(
      onTap: () => _setDietChoice(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
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
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
  
  // Page de difficulté des défis
  Widget _buildChallengeDifficultyPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Niveau de difficulté',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Quel niveau de difficulté préférez-vous pour vos défis écologiques ?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Options de difficulté
          _buildDifficultyOption(
            'débutant',
            'Débutant',
            Icons.emoji_events_outlined,
            'Défis simples, parfaits pour commencer.',
          ),
          
          _buildDifficultyOption(
            'intermédiaire',
            'Intermédiaire',
            Icons.emoji_events,
            'Défis plus engageants nécessitant plus d\'effort.',
          ),
          
          _buildDifficultyOption(
            'avancé',
            'Avancé',
            Icons.stars,
            'Défis ambitieux pour un impact environnemental maximal.',
          ),
          
          _buildDifficultyOption(
            'adaptatif',
            'Adaptatif',
            Icons.auto_awesome,
            'Progression automatique selon votre évolution.',
          ),
        ],
      ),
    );
  }
  
  // Option de difficulté (widget réutilisable)
  Widget _buildDifficultyOption(String id, String title, IconData icon, String description) {
    final isSelected = _selectedDifficulty == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
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
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
  
  // Page de partage social
  Widget _buildSocialSharingPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partage social',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Souhaitez-vous partager vos accomplissements sur les réseaux sociaux ?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Switch pour activer/désactiver le partage
          SwitchListTile(
            title: const Text(
              'Activer le partage social',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Vous pourrez célébrer vos succès écologiques avec votre communauté',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            value: _shareOnSocial,
            onChanged: _toggleSocialSharing,
            activeColor: AppColors.primaryColor,
          ),
          
          if (_shareOnSocial) ...[
            const SizedBox(height: 16),
            const Text(
              'Sélectionnez vos réseaux sociaux :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            
            // Options de réseaux sociaux
            CheckboxListTile(
              title: const Text('Facebook'),
              value: _socialNetworks.contains('facebook'),
              onChanged: (value) => _toggleSocialNetwork('facebook'),
              activeColor: AppColors.primaryColor,
            ),
            CheckboxListTile(
              title: const Text('Instagram'),
              value: _socialNetworks.contains('instagram'),
              onChanged: (value) => _toggleSocialNetwork('instagram'),
              activeColor: AppColors.primaryColor,
            ),
            CheckboxListTile(
              title: const Text('Twitter/X'),
              value: _socialNetworks.contains('twitter'),
              onChanged: (value) => _toggleSocialNetwork('twitter'),
              activeColor: AppColors.primaryColor,
            ),
            CheckboxListTile(
              title: const Text('LinkedIn'),
              value: _socialNetworks.contains('linkedin'),
              onChanged: (value) => _toggleSocialNetwork('linkedin'),
              activeColor: AppColors.primaryColor,
            ),
          ],
        ],
      ),
    );
  }
  
  // Écran de chargement/complétion
  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Tout est prêt !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Votre expérience a été personnalisée selon vos préférences. Votre parcours écologique commence maintenant.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
} 