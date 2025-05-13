import 'package:flutter/material.dart';
import 'package:greens_app/models/environmental_impact_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialSharingCard extends StatelessWidget {
  final EnvironmentalImpactModel? impact;
  final String? achievementTitle;
  final String? achievementDescription;
  final String? imageUrl;
  final List<String> networks;
  
  const SocialSharingCard({
    Key? key,
    this.impact,
    this.achievementTitle,
    this.achievementDescription,
    this.imageUrl,
    this.networks = const ['facebook', 'instagram', 'twitter', 'linkedin'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                const Icon(
                  Icons.share,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Partager votre impact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Aperçu du contenu à partager
            if (achievementTitle != null || impact != null) _buildPreview(),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Boutons de partage
            const Text(
              'Choisissez votre réseau social :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textLightColor,
              ),
            ),
            const SizedBox(height: 12),
            
            // Réseaux sociaux
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildSocialButtons(),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton de personnalisation du message
            OutlinedButton(
              onPressed: () => _showCustomizeMessageDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Personnaliser mon message'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Aperçu du contenu à partager
  Widget _buildPreview() {
    // Message par défaut
    String previewTitle = achievementTitle ?? 'Mon impact environnemental';
    String previewDescription;
    
    if (impact != null) {
      previewDescription = 'J\'ai économisé ${impact!.carbonSaved.toStringAsFixed(1)} kg de CO₂, soit l\'équivalent de ${impact!.treeEquivalent.toStringAsFixed(1)} arbres plantés !';
    } else {
      previewDescription = achievementDescription ?? 'Je contribue à un avenir plus durable avec Green Minds.';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (si disponible)
          if (imageUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: AppColors.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.image,
                        color: AppColors.primaryColor,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
          
          if (imageUrl != null) const SizedBox(height: 12),
          
          // Titre du partage
          Text(
            previewTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          
          // Description du partage
          Text(
            previewDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Hashtags
          Text(
            '#GreenMinds #ÉcologiePratique #ActionClimat',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  // Liste des boutons de partage social
  List<Widget> _buildSocialButtons() {
    final List<Widget> buttons = [];
    
    if (networks.contains('facebook')) {
      buttons.add(_buildSocialButton(
        'Facebook',
        Icons.facebook,
        Colors.blue.shade800,
        () => _shareToSocial('facebook'),
      ));
    }
    
    if (networks.contains('instagram')) {
      buttons.add(_buildSocialButton(
        'Instagram',
        Icons.camera_alt,
        Colors.purple.shade700,
        () => _shareToSocial('instagram'),
      ));
    }
    
    if (networks.contains('twitter')) {
      buttons.add(_buildSocialButton(
        'Twitter/X',
        Icons.flutter_dash,
        Colors.blue.shade400,
        () => _shareToSocial('twitter'),
      ));
    }
    
    if (networks.contains('linkedin')) {
      buttons.add(_buildSocialButton(
        'LinkedIn',
        Icons.work,
        Colors.blue.shade900,
        () => _shareToSocial('linkedin'),
      ));
    }
    
    return buttons;
  }
  
  // Bouton de partage sur un réseau social
  Widget _buildSocialButton(String name, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Boîte de dialogue pour personnaliser le message
  void _showCustomizeMessageDialog(BuildContext context) {
    String message = achievementDescription ?? '';
    if (impact != null) {
      message = 'J\'ai économisé ${impact!.carbonSaved.toStringAsFixed(1)} kg de CO₂, soit l\'équivalent de ${impact!.treeEquivalent.toStringAsFixed(1)} arbres plantés !';
    }
    
    TextEditingController titleController = TextEditingController(
      text: achievementTitle ?? 'Mon impact environnemental',
    );
    TextEditingController messageController = TextEditingController(
      text: message,
    );
    TextEditingController hashtagsController = TextEditingController(
      text: '#GreenMinds #ÉcologiePratique #ActionClimat',
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Personnaliser votre message'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hashtagsController,
                  decoration: const InputDecoration(
                    labelText: 'Hashtags',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Ici vous pourriez enregistrer ces préférences
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }
  
  // Partage sur les réseaux sociaux
  void _shareToSocial(String network) async {
    // Construit un message basé sur l'impact ou l'accomplissement
    String message = '';
    
    if (achievementTitle != null) {
      message += achievementTitle! + '\n';
    } else {
      message += 'Mon impact environnemental\n';
    }
    
    if (impact != null) {
      message += 'J\'ai économisé ${impact!.carbonSaved.toStringAsFixed(1)} kg de CO₂, soit l\'équivalent de ${impact!.treeEquivalent.toStringAsFixed(1)} arbres plantés !\n';
    } else if (achievementDescription != null) {
      message += achievementDescription! + '\n';
    }
    
    message += '#GreenMinds #ÉcologiePratique #ActionClimat';
    
    // URL de l'application (à remplacer par votre URL réelle)
    const String appUrl = 'https://green-minds-app.com';
    
    // Construction de l'URL de partage en fonction du réseau social
    String shareUrl;
    
    switch (network) {
      case 'facebook':
        shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=$appUrl&quote=${Uri.encodeComponent(message)}';
        break;
      case 'twitter':
        shareUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(message)}&url=$appUrl';
        break;
      case 'linkedin':
        shareUrl = 'https://www.linkedin.com/sharing/share-offsite/?url=$appUrl&summary=${Uri.encodeComponent(message)}';
        break;
      case 'instagram':
        // Instagram ne permet pas de partage direct via URL, on peut seulement lancer l'app
        shareUrl = 'instagram://camera';
        break;
      default:
        shareUrl = '';
    }
    
    // Lancer l'URL
    if (shareUrl.isNotEmpty) {
      final Uri uri = Uri.parse(shareUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } 
    }
  }
} 