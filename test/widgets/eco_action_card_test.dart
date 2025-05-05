import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:greens_app/widgets/eco_action_card.dart';

void main() {
  group('EcoActionCard Widget Tests', () {
    testWidgets('Affiche correctement le titre et la description', 
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EcoActionCard(
            title: 'Réduire sa consommation d\'eau',
            description: 'Conseils pour économiser l\'eau au quotidien',
            iconData: Icons.water_drop,
            onTap: () {},
          ),
        ),
      ));

      expect(find.text('Réduire sa consommation d\'eau'), findsOneWidget);
      expect(find.text('Conseils pour économiser l\'eau au quotidien'), 
          findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
    });

    testWidgets('Déclenche le callback onTap', 
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EcoActionCard(
            title: 'Test Action',
            description: 'Test Description',
            iconData: Icons.eco,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ));

      await tester.tap(find.byType(EcoActionCard));
      expect(tapped, isTrue);
    });

    testWidgets('Vérifie le style et la mise en page', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EcoActionCard(
            title: 'Test Style',
            description: 'Test Description',
            iconData: Icons.eco,
            onTap: () {},
          ),
        ),
      ));

      // Vérifie la présence du Container principal
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      // Vérifie le style du texte du titre
      final titleFinder = find.text('Test Style');
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));

      // Vérifie la présence de l'effet d'élévation
      final cardFinder = find.byType(Card);
      final cardWidget = tester.widget<Card>(cardFinder);
      expect(cardWidget.elevation, isNotNull);
    });

    testWidgets('Gère correctement un long texte', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EcoActionCard(
            title: 'Un très long titre qui devrait être géré correctement par le widget',
            description: 'Une description très longue qui devrait également être gérée correctement et ne pas déborder du widget',
            iconData: Icons.eco,
            onTap: () {},
          ),
        ),
      ));

      // Vérifie qu'il n'y a pas de débordement
      expect(tester.takeException(), isNull);
    });

    testWidgets('Vérifie l\'accessibilité', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EcoActionCard(
            title: 'Test Accessibilité',
            description: 'Description pour test d\'accessibilité',
            iconData: Icons.eco,
            onTap: () {},
          ),
        ),
      ));

      // Vérifie la présence des éléments d'accessibilité
      final semanticsFinder = find.byType(Semantics);
      expect(semanticsFinder, findsWidgets);

      // Vérifie que le widget est tapable
      final gestureDetectorFinder = find.byType(GestureDetector);
      expect(gestureDetectorFinder, findsOneWidget);
    });

    testWidgets('Vérifie le comportement avec des données nulles', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EcoActionCard(
            title: '',
            description: '',
            iconData: Icons.eco,
            onTap: () {},
          ),
        ),
      ));

      // Vérifie que le widget se comporte correctement avec des chaînes vides
      expect(find.text(''), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}