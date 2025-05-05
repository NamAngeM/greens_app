import 'package:test/test.dart';
import 'package:greens_app/services/accessibility_service.dart';

void main() {
  group('AccessibilityService Tests', () {
    late AccessibilityService accessibilityService;

    setUp(() {
      accessibilityService = AccessibilityService();
    });

    test('Doit initialiser avec les paramètres par défaut', () async {
      await accessibilityService.initialize();
      expect(accessibilityService.isHighContrastEnabled, isFalse);
      expect(accessibilityService.textScaleFactor, equals(1.0));
    });

    test('Doit mettre à jour les paramètres d\'accessibilité', () {
      accessibilityService.setHighContrast(true);
      expect(accessibilityService.isHighContrastEnabled, isTrue);

      accessibilityService.setTextScale(1.5);
      expect(accessibilityService.textScaleFactor, equals(1.5));
    });
  });
}