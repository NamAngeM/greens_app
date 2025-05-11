import 'package:flutter/foundation.dart';

/// Service pour calculer l'empreinte carbone des activités numériques
class DigitalCarbonService {
  // Facteurs d'émission pour différentes activités numériques (en g CO2e)
  static const Map<String, double> _streamingEmissionFactors = {
    'video_sd': 0.8,    // g CO2e par heure de streaming SD
    'video_hd': 2.5,    // g CO2e par heure de streaming HD
    'video_4k': 6.0,    // g CO2e par heure de streaming 4K
    'music': 0.2,       // g CO2e par heure de streaming audio
    'video_call': 1.0,  // g CO2e par heure de visioconférence
  };

  static const Map<String, double> _emailEmissionFactors = {
    'email_simple': 4.0,     // g CO2e par email sans pièce jointe
    'email_attachment': 50.0, // g CO2e par email avec pièce jointe
    'spam': 0.3,             // g CO2e par spam
  };

  static const Map<String, double> _storageEmissionFactors = {
    'cloud_storage': 0.015,  // g CO2e par Go par jour
    'photo': 0.08,           // g CO2e par photo stockée
    'video_minute': 0.2,     // g CO2e par minute de vidéo stockée
  };

  static const Map<String, double> _deviceEmissionFactors = {
    'smartphone_usage': 8.0,   // g CO2e par heure d'utilisation
    'laptop_usage': 17.0,      // g CO2e par heure d'utilisation
    'tablet_usage': 12.0,      // g CO2e par heure d'utilisation
    'desktop_usage': 28.0,     // g CO2e par heure d'utilisation
  };

  /// Calcule l'empreinte carbone du streaming vidéo et audio
  double calculateStreamingEmissions({
    double hoursVideoSD = 0,
    double hoursVideoHD = 0,
    double hoursVideo4K = 0,
    double hoursMusic = 0,
    double hoursVideoCalls = 0,
  }) {
    double totalEmissions = 0;
    
    totalEmissions += hoursVideoSD * _streamingEmissionFactors['video_sd']!;
    totalEmissions += hoursVideoHD * _streamingEmissionFactors['video_hd']!;
    totalEmissions += hoursVideo4K * _streamingEmissionFactors['video_4k']!;
    totalEmissions += hoursMusic * _streamingEmissionFactors['music']!;
    totalEmissions += hoursVideoCalls * _streamingEmissionFactors['video_call']!;
    
    return totalEmissions;
  }

  /// Calcule l'empreinte carbone des emails
  double calculateEmailEmissions({
    required int emailsSimple,
    required int emailsWithAttachment,
    required int spamEmails,
  }) {
    double totalEmissions = 0;
    
    totalEmissions += emailsSimple * _emailEmissionFactors['email_simple']!;
    totalEmissions += emailsWithAttachment * _emailEmissionFactors['email_attachment']!;
    totalEmissions += spamEmails * _emailEmissionFactors['spam']!;
    
    return totalEmissions;
  }

  /// Calcule l'empreinte carbone du stockage cloud
  double calculateStorageEmissions({
    required double cloudStorageGB,
    required int photosStored,
    required int videoMinutesStored,
  }) {
    double totalEmissions = 0;
    
    totalEmissions += cloudStorageGB * _storageEmissionFactors['cloud_storage']!;
    totalEmissions += photosStored * _storageEmissionFactors['photo']!;
    totalEmissions += videoMinutesStored * _storageEmissionFactors['video_minute']!;
    
    return totalEmissions;
  }

  /// Calcule l'empreinte carbone de l'utilisation des appareils
  double calculateDeviceUsageEmissions({
    required double hoursSmartphone,
    required double hoursLaptop,
    required double hoursTablet,
    required double hoursDesktop,
  }) {
    double totalEmissions = 0;
    
    totalEmissions += hoursSmartphone * _deviceEmissionFactors['smartphone_usage']!;
    totalEmissions += hoursLaptop * _deviceEmissionFactors['laptop_usage']!;
    totalEmissions += hoursTablet * _deviceEmissionFactors['tablet_usage']!;
    totalEmissions += hoursDesktop * _deviceEmissionFactors['desktop_usage']!;
    
    return totalEmissions;
  }

  /// Calcule l'empreinte carbone numérique totale (en kg CO2e)
  double calculateTotalDigitalFootprint({
    // Streaming
    required double hoursVideoSD,
    required double hoursVideoHD,
    required double hoursVideo4K,
    required double hoursMusic,
    required double hoursVideoCalls,
    
    // Emails
    required int emailsSimple,
    required int emailsWithAttachment,
    required int spamEmails,
    
    // Stockage
    required double cloudStorageGB,
    required int photosStored,
    required int videoMinutesStored,
    
    // Utilisation des appareils
    required double hoursSmartphone,
    required double hoursLaptop,
    required double hoursTablet,
    required double hoursDesktop,
  }) {
    double streamingEmissions = calculateStreamingEmissions(
      hoursVideoSD: hoursVideoSD,
      hoursVideoHD: hoursVideoHD,
      hoursVideo4K: hoursVideo4K,
      hoursMusic: hoursMusic,
      hoursVideoCalls: hoursVideoCalls,
    );
    
    double emailEmissions = calculateEmailEmissions(
      emailsSimple: emailsSimple,
      emailsWithAttachment: emailsWithAttachment,
      spamEmails: spamEmails,
    );
    
    double storageEmissions = calculateStorageEmissions(
      cloudStorageGB: cloudStorageGB,
      photosStored: photosStored,
      videoMinutesStored: videoMinutesStored,
    );
    
    double deviceEmissions = calculateDeviceUsageEmissions(
      hoursSmartphone: hoursSmartphone,
      hoursLaptop: hoursLaptop,
      hoursTablet: hoursTablet,
      hoursDesktop: hoursDesktop,
    );
    
    // Convertir de g à kg
    return (streamingEmissions + emailEmissions + storageEmissions + deviceEmissions) / 1000;
  }

  /// Génère des recommandations pour réduire l'empreinte numérique
  List<String> generateDigitalRecommendations({
    required double streamingEmissions,
    required double emailEmissions,
    required double storageEmissions,
    required double deviceEmissions,
  }) {
    final recommendations = <String>[];
    
    if (streamingEmissions > 5.0) {
      recommendations.add('Réduisez la qualité de vos vidéos en streaming (HD au lieu de 4K) pour diminuer votre empreinte carbone.');
    }
    
    if (emailEmissions > 10.0) {
      recommendations.add('Nettoyez régulièrement votre boîte mail et évitez d\'envoyer des pièces jointes volumineuses.');
    }
    
    if (storageEmissions > 3.0) {
      recommendations.add('Faites le tri dans vos photos et vidéos stockées dans le cloud pour réduire votre empreinte numérique.');
    }
    
    if (deviceEmissions > 20.0) {
      recommendations.add('Prolongez la durée de vie de vos appareils électroniques et privilégiez les appareils reconditionnés.');
    }
    
    // Recommandations générales
    recommendations.add('Désactivez les notifications inutiles et limitez le temps d\'écran pour réduire votre empreinte numérique.');
    recommendations.add('Utilisez le WiFi plutôt que les données mobiles quand c\'est possible.');
    
    return recommendations;
  }
}
