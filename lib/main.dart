import 'package:flutter/material.dart';
import 'package:greens_app/screens/home_screen.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/controllers/reward_controller.dart';
import 'package:greens_app/controllers/product_controller.dart';
import 'package:greens_app/controllers/article_controller.dart';
import 'package:greens_app/firebase/firebase_config.dart';
import 'package:greens_app/services/favorites_service.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:greens_app/controllers/product_scan_controller.dart';
import 'package:greens_app/services/chatbot_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase avec la configuration
  try {
    await FirebaseConfig.initializeFirebase();
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
    // Continuer l'application même si Firebase échoue
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CarbonFootprintController()),
        ChangeNotifierProvider(create: (_) => RewardController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => ArticleController()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => EcoGoalController()),
        ChangeNotifierProvider(create: (_) => CommunityController()),
        ChangeNotifierProvider(create: (_) => ProductScanController()),
        ChangeNotifierProvider(create: (_) => N8nChatbotService.instance),
      ],
      child: MaterialApp(
        title: 'Green Minds',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: AppColors.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            primary: AppColors.primaryColor,
            secondary: AppColors.secondaryColor,
          ),
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            displayMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            displaySmall: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: AppColors.textColor,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: AppColors.textColor,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              color: AppColors.textLightColor,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.generateRoute,
        home: const HomeScreen(),
      ),
    );
  }
}
