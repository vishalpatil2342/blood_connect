import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequest {
  final String id;
  final String patientName;
  final String city;
  final String hospital;
  final String bloodType;
  final String mobile;
  final String requesterId;
  final String status; // e.g., 'pending', 'fulfilled'
  final DateTime createdAt;

  BloodRequest({
    required this.id,
    required this.patientName,
    required this.city,
    required this.hospital,
    required this.bloodType,
    required this.mobile,
    required this.requesterId,
    required this.status,
    required this.createdAt,
  });

  factory BloodRequest.fromMap(Map<String, dynamic> map, String id) {
    return BloodRequest(
      id: id,
      patientName: map['patientName'] ?? '',
      city: map['city'] ?? '',
      hospital: map['hospital'] ?? '',
      bloodType: map['bloodType'] ?? '',
      mobile: map['mobile'] ?? '',
      requesterId: map['requesterId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'city': city,
      'hospital': hospital,
      'bloodType': bloodType,
      'mobile': mobile,
      'requesterId': requesterId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
