import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? senderId;
  final String? senderName;
  final String? type; // 'emergency', 'donor_found', 'offer_accepted', 'offer_declined'
  final String? requestId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.senderId,
    this.senderName,
    this.type,
    this.requestId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      senderId: map['senderId'],
      senderName: map['senderName'],
      type: map['type'],
      requestId: map['requestId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
      'senderId': senderId,
      'senderName': senderName,
      'type': type,
      'requestId': requestId,
    };
  }
}
