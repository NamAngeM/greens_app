import 'dart:io';
import 'dart:convert';

// Ce script est destiné à être exécuté avec "dart scripts/prepare_agribalyse_data.dart"
// Il convertit les fichiers CSV bruts d'Agribalyse en format exploitable par l'application

void main() async {
  print('Démarrage de la préparation des données Agribalyse...');
  
  // Chemin des fichiers source et destination
  final sourcePath = 'data_raw/';
  final destPath = 'assets/data/';
  
  // Créer le dossier de destination s'il n'existe pas
  final destDir = Directory(destPath);
  if (!await destDir.exists()) {
    await destDir.create(recursive: true);
    print('Dossier de destination créé: $destPath');
  }
  
  try {
    // Traiter les différents fichiers
    await processProductsFile(
      sourcePath: '${sourcePath}agribalyse_products_raw.csv', 
      destPath: '${destPath}agribalyse_products.csv'
    );
    
    await processCarbonFile(
      sourcePath: '${sourcePath}agribalyse_carbon_raw.csv', 
      destPath: '${destPath}agribalyse_carbon.csv'
    );
    
    await processWaterFile(
      sourcePath: '${sourcePath}agribalyse_water_raw.csv', 
      destPath: '${destPath}agribalyse_water.csv'
    );
    
    print('Préparation des données Agribalyse terminée avec succès!');
    
  } catch (e) {
    print('Erreur lors de la préparation des données: $e');
    exit(1);
  }
}

Future<void> processProductsFile({required String sourcePath, required String destPath}) async {
  print('Traitement du fichier produits...');
  
  try {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      print('ERREUR: Le fichier source $sourcePath n\'existe pas!');
      return;
    }
    
    final lines = await sourceFile.readAsLines();
    
    // Écrire le fichier de sortie avec les champs nécessaires
    final destFile = File(destPath);
    final sink = destFile.openWrite();
    
    // Écrire l'en-tête
    sink.writeln('code,name,category,subCategory');
    
    // Ignorer la première ligne (en-tête) et traiter les données
    for (int i = 1; i < lines.length; i++) {
      final columns = lines[i].split(',');
      
      // S'assurer qu'il y a assez de colonnes
      if (columns.length >= 4) {
        final code = columns[0].replaceAll('"', '');
        final name = columns[1].replaceAll('"', '');
        final category = columns[2].replaceAll('"', '');
        final subCategory = columns[3].replaceAll('"', '');
        
        // Écrire la ligne formatée
        sink.writeln('$code,$name,$category,$subCategory');
      }
    }
    
    await sink.flush();
    await sink.close();
    print('Fichier produits traité: $destPath');
    
  } catch (e) {
    print('Erreur lors du traitement du fichier produits: $e');
    rethrow;
  }
}

Future<void> processCarbonFile({required String sourcePath, required String destPath}) async {
  print('Traitement du fichier empreinte carbone...');
  
  try {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      print('ERREUR: Le fichier source $sourcePath n\'existe pas!');
      return;
    }
    
    final lines = await sourceFile.readAsLines();
    
    // Écrire le fichier de sortie avec les champs nécessaires
    final destFile = File(destPath);
    final sink = destFile.openWrite();
    
    // Écrire l'en-tête
    sink.writeln('code,value,production,transport,packaging,processing');
    
    // Ignorer la première ligne (en-tête) et traiter les données
    for (int i = 1; i < lines.length; i++) {
      final columns = lines[i].split(',');
      
      // S'assurer qu'il y a assez de colonnes
      if (columns.length >= 6) {
        final code = columns[0].replaceAll('"', '');
        final value = columns[1].replaceAll('"', '');
        final production = columns[2].replaceAll('"', '');
        final transport = columns[3].replaceAll('"', '');
        final packaging = columns[4].replaceAll('"', '');
        final processing = columns[5].replaceAll('"', '');
        
        // Écrire la ligne formatée
        sink.writeln('$code,$value,$production,$transport,$packaging,$processing');
      }
    }
    
    await sink.flush();
    await sink.close();
    print('Fichier empreinte carbone traité: $destPath');
    
  } catch (e) {
    print('Erreur lors du traitement du fichier empreinte carbone: $e');
    rethrow;
  }
}

Future<void> processWaterFile({required String sourcePath, required String destPath}) async {
  print('Traitement du fichier empreinte eau...');
  
  try {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      print('ERREUR: Le fichier source $sourcePath n\'existe pas!');
      return;
    }
    
    final lines = await sourceFile.readAsLines();
    
    // Écrire le fichier de sortie avec les champs nécessaires
    final destFile = File(destPath);
    final sink = destFile.openWrite();
    
    // Écrire l'en-tête
    sink.writeln('code,value');
    
    // Ignorer la première ligne (en-tête) et traiter les données
    for (int i = 1; i < lines.length; i++) {
      final columns = lines[i].split(',');
      
      // S'assurer qu'il y a assez de colonnes
      if (columns.length >= 2) {
        final code = columns[0].replaceAll('"', '');
        final value = columns[1].replaceAll('"', '');
        
        // Écrire la ligne formatée
        sink.writeln('$code,$value');
      }
    }
    
    await sink.flush();
    await sink.close();
    print('Fichier empreinte eau traité: $destPath');
    
  } catch (e) {
    print('Erreur lors du traitement du fichier empreinte eau: $e');
    rethrow;
  }
} 