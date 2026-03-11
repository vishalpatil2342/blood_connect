import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id;
  final String donorId;
  final String? requestId; // Optional, if they donated responding to a specific request
  final String hospital;
  final String bloodType;
  final String status; // 'booked', 'completed', 'cancelled'
  final DateTime donationDate;

  Donation({
    required this.id,
    required this.donorId,
    this.requestId,
    required this.hospital,
    required this.bloodType,
    required this.status,
    required this.donationDate,
  });

  factory Donation.fromMap(Map<String, dynamic> map, String id) {
    return Donation(
      id: id,
      donorId: map['donorId'] ?? '',
      requestId: map['requestId'],
      hospital: map['hospital'] ?? '',
      bloodType: map['bloodType'] ?? '',
      status: map['status'] ?? 'completed',
      donationDate: (map['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      if (requestId != null) 'requestId': requestId,
      'hospital': hospital,
      'bloodType': bloodType,
      'status': status,
      'donationDate': Timestamp.fromDate(donationDate),
    };
  }
}
