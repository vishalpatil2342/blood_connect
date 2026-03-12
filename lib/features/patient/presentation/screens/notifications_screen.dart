import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:blood_connect/core/models/notification_model.dart';
import 'package:blood_connect/features/patient/data/repositories/notification_repository.dart';
import 'package:blood_connect/core/services/emergency_notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFE60000)),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.black87)),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text("You have no new notifications.", style: TextStyle(color: Colors.black87)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(
                context, 
                ref,
                notification,
              );
            },
          );
        },
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} mins ago';
    return 'Just now';
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationRepositoryProvider).markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !notification.isRead ? const Color(0xFFFFF0F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: !notification.isRead ? const Color(0xFFE60000).withValues(alpha: 0.3) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: !notification.isRead ? const Color(0xFFE60000) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop,
                color: !notification.isRead ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: !notification.isRead ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _getTimeAgo(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if ((notification.type == 'donor_found' || notification.type == 'direct_request') && !notification.isRead) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleAction(ref, notification, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleAction(ref, notification, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(WidgetRef ref, NotificationModel notification, bool isAccept) async {
    final repo = ref.read(notificationRepositoryProvider);
    final notificationService = ref.read(emergencyNotificationServiceProvider);
    final currentUser = ref.read(userProfileProvider).value;

    if (currentUser == null || notification.senderId == null) return;

    // 1. Mark current notification as read
    await repo.markAsRead(notification.id);

    // 2. Send reciprocal notification back to the donor
    final message = isAccept 
        ? '${currentUser.name} has accepted your donation offer! Please check your messages or contact them directly.'
        : 'Sorry, ${currentUser.name} has declined your donation offer for now. Thank you for your willingness to help!';

    await notificationService.notifyDonationAction(
      recipientId: notification.senderId!,
      senderId: currentUser.uid,
      senderName: currentUser.name,
      message: message,
      isAccept: isAccept,
    );
  }
}
