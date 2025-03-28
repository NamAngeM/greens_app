import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:greens_app/main.dart' as app;
import 'package:greens_app/utils/app_router.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

testWidgets('Test du flux de navigation complet', (WidgetTester tester) async {
    app.main();
    // Modifier le pumpAndSettle initial
await tester.pumpAndSettle(Duration(seconds: 5)); // Augmenter à 5 secondes
await tester.pump(); // Ajouter un pump supplémentaire

    // Étape 1: Vérification de splash_view_connect
    expect(find.text('Step into a greener future'), findsOneWidget);

    // Étape 2: Navigation vers signup_view - utiliser une clé existante
    await tester.tap(find.text('Create a new account'));
    await tester.pumpAndSettle(Duration(seconds: 2));
    
    // Vérifier via le titre du formulaire
    expect(find.text('Create Account'), findsOneWidget);

    // Remplissage avec des sélecteurs plus robustes
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    
    // Trouver le bouton par texte plutôt que par type
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Vérification alternative avec texte de la question
    expect(find.text('Pourquoi avez-vous téléchargé GreenMinds ?'), findsOneWidget);
  });
}