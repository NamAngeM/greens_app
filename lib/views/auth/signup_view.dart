import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_router.dart';

class SignupView extends StatefulWidget {
  const SignupView({Key? key}) : super(key: key);

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isSigningUpWithGoogle = false;
  int _passwordStrength = 0;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final String password = _passwordController.text;
    int strength = 0;
    
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
      });
      return;
    }
    
    if (password.length >= 8) strength += 25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 25;
    
    setState(() {
      _passwordStrength = strength;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      setState(() {
        _isLoading = true;
      });
      
      final authController = Provider.of<AuthController>(context, listen: false);
      
      final success = await authController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (success && mounted) {
        // Marquer comme nouvel utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_new_user', true);
        
        // Rediriger vers le questionnaire
        Navigator.pushReplacementNamed(context, AppRoutes.question1);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Erreur d\'inscription'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (!_agreedToTerms && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isSigningUpWithGoogle = true;
    });
    
    try {
      print('Début de l\'inscription avec Google...');
      final authController = Provider.of<AuthController>(context, listen: false);
      final success = await authController.signInWithGoogle();
      
      print('Résultat de l\'inscription Google: $success');
      print('Message d\'erreur éventuel: ${authController.errorMessage}');
      
      if (success && mounted) {
        // Vérifier si l'utilisateur est un nouvel inscrit
        final prefs = await SharedPreferences.getInstance();
        final isNewUser = prefs.getBool('is_new_user') ?? false;
        final hasCompletedQuestions = prefs.getBool('has_completed_questions') ?? false;
        
        print('isNewUser: $isNewUser, hasCompletedQuestions: $hasCompletedQuestions');
        
        if (isNewUser && !hasCompletedQuestions) {
          // Si c'est un nouvel utilisateur qui n'a pas encore répondu aux questions
          print('Redirection vers le questionnaire');
          // Naviguer vers la première page de questions
          Navigator.pushReplacementNamed(context, AppRoutes.question1);
        } else {
          // Sinon, rediriger directement vers la page d'accueil
          print('Redirection vers la page d\'accueil');
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (mounted) {
        print('Affichage du message d\'erreur: ${authController.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Erreur d\'inscription avec Google'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erreur dans signup_view._signUpWithGoogle: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'inscription avec Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningUpWithGoogle = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Image.asset(
            'assets/images/backgrounds/mountain_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Overlay semi-transparent
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
          
          // Contenu
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
            child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/logo/logo_green_white.png',
                          height: screenSize.height * 0.13, // 13% de la hauteur de l'écran
                          errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.eco, size: 72, color: Colors.white),
                                ),
                              ),
                              
                              const SizedBox(height: 14),
                              
                              // Champ nom complet
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 5),
                            child: Text(
                                      'Nom complet',
                              style: TextStyle(
                                color: Colors.white,
                                        fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextFormField(
                                    controller: _fullNameController,
                            decoration: InputDecoration(
                                      hintText: 'Entrez votre nom complet',
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                        vertical: 15,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer votre nom complet';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                              const SizedBox(height: 14),
                      
                      // Champ email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 5),
                            child: Text(
                              'Adresse email',
                              style: TextStyle(
                                color: Colors.white,
                                        fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Entrez votre adresse email',
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                        vertical: 15,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer votre adresse email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return 'Veuillez entrer une adresse email valide';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                              const SizedBox(height: 14),
                      
                      // Champ mot de passe
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 5),
                            child: Text(
                              'Mot de passe',
                              style: TextStyle(
                                color: Colors.white,
                                        fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: 'Créez votre mot de passe',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                        vertical: 15,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey[600],
                                  size: 23,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                                  
                                  // Indicateur de force du mot de passe
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: _passwordStrength / 100,
                                            backgroundColor: Colors.grey.withOpacity(0.3),
                                            color: _passwordStrength > 75 
                                                ? Colors.green 
                                                : _passwordStrength > 50 
                                                    ? Colors.orange 
                                                    : _passwordStrength > 25 
                                                        ? Colors.yellow 
                                                        : Colors.red,
                                            minHeight: 4.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _passwordStrength > 75 
                                              ? 'Fort' 
                                              : _passwordStrength > 50 
                                                  ? 'Moyen' 
                                                  : _passwordStrength > 25 
                                                      ? 'Faible' 
                                                      : _passwordStrength > 0 
                                                          ? 'Très faible'
                                                          : '',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 10),
                      
                      // Champ confirmation mot de passe
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 5),
                            child: Text(
                              'Confirmer le mot de passe',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              hintText: 'Confirmez votre mot de passe',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey[600],
                                  size: 23,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer votre mot de passe';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                              const SizedBox(height: 15),
                      
                      // Case à cocher pour les conditions d'utilisation
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.0,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return const Color(0xFF1F2937);
                                  }
                                  return Colors.white;
                                },
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                              const SizedBox(height: 16),
                              
                              // Bouton d'inscription
                              ElevatedButton(
                                onPressed: authController.isLoading ? null : _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF34D399),
                                  disabledBackgroundColor: const Color(0xFF34D399).withOpacity(0.5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authController.isLoading
                                    ? const SizedBox(
                                        height: 21,
                                        width: 21,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Créer un compte',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              
                              const SizedBox(height: 14),
                              
                              // Séparateur OU
                              const Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white54,
                                      thickness: 1.2,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      'OU',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white54,
                                      thickness: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Icône Google pour inscription
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: _isSigningUpWithGoogle ? null : _signUpWithGoogle,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 7,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: _isSigningUpWithGoogle
                                        ? const Center(
                                            child: SizedBox(
                                              height: 21,
                                              width: 21,
                                              child: CircularProgressIndicator(
                                                color: Colors.black54,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Image.asset(
                                              'assets/images/icons/icons8-google-96-2.png',
                                              height: 28,
                                              width: 28,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Lien de connexion
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Vous avez déjà un compte? ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, AppRoutes.login);
                                    },
                                    child: const Text(
                                      'Connexion',
                                      style: TextStyle(
                                        color: Color(0xFF34D399),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
