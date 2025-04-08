// Fichier: lib/views/community/challenge_contribution_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/models/community_challenge_model.dart';

class ChallengeContributionView extends StatefulWidget {
  final String challengeId;

  const ChallengeContributionView({Key? key, required this.challengeId}) : super(key: key);

  @override
  _ChallengeContributionViewState createState() => _ChallengeContributionViewState();
}

class _ChallengeContributionViewState extends State<ChallengeContributionView> {
  final _formKey = GlobalKey<FormState>();
  final _activityController = TextEditingController();
  
  double _carbonSaved = 1.0;
  bool _isSubmitting = false;
  CommunityChallenge? _challenge;
  
  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }
  
  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }
  
  Future<void> _loadChallenge() async {
    final communityController = Provider.of<CommunityController>(context, listen: false);
    
    setState(() {
      _challenge = communityController.challenges
          .firstWhere((c) => c.id == widget.challengeId, orElse: () => 
            CommunityChallenge(
              id: widget.challengeId,
              title: 'Défi non trouvé',
              description: 'Ce défi n\'existe pas ou a été supprimé',
              imageUrl: '',
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 30)),
              participantsCount: 0,
              targetParticipants: 100,
              status: ChallengeStatus.upcoming,
              carbonPointsReward: 0,
              participants: [],
              createdAt: DateTime.now(),
              goalTarget: 0,
              category: ChallengeCategory.other
            )
          );
    });
  }
  
  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    final communityController = Provider.of<CommunityController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.currentUser?.uid ?? '';
    
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour contribuer')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }
    
    final success = await communityController.recordContribution(
      widget.challengeId,
      userId,
      _carbonSaved,
      _activityController.text,
    );
    
    setState(() {
      _isSubmitting = false;
    });
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contribution enregistrée avec succès !')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement de la contribution')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer une contribution'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _challenge == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contribuer au défi: ${_challenge!.title}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    
                    // Description de l'activité
                    TextFormField(
                      controller: _activityController,
                      decoration: const InputDecoration(
                        labelText: 'Description de votre action écologique',
                        hintText: 'Ex: J\'ai utilisé mon vélo au lieu de ma voiture',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez décrire votre action';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Estimation de CO2 économisé
                    Text(
                      'Estimation du CO₂ économisé (en kg)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _carbonSaved,
                      min: 0.1,
                      max: 10.0,
                      divisions: 99,
                      label: _carbonSaved.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _carbonSaved = value;
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        '${_carbonSaved.toStringAsFixed(1)} kg de CO₂',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Guide d'estimation
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guide d\'estimation',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEstimationGuideItem(
                              '0.5 kg', 
                              'Utiliser le vélo au lieu de la voiture pour 2 km'
                            ),
                            _buildEstimationGuideItem(
                              '1 kg', 
                              'Une journée sans viande'
                            ),
                            _buildEstimationGuideItem(
                              '2 kg', 
                              'Utiliser les transports en commun au lieu de la voiture pour 10 km'
                            ),
                            _buildEstimationGuideItem(
                              '5 kg', 
                              'Réduire le chauffage de 2°C pendant une journée'
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton de soumission
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitContribution,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Enregistrer ma contribution',
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
            ),
    );
  }
  
  Widget _buildEstimationGuideItem(String amount, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}