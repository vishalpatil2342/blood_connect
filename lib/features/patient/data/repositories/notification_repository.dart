import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_connect/core/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(firestore: ref.watch(firestoreProvider));
});

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _notifications => _firestore.collection('notifications');

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _notifications.add(notification.toMap());
  }

  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }
}
