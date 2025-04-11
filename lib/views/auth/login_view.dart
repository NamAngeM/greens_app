import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isLoggingInWithGoogle = false;
  
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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      final success = await authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        // Vérifier si l'utilisateur est un nouvel inscrit
        final prefs = await SharedPreferences.getInstance();
        final isNewUser = prefs.getBool('is_new_user') ?? false;
        final hasCompletedQuestions = prefs.getBool('has_completed_questions') ?? false;
        
        if (isNewUser && !hasCompletedQuestions) {
          // Si c'est un nouvel utilisateur qui n'a pas encore répondu aux questions
          
          // Naviguer vers la première page de questions
          Navigator.pushReplacementNamed(context, AppRoutes.question1);
        } else {
          // Sinon, rediriger directement vers la page d'accueil
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Erreur de connexion'),
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
  
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoggingInWithGoogle = true;
    });
    
    try {
      print('Début de la connexion Google...');
      final authController = Provider.of<AuthController>(context, listen: false);
      final success = await authController.signInWithGoogle();
      
      print('Résultat de la connexion Google: $success');
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
            content: Text(authController.errorMessage ?? 'Erreur de connexion avec Google'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erreur dans login_view._signInWithGoogle: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion avec Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingInWithGoogle = false;
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
                          // Logo et formulaire
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 30),
                              
                              // Logo
                              Center(
                                child: Hero(
                                  tag: 'app_logo',
                                  child: Image.asset(
                                    'assets/images/logo/logo_green_white.png',
                                    height: 130,
                                    // Utiliser une icône par défaut si le logo n'est pas disponible
                                    errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.eco, size: 80, color: Colors.white),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Champ email
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 8),
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
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer votre email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return 'Veuillez entrer un email valide';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Champ mot de passe
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 8),
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
                                      hintText: 'Entrez votre mot de passe',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: _togglePasswordVisibility,
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer votre mot de passe';
                                      }
                                      if (value.length < 6) {
                                        return 'Le mot de passe doit contenir au moins 6 caractères';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              
                              // Lien mot de passe oublié
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implémenter la récupération de mot de passe
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'Mot de passe oublié?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Case à cocher pour les conditions d'utilisation
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreedToTerms = value ?? false;
                                      });
                                    },
                                    fillColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return AppColors.primaryColor;
                                        }
                                        return Colors.white;
                                      },
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 25),
                              
                              // Bouton de connexion
                              ElevatedButton(
                                onPressed: authController.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F2937),
                                  disabledBackgroundColor: const Color(0xFF34D399).withOpacity(0.5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authController.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        'Se connecter',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Lien pour créer un compte
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Pas encore de compte ? ",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, AppRoutes.signup);
                                    },
                                    child: const Text(
                                      'Créer un compte',
                                      style: TextStyle(
                                        color: Color(0xFF34D399),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Section connexion avec Google (en bas)
                          Column(
                            children: [
                              // Séparateur OU
                              const Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white54,
                                      thickness: 1,
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
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Bouton de connexion avec Google
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: _isLoggingInWithGoogle ? null : _signInWithGoogle,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: _isLoggingInWithGoogle
                                        ? const Center(
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.black54,
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Image.asset(
                                              'assets/images/icons/icons8-google-96-2.png',
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: screenSize.height * 0.05), // Espacement adaptatif en bas
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
