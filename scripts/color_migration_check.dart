// scripts/color_migration_check.dart
// Script pour identifier les fichiers qui utilisent encore les anciennes couleurs (LegacyAppColors)

import 'dart:io';

void main() async {
  final libDirectory = Directory('lib');
  final results = <String, List<int>>{};
  
  print('🔍 Recherche des références à LegacyAppColors...\n');
  
  await _scanDirectory(libDirectory, results);
  
  if (results.isEmpty) {
    print('✅ Aucune référence à LegacyAppColors trouvée. La migration est complète !');
  } else {
    print('⚠️ ${results.length} fichiers utilisent encore LegacyAppColors :');
    
    results.forEach((filePath, lines) {
      print('\n📁 $filePath');
      print('   Lignes: ${lines.join(', ')}');
    });
    
    print('\n📝 Recommandation : Mettez à jour ces fichiers pour utiliser AppColors à la place.');
    print('💡 Vous pouvez utiliser le fichier lib/utils/color_migration.dart pour faciliter la migration.');
  }
}

Future<void> _scanDirectory(Directory directory, Map<String, List<int>> results) async {
  final pattern = RegExp(r'LegacyAppColors');
  
  await for (final entity in directory.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('color_migration.dart')) {
      final lines = await entity.readAsLines();
      final matchedLines = <int>[];
      
      for (int i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          matchedLines.add(i + 1);
        }
      }
      
      if (matchedLines.isNotEmpty) {
        final relativePath = entity.path.replaceFirst('${Directory.current.path}${Platform.pathSeparator}', '');
        results[relativePath] = matchedLines;
      }
    }
  }
} 