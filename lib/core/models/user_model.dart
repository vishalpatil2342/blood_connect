import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String bloodType;
  final String location;
  final String photoUrl;
  final DateTime createdAt;
  final String authProvider;
  final bool isAvailableForDonation;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodType,
    required this.location,
    required this.photoUrl,
    required this.createdAt,
    required this.authProvider,
    this.isAvailableForDonation = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodType: map['bloodType'] ?? 'Unknown',
      location: map['location'] ?? 'Unknown Location',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authProvider: map['authProvider'] ?? 'email',
      isAvailableForDonation: map['isAvailableForDonation'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bloodType': bloodType,
      'location': location,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'authProvider': authProvider,
      'isAvailableForDonation': isAvailableForDonation,
    };
  }
}
