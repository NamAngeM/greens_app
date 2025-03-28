class UserModel {
  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final int carbonPoints;
  final List<String>? interests;
  final Map<String, dynamic>? dailyHabits;

  UserModel({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.carbonPoints = 0,
    this.interests,
    this.dailyHabits,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      photoUrl: json['photoUrl'],
      carbonPoints: json['carbonPoints'] ?? 0,
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : null,
      dailyHabits: json['dailyHabits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'carbonPoints': carbonPoints,
      'interests': interests,
      'dailyHabits': dailyHabits,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? photoUrl,
    int? carbonPoints,
    List<String>? interests,
    Map<String, dynamic>? dailyHabits,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      carbonPoints: carbonPoints ?? this.carbonPoints,
      interests: interests ?? this.interests,
      dailyHabits: dailyHabits ?? this.dailyHabits,
    );
  }
}
