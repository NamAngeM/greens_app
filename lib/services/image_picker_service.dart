import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:greens_app/services/storage_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerService extends GetxService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final StorageService _storageService = Get.find<StorageService>();
  
  // Rx variable pour suivre l'état du chargement
  final RxBool isUploading = false.obs;
  
  /// Sélectionne une image depuis la galerie ou l'appareil photo
  Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool cropImage = true,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        return null;
      }

      File imageFile = File(pickedFile.path);
      
      // Cropper l'image si demandé
      if (cropImage) {
        final File? croppedFile = await _cropImage(imageFile);
        if (croppedFile != null) {
          imageFile = croppedFile;
        }
      }
      
      return imageFile;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner l\'image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  /// Croppe l'image sélectionnée
  Future<File?> _cropImage(File imageFile) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Ajuster la photo',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Ajuster la photo',
            doneButtonTitle: 'Terminer',
            cancelButtonTitle: 'Annuler',
          ),
        ],
      );
      
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de redimensionner l\'image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  /// Valide le format et la taille de l'image
  bool validateImage(File image, {double maxSizeInMb = 2.0}) {
    // Vérifier le format de l'image (extension)
    final String extension = path.extension(image.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
      Get.snackbar(
        'Format non valide',
        'Seuls les formats JPEG et PNG sont acceptés',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    // Vérifier la taille de l'image
    final int sizeInBytes = image.lengthSync();
    final double sizeInMb = sizeInBytes / (1024 * 1024);
    
    if (sizeInMb > maxSizeInMb) {
      Get.snackbar(
        'Image trop volumineuse',
        'L\'image doit être inférieure à ${maxSizeInMb.toStringAsFixed(1)} Mo. Taille actuelle: ${sizeInMb.toStringAsFixed(1)} Mo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    return true;
  }
  
  /// Compresse l'image pour réduire sa taille
  Future<File?> _compressImage(File file, {int quality = 85}) async {
    try {
      final String dir = (await getTemporaryDirectory()).path;
      final String targetPath = '$dir/${const Uuid().v4()}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 800,
        minHeight: 800,
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Erreur lors de la compression: $e');
      // En cas d'échec de compression, retourner le fichier d'origine
      return file;
    }
  }
  
  /// Télécharge l'image de profil vers Firebase Storage
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Comprimer l'image avant téléchargement
      final File? compressedFile = await _compressImage(imageFile);
      if (compressedFile == null) return null;

      // Définir le chemin de stockage
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_images').child(fileName);
      
      // Créer la tâche de téléchargement
      final UploadTask uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Gérer la progression du téléchargement
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Progression du téléchargement: ${(progress * 100).toStringAsFixed(2)}%');
      });
      
      // Attendre la fin du téléchargement et récupérer l'URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec du téléchargement: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  /// Récupère l'URL de l'image de profil depuis Firebase Storage
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_images').child(fileName);
      return await ref.getDownloadURL();
    } catch (e) {
      // Si l'image n'existe pas ou autre erreur, retourner null silencieusement
      return null;
    }
  }
  
  /// Supprime l'image de profil de Firebase Storage
  Future<bool> deleteProfileImage(String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_images').child(fileName);
      await ref.delete();
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer l\'image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
} 