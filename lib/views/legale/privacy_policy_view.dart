import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Politique de confidentialité de GreenMinds',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dernière mise à jour: 1er avril 2023',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'La protection de vos données personnelles est notre priorité. Cette politique de confidentialité explique comment GreenMinds collecte, utilise et protège vos informations lorsque vous utilisez notre application.',
            ),
            _buildSection(
              'Données collectées',
              'Nous collectons les informations suivantes pour vous offrir une expérience personnalisée et vous aider à réduire votre empreinte carbone:\n\n'
              '• Données personnelles: nom, adresse e-mail, et profil de base.\n'
              '• Données de calcul d\'empreinte carbone: consommation énergétique, habitudes alimentaires, transport et consommation générale.\n'
              '• Données d\'utilisation: produits scannés, défis complétés, et interactions avec l\'application.\n'
              '• Données de localisation (avec votre consentement): pour suggérer des alternatives locales et calculer précisément l\'impact de vos déplacements.',
            ),
            _buildSection(
              'Utilisation des données',
              'Vos données sont utilisées pour:\n\n'
              '• Calculer et suivre votre empreinte carbone personnelle.\n'
              '• Vous fournir des recommandations personnalisées pour réduire votre impact environnemental.\n'
              '• Améliorer nos services et développer de nouvelles fonctionnalités basées sur des données agrégées anonymisées.\n'
              '• Étudier les tendances globales et l\'efficacité des actions écologiques (données toujours anonymisées).',
            ),
            _buildSection(
              'Confidentialité des données écologiques',
              'Nous comprenons que vos données environnementales révèlent des aspects personnels de votre mode de vie. C\'est pourquoi:\n\n'
              '• Vos données individuelles ne sont jamais partagées avec des tiers sans votre consentement explicite.\n'
              '• Les statistiques communautaires et les classements sont toujours présentés de manière anonyme.\n'
              '• Vous pouvez choisir quelles données partager dans les défis communautaires.',
            ),
            _buildSection(
              'Stockage et sécurité',
              'Toutes vos données sont stockées sur des serveurs sécurisés avec chiffrement. Nous utilisons Firebase (Google Cloud) pour héberger vos données, conformément aux normes de sécurité les plus strictes.\n\n'
              'Les données sont également stockées localement sur votre appareil pour permettre l\'utilisation hors ligne. Ces données sont synchronisées lorsque vous vous reconnectez à Internet.',
            ),
            _buildSection(
              'Mode hors ligne et synchronisation',
              'Notre application fonctionne en mode hors ligne pour vous permettre de calculer votre empreinte carbone et scanner des produits même sans connexion Internet. Lors de la reconnexion, vos données sont automatiquement synchronisées avec nos serveurs sécurisés.',
            ),
            _buildSection(
              'Partage de données',
              'Nous ne vendons jamais vos données personnelles. Nous partageons des données uniquement dans les cas suivants:\n\n'
              '• Avec votre consentement explicite (par exemple, lorsque vous choisissez de participer à un défi communautaire).\n'
              '• Avec nos partenaires de service qui nous aident à faire fonctionner l\'application (stockage, authentification), toujours avec des contrats stricts de confidentialité.\n'
              '• De manière agrégée et anonymisée à des fins de recherche sur l\'impact environnemental.',
            ),
            _buildSection(
              'Vos droits',
              'Vous avez le droit de:\n\n'
              '• Accéder à toutes vos données personnelles que nous conservons.\n'
              '• Rectifier vos données si elles sont inexactes.\n'
              '• Supprimer vos données (droit à l\'oubli).\n'
              '• Exporter vos données dans un format lisible par machine.\n'
              '• Retirer votre consentement à tout moment.\n\n'
              'Pour exercer ces droits, accédez à la section "Confidentialité" dans les paramètres de l\'application ou contactez-nous à privacy@greenminds.eco.',
            ),
            _buildSection(
              'Utilisation des données par l\'IA',
              'Nous utilisons des algorithmes d\'intelligence artificielle pour analyser votre empreinte carbone et générer des recommandations personnalisées. Ces algorithmes utilisent vos données de manière confidentielle et sécurisée. Aucune décision automatisée affectant significativement vos droits n\'est prise sans intervention humaine.',
            ),
            _buildSection(
              'Contact',
              'Pour toute question concernant cette politique de confidentialité ou vos données personnelles, veuillez nous contacter à:\n\n'
              'privacy@greenminds.eco\n'
              'GreenMinds SAS\n'
              '123 Avenue de l\'Écologie\n'
              '75001 Paris, France',
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'J\'ai compris',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 