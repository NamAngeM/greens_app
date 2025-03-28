import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:greens_app/widgets/menu.dart';

import '../../controllers/auth_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    
    if (user != null) {
      String displayName = '';
      if (user.firstName != null && user.firstName!.isNotEmpty) {
        displayName = user.firstName!;
        if (user.lastName != null && user.lastName!.isNotEmpty) {
          displayName += ' ${user.lastName!}';
        }
      } else if (user.lastName != null && user.lastName!.isNotEmpty) {
        displayName = user.lastName!;
      } else {
        displayName = 'Utilisateur GreenMinds';
      }
      
      _nameController.text = displayName;
      _emailController.text = user.email ?? '';
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final String fullName = _nameController.text.trim();
      final List<String> nameParts = fullName.split(' ');
      final String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      final authController = Provider.of<AuthController>(context, listen: false);
      
      _updateUserInfo(firstName, lastName, authController).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: AppColors.secondaryColor,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${error.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      });
    }
  }
  
  Future<void> _updateUserInfo(String firstName, String lastName, AuthController authController) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Mon profil",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Color(0xFF1F3140)),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.profilePrimaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: AppColors.profilePrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      enabled: false, 
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildStatisticsSection(),
                    const SizedBox(height: 32),
                    
                    if (!_isEditing) ...[
                      CustomButton(
                        text: 'Calculer mon empreinte carbone',
                        icon: Icons.eco_outlined,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.carbonCalculator);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Mes récompenses',
                        icon: Icons.card_giftcard_outlined,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.rewards);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Paramètres',
                        icon: Icons.settings_outlined,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          authController.signOut().then((_) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomMenu(currentIndex: 3),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.profilePrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            icon: Icons.eco,
            title: 'Empreinte carbone',
            value: '2.5 tonnes CO2/an',
            color: AppColors.secondaryColor,
          ),
          const Divider(),
          _buildStatItem(
            icon: Icons.recycling,
            title: 'Déchets évités',
            value: '15 kg',
            color: Colors.green,
          ),
          const Divider(),
          _buildStatItem(
            icon: Icons.star,
            title: 'Points de récompense',
            value: '350 points',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}