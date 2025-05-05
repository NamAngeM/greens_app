import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greens_app/services/auth_service.dart';
import 'package:greens_app/views/auth/login_view.dart';
import 'package:greens_app/views/auth/signup_view.dart';
import 'package:greens_app/screens/articles_screen.dart';
import 'package:greens_app/views/home/home_view.dart';
import 'package:greens_app/views/onboarding/onboarding_view.dart';
import 'package:greens_app/views/splash_view.dart';
import 'package:greens_app/views/splash_view_connect.dart';
import 'package:greens_app/views/carbon/carbon_calculator_view.dart';
import 'package:greens_app/views/carbon/carbon_dashboard_view.dart';
import 'package:greens_app/views/questions/question_1_view.dart';
import 'package:greens_app/views/questions/question_2_view.dart';
import 'package:greens_app/views/questions/question_3_view.dart';
import 'package:greens_app/views/questions/question_4_view.dart';
import 'package:greens_app/views/questions/question_5_view.dart';
import 'package:greens_app/views/articles/article_view.dart';
import 'package:greens_app/views/blogs/blog_view.dart';
import 'package:greens_app/views/legale/legale_notice_view.dart';
import 'package:greens_app/views/settings/setting_view.dart';
import 'package:greens_app/views/chatbot/chatbot_view.dart';
import 'package:greens_app/views/chatbot/eco_chatbot_view.dart';
import 'package:greens_app/views/products/products_view.dart';
import 'package:greens_app/views/profile/profile_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greens_app/views/goals/goals_view.dart';
import 'package:greens_app/views/community/community_view.dart';
import 'package:greens_app/views/scanner/product_scanner_view.dart';
import 'package:greens_app/views/methodology_view.dart';
import 'package:greens_app/views/community_impact_view.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';

// Classe pour définir les constantes de routes
class AppRoutes {
  static const String splash = '/';
  static const String splashConnect = '/splash_connect';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String carbonCalculator = '/carbon_calculator';
  static const String carbonDashboard = '/carbon_dashboard';
  static const String products = '/products';
  static const String rewards = '/rewards';
  static const String profile = '/profile';
  static const String articles = '/articles';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String chatbot = '/chatbot';
  static const String ecoChatbot = '/eco_chatbot';
  static const String question1 = '/question1';
  static const String question2 = '/question2';
  static const String question3 = '/question3';
  static const String question4 = '/question4';
  static const String question5 = '/question5';
  static const String blog = '/blog';
  static const String legalNotice = '/legal_notice';
  static const String goals = '/goals';
  static const String community = '/community';
  static const String productScanner = '/product_scanner';
  static const String cart = '/cart';
  static const String notifications = '/notifications';
  static const String methodology = '/methodology';
  static const String communityImpact = '/community_impact';
  static const String onboardingNew = '/onboarding_new';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case AppRoutes.splashConnect:
        return MaterialPageRoute(builder: (_) => const SplashViewConnect());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupView());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingView());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case AppRoutes.carbonCalculator:
        return MaterialPageRoute(builder: (_) => const CarbonCalculatorView());
      case AppRoutes.carbonDashboard:
        return MaterialPageRoute(builder: (_) => const CarbonDashboardView());
      case AppRoutes.question1:
        return MaterialPageRoute(builder: (_) => const Question1View());
      case AppRoutes.question2:
        return MaterialPageRoute(builder: (_) => const Question2View());
      case AppRoutes.question3:
        return MaterialPageRoute(builder: (_) => const Question3View());
      case AppRoutes.question4:
        return MaterialPageRoute(builder: (_) => const Question4View());
      case AppRoutes.question5:
        return MaterialPageRoute(builder: (_) => const Question5View());
      case AppRoutes.articles:
        return MaterialPageRoute(builder: (_) => const ArticlesScreen());
      case AppRoutes.blog:
        return MaterialPageRoute(builder: (_) => const BlogView());
      case AppRoutes.legalNotice:
        return MaterialPageRoute(builder: (_) => const LegaleNoticeView());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingView());
      case AppRoutes.products:
        return MaterialPageRoute(builder: (_) => const ProductsView());
      case AppRoutes.chatbot:
        return MaterialPageRoute(builder: (_) => const ChatbotView());
      case AppRoutes.ecoChatbot:
        return MaterialPageRoute(builder: (_) => const EcoChatbotView());
      case AppRoutes.rewards:
      case AppRoutes.goals:
        return MaterialPageRoute(builder: (_) => const GoalsView());
      case AppRoutes.community:
        return MaterialPageRoute(builder: (_) => const CommunityView());
      case AppRoutes.productScanner:
        return MaterialPageRoute(builder: (_) => const ProductScannerView());
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileView(), 
        );
      case AppRoutes.help:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Aide')),
            body: const Center(child: Text('Page d\'aide - À implémenter')),
          ),
        );
      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Panier')),
            body: const Center(child: Text('Page du panier - À implémenter')),
          ),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Notifications')),
            body: const Center(child: Text('Page des notifications - À implémenter')),
          ),
        );
      case AppRoutes.methodology:
        return MaterialPageRoute(
          builder: (_) => const MethodologyView(),
        );
      case AppRoutes.communityImpact:
        String challengeId = '';
        if (settings.arguments != null) {
          challengeId = settings.arguments as String;
        }
        return MaterialPageRoute(
          builder: (_) => CommunityImpactView(challengeId: challengeId),
        );
      case AppRoutes.onboardingNew:
        return MaterialPageRoute(
          builder: (_) => const OnboardingView(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non définie pour ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return generateRoute(settings);
  }

  static Widget initialRoute() {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashView();
        } else if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _hasCompletedQuestions(),
            builder: (context, questionsSnapshot) {
              if (questionsSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashView();
              }
              
              if (questionsSnapshot.data == false) {
                return const Question1View();
              }
              
              return const HomeView();
            },
          );
        } else {
          return const LoginView();
        }
      },
    );
  }
  
  static Future<bool> _hasCompletedQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Pour les nouveaux utilisateurs, vérifier explicitement les deux drapeaux
      final isNewUser = prefs.getBool('is_new_user') ?? false;
      final hasCompleted = prefs.getBool('has_completed_questions') ?? false;
      
      // Afficher pour le débogage
      print('isNewUser: $isNewUser, hasCompleted: $hasCompleted');
      
      // Si c'est un nouvel utilisateur et qu'il n'a pas complété les questions, 
      // retourner false pour rediriger vers les questions
      if (isNewUser && !hasCompleted) {
        return false;
      }
      
      // Sinon, si l'utilisateur existe déjà et qu'il n'a pas encore
      // de drapeau has_completed_questions, on considère qu'il l'a fait
      // pour ne pas bloquer les utilisateurs existants
      if (!isNewUser && !hasCompleted) {
        await prefs.setBool('has_completed_questions', true);
        return true;
      }
      
      return hasCompleted;
    } catch (e) {
      print('Erreur lors de la vérification des questions: $e');
      // En cas d'erreur, on retourne true pour ne pas bloquer l'utilisateur
      return true;
    }
  }
}
