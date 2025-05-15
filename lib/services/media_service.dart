import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class MediaService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _mediaList = [];
  
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get mediaList => _mediaList;
  
  // Singleton pattern
  static final MediaService _instance = MediaService._internal();
  
  factory MediaService() {
    return _instance;
  }
  
  MediaService._internal();
  
  // Charger la liste des médias depuis Firestore
  Future<void> loadMedia() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final mediaSnapshot = await _firestore.collection('media').orderBy('createdAt', descending: true).get();
      
      _mediaList = mediaSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Sans nom',
          'url': data['url'] ?? '',
          'type': data['type'] ?? 'image',
          'size': data['size'] ?? 0,
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
          'createdBy': data['createdBy'] ?? 'Admin',
        };
      }).toList();
      
    } catch (e) {
      print('Erreur lors du chargement des médias: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Télécharger un fichier vers Firebase Storage
  Future<Map<String, dynamic>?> uploadMedia({
    required Uint8List fileBytes,
    required String fileName,
    required String fileType,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Générer un nom de fichier unique
      final String fileExtension = fileName.split('.').last;
      final String uniqueFileName = '${Uuid().v4()}.$fileExtension';
      final String storagePath = 'media/$uniqueFileName';
      
      // Déterminer le type MIME
      String contentType;
      switch (fileExtension.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'pdf':
          contentType = 'application/pdf';
          break;
        default:
          contentType = 'application/octet-stream';
      }
      
      // Télécharger le fichier vers Firebase Storage
      final storageRef = _storage.ref().child(storagePath);
      final UploadTask uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: contentType),
      );
      
      // Attendre la fin du téléchargement
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Enregistrer les métadonnées dans Firestore
      final mediaData = {
        'name': fileName,
        'url': downloadUrl,
        'storagePath': storagePath,
        'type': fileType,
        'size': fileBytes.length,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': userId,
      };
      
      final docRef = await _firestore.collection('media').add(mediaData);
      
      // Ajouter le média à la liste locale
      final newMedia = {
        'id': docRef.id,
        'name': fileName,
        'url': downloadUrl,
        'type': fileType,
        'size': fileBytes.length,
        'createdAt': DateTime.now(),
        'createdBy': userId,
      };
      
      _mediaList.insert(0, newMedia);
      notifyListeners();
      
      return newMedia;
    } catch (e) {
      print('Erreur lors du téléchargement du média: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Supprimer un média
  Future<bool> deleteMedia(String mediaId) async {
    try {
      // Trouver le média dans la liste
      final mediaToDelete = _mediaList.firstWhere((media) => media['id'] == mediaId);
      final storagePath = await _firestore.collection('media').doc(mediaId).get()
          .then((doc) => doc.data()?['storagePath'] as String?);
      
      if (storagePath != null) {
        // Supprimer le fichier de Firebase Storage
        await _storage.ref().child(storagePath).delete();
      }
      
      // Supprimer les métadonnées de Firestore
      await _firestore.collection('media').doc(mediaId).delete();
      
      // Supprimer de la liste locale
      _mediaList.removeWhere((media) => media['id'] == mediaId);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du média: $e');
      return false;
    }
  }
  
  // Sélectionner et télécharger une image
  Future<Map<String, dynamic>?> pickAndUploadImage(String userId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final fileBytes = file.bytes;
        
        if (fileBytes != null) {
          return await uploadMedia(
            fileBytes: fileBytes,
            fileName: fileName,
            fileType: 'image',
            userId: userId,
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      return null;
    }
  }
} 