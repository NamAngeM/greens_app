// Ajouter dans utils/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
      ),
      // Autres éléments de thème...
    );
  }
  
  static ThemeData get darkTheme {
    // Thème sombre pour réduire l'empreinte numérique
    // ...
  }
}