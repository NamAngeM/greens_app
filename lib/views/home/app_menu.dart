import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // En-tête du menu
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: AppColors.primaryColor,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24), // Pour éviter le chevauchement avec la barre d'état
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authController.currentUser != null 
                    ? (authController.currentUser?.firstName != null 
                       ? "${authController.currentUser?.firstName} ${authController.currentUser?.lastName ?? ''}"
                       : authController.currentUser?.email ?? 'Utilisateur')
                    : 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authController.currentUser?.email ?? 'email@example.com',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Options du menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context, 
                    'Accueil', 
                    Icons.home, 
                    AppRoutes.home,
                  ),
                  _buildMenuItem(
                    context, 
                    'Mon profil', 
                    Icons.person, 
                    AppRoutes.profile,
                  ),
                  _buildMenuItem(
                    context, 
                    'Mes objectifs', 
                    Icons.eco, 
                    AppRoutes.goals,
                  ),
                  _buildMenuItem(
                    context, 
                    'Calculateur d\'empreinte', 
                    Icons.calculate, 
                    AppRoutes.carbonCalculator,
                  ),
                  _buildMenuItem(
                    context, 
                    'Tableau de bord carbone', 
                    Icons.bar_chart, 
                    AppRoutes.carbonDashboard,
                  ),
                  _buildMenuItem(
                    context, 
                    'Scanner de produits', 
                    Icons.qr_code_scanner, 
                    AppRoutes.productScanner,
                  ),
                  _buildMenuItem(
                    context, 
                    'Badges', 
                    Icons.military_tech, 
                    AppRoutes.badges,
                  ),
                  _buildMenuItem(
                    context, 
                    'Communauté', 
                    Icons.people, 
                    AppRoutes.community,
                  ),
                  _buildMenuItem(
                    context, 
                    'Produits écologiques', 
                    Icons.shopping_bag, 
                    AppRoutes.products,
                  ),
                  _buildMenuItem(
                    context, 
                    'Articles et conseils', 
                    Icons.article, 
                    AppRoutes.articles,
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context, 
                    'Paramètres', 
                    Icons.settings, 
                    AppRoutes.settings,
                  ),
                  _buildMenuItem(
                    context, 
                    'Aide', 
                    Icons.help, 
                    AppRoutes.help,
                  ),
                  _buildMenuItem(
                    context, 
                    'Politique de confidentialité', 
                    Icons.privacy_tip, 
                    AppRoutes.privacyPolicy,
                  ),
                  _buildMenuItem(
                    context, 
                    'Mentions légales', 
                    Icons.gavel, 
                    AppRoutes.legalNotice,
                  ),
                ],
              ),
            ),
            
            // Bouton de déconnexion
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  // Afficher une boîte de dialogue de confirmation
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    await authController.signOut();
                    // Naviguer vers l'écran de connexion après déconnexion
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login, 
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(
    BuildContext context, 
    String title, 
    IconData icon, 
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      onTap: () {
        // Fermer le drawer avant de naviguer
        Navigator.of(context).pop();
        
        // Ne pas naviguer si nous sommes déjà sur cette page
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.of(context).pushNamed(route);
        }
      },
    );
  }
} 