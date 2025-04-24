import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'services/image_picker_service.dart';
import 'services/storage_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  // Initialiser les services
  final storageService = StorageService();
  Get.put(storageService);
  Get.put(ImagePickerService());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Test Upload Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProfileImageTest(),
    );
  }
}

class ProfileImageTest extends StatefulWidget {
  const ProfileImageTest({Key? key}) : super(key: key);

  @override
  _ProfileImageTestState createState() => _ProfileImageTestState();
}

class _ProfileImageTestState extends State<ProfileImageTest> {
  final ImagePickerService _imagePickerService = Get.find<ImagePickerService>();
  File? _profileImage;
  String? _imageUrl;
  
  Future<void> _pickImageFrom(ImageSource source) async {
    try {
      final File? image = await _imagePickerService.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image == null) return;
      
      setState(() {
        _profileImage = image;
      });
      
      // Simuler l'ID utilisateur
      const String userId = 'test_user_123';
      
      // Télécharger l'image
      final imageUrl = await _imagePickerService.uploadProfileImage(_profileImage!, userId);
      
      if (imageUrl != null) {
        setState(() {
          _imageUrl = imageUrl;
        });
        
        Get.snackbar(
          'Succès',
          'Image téléchargée avec succès',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner ou télécharger l\'image: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
  
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une photo de profil'),
          content: const Text(
            'D\'où souhaitez-vous importer votre photo ?',
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.photo_library, color: AppColors.primaryColor),
              label: const Text('Galerie', style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFrom(ImageSource.gallery);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              label: const Text('Caméra', style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFrom(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Afficher l'image sélectionnée ou l'image téléchargée
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Obx(() => _imagePickerService.isUploading.value
                ? const CircularProgressIndicator()
                : ClipOval(
                    child: _profileImage != null
                      ? Image.file(_profileImage!, fit: BoxFit.cover)
                      : _imageUrl != null
                          ? Image.network(_imageUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 80, color: Colors.grey),
                  ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bouton pour sélectionner une image
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Sélectionner une image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
            
            if (_imageUrl != null) ...[
              const SizedBox(height: 16),
              const Text('Image URL:'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _imageUrl!,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 