import 'package:cloud_firestore/cloud_firestore.dart';

class LocalStore {
  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final String address;
  final String phoneNumber;
  final String email;
  final String website;
  final List<String> categories;
  final List<String> certifications;
  final Map<String, dynamic> openingHours;
  final double rating;
  final int reviewCount;
  final List<String> paymentMethods;
  final bool isOpen;
  final Map<String, dynamic> services;
  final List<String> images;
  final Map<String, dynamic> socialMedia;

  LocalStore({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.categories,
    required this.certifications,
    required this.openingHours,
    required this.rating,
    required this.reviewCount,
    required this.paymentMethods,
    required this.isOpen,
    required this.services,
    required this.images,
    required this.socialMedia,
  });

  factory LocalStore.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return LocalStore(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] as GeoPoint,
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      website: data['website'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      openingHours: data['openingHours'] ?? {},
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
      isOpen: data['isOpen'] ?? false,
      services: data['services'] ?? {},
      images: List<String>.from(data['images'] ?? []),
      socialMedia: data['socialMedia'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'categories': categories,
      'certifications': certifications,
      'openingHours': openingHours,
      'rating': rating,
      'reviewCount': reviewCount,
      'paymentMethods': paymentMethods,
      'isOpen': isOpen,
      'services': services,
      'images': images,
      'socialMedia': socialMedia,
    };
  }

  LocalStore copyWith({
    String? id,
    String? name,
    String? description,
    GeoPoint? location,
    String? address,
    String? phoneNumber,
    String? email,
    String? website,
    List<String>? categories,
    List<String>? certifications,
    Map<String, dynamic>? openingHours,
    double? rating,
    int? reviewCount,
    List<String>? paymentMethods,
    bool? isOpen,
    Map<String, dynamic>? services,
    List<String>? images,
    Map<String, dynamic>? socialMedia,
  }) {
    return LocalStore(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      categories: categories ?? this.categories,
      certifications: certifications ?? this.certifications,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isOpen: isOpen ?? this.isOpen,
      services: services ?? this.services,
      images: images ?? this.images,
      socialMedia: socialMedia ?? this.socialMedia,
    );
  }

  String get formattedAddress {
    return address.replaceAll(', ', '\n');
  }

  String get formattedPhoneNumber {
    // Format: +33 1 23 45 67 89
    if (phoneNumber.length == 10) {
      return '+33 ${phoneNumber.substring(0, 2)} ${phoneNumber.substring(2, 4)} ${phoneNumber.substring(4, 6)} ${phoneNumber.substring(6, 8)} ${phoneNumber.substring(8)}';
    }
    return phoneNumber;
  }

  Map<String, String> get formattedOpeningHours {
    final Map<String, String> formatted = {};
    openingHours.forEach((key, value) {
      if (value is Map) {
        formatted[key] = '${value['open']} - ${value['close']}';
      }
    });
    return formatted;
  }
} 