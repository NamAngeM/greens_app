import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Configuration Firebase pour l'application GREENS APP
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions n\'a pas été configuré pour Windows - '
          'créez une configuration d\'application avec Firebase CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions n\'a pas été configuré pour Linux - '
          'créez une configuration d\'application avec Firebase CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions n\'est pas supporté pour cette plateforme.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBOComehLBkIiTvsQP-vDWv3RNMC-xQ_bM",
    appId: "1:52406500094:web:641fac4240dc76f383c3af",
    messagingSenderId: "52406500094",
    projectId: "greens-app-59611",
    authDomain: "greens-app-59611.firebaseapp.com",
    storageBucket: "greens-app-59611.firebasestorage.app",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBOComehLBkIiTvsQP-vDWv3RNMC-xQ_bM",
    appId: "1:52406500094:android:641fac4240dc76f383c3af",
    messagingSenderId: "52406500094",
    projectId: "greens-app-59611",
    storageBucket: "greens-app-59611.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBOComehLBkIiTvsQP-vDWv3RNMC-xQ_bM",
    appId: "1:52406500094:ios:641fac4240dc76f383c3af",
    messagingSenderId: "52406500094",
    projectId: "greens-app-59611",
    storageBucket: "greens-app-59611.firebasestorage.app",
    iosClientId: "52406500094-ios-client-id.apps.googleusercontent.com",
    iosBundleId: "com.example.greensApp",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyBOComehLBkIiTvsQP-vDWv3RNMC-xQ_bM",
    appId: "1:52406500094:macos:641fac4240dc76f383c3af",
    messagingSenderId: "52406500094",
    projectId: "greens-app-59611",
    storageBucket: "greens-app-59611.firebasestorage.app",
    iosClientId: "52406500094-macos-client-id.apps.googleusercontent.com",
    iosBundleId: "com.example.greensApp.RunnerTests",
  );
}

// Classe pour initialiser Firebase
class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialisé avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de Firebase: $e');
    }
  }
}
