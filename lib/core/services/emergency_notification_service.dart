import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/core/models/notification_model.dart';
import 'package:blood_connect/core/utils/blood_compatibility.dart';
import 'package:blood_connect/features/patient/data/repositories/donor_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/notification_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/request_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emergencyNotificationServiceProvider = Provider<EmergencyNotificationService>((ref) {
  return EmergencyNotificationService(
    donorRepository: ref.watch(donorRepositoryProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
    requestRepository: ref.watch(requestRepositoryProvider),
  );
});

class EmergencyNotificationService {
  final DonorRepository _donorRepository;
  final NotificationRepository _notificationRepository;
  final RequestRepository _requestRepository;

  EmergencyNotificationService({
    required DonorRepository donorRepository,
    required NotificationRepository notificationRepository,
    required RequestRepository requestRepository,
  })  : _donorRepository = donorRepository,
        _notificationRepository = notificationRepository,
        _requestRepository = requestRepository;

  Future<void> saveAndBroadcastEmergencyRequest(BloodRequest request) async {
    // 1. Save to Firestore first so it shows up in the feed
    await _requestRepository.createRequest(request);

    // 2. Broadcast notifications to donors
    await broadcastEmergencyRequest(request);
  }

  String _extractState(String location) {
    if (!location.contains(',')) return location.trim().toLowerCase();
    return location.split(',').last.trim().toLowerCase();
  }

  Future<void> broadcastEmergencyRequest(BloodRequest request) async {
    // 1. Get all donors
    final donors = await _donorRepository.getAllDonors().first;

    final requestState = _extractState(request.city);

    // 2. Filter by location (same state) and compatibility
    final nearbyCompatibleDonors = donors.where((donor) {
      // Don't notify the requester
      if (donor.uid == request.requesterId) return false;

      // Match state
      final donorState = _extractState(donor.location);
      if (donorState != requestState) return false;

      // Check blood compatibility
      return BloodCompatibility.canDonate(
        donorBloodType: donor.bloodType,
        receiverBloodType: request.bloodType,
      );
    }).toList();

    // 3. Create notifications for each donor
    final futures = nearbyCompatibleDonors.map((donor) {
      return _notificationRepository.createNotification(
        NotificationModel(
          id: '', // Firestore auto-generates
          userId: donor.uid,
          title: '🚨 Emergency Blood Request!',
          message:
              'A patient (${request.patientName}) needs ${request.bloodType} blood at ${request.hospital} in ${request.city}.',
          isRead: false,
          createdAt: DateTime.now(),
          senderId: request.requesterId,
          type: 'emergency',
          requestId: request.id,
        ),
      );
    });

    await Future.wait(futures);
  }

  Future<void> notifyBankStockZero(BloodBankModel bank, String bloodType) async {
    final donors = await _donorRepository.getAllDonors().first;
    final bankState = _extractState(bank.location);

    final nearbyCompatibleDonors = donors.where((donor) {
      final donorState = _extractState(donor.location);
      if (donorState != bankState) return false;
      return BloodCompatibility.canDonate(
        donorBloodType: donor.bloodType,
        receiverBloodType: bloodType,
      );
    }).toList();

    final futures = nearbyCompatibleDonors.map((donor) {
      return _notificationRepository.createNotification(
        NotificationModel(
          id: '',
          userId: donor.uid,
          title: '⚠️ Critical Stock Alert: $bloodType',
          message:
              '${bank.name} (${bank.hospitalName}) has run out of $bloodType blood. If you are compatible, please consider donating today!',
          isRead: false,
          createdAt: DateTime.now(),
          type: 'stock_alert',
        ),
      );
    });

    await Future.wait(futures);
  }

  Future<void> notifySpecificDonor({
    required String donorId,
    required String senderId,
    required String senderName,
    required String phoneNumber,
    required String bloodType,
  }) async {
    await _notificationRepository.createNotification(
      NotificationModel(
        id: '',
        userId: donorId,
        title: '🩸 Direct Blood Request!',
        message:
            '$senderName urgently needs your $bloodType blood! Please contact them at $phoneNumber.',
        isRead: false,
        createdAt: DateTime.now(),
        senderId: senderId,
        senderName: senderName,
        type: 'direct_request',
      ),
    );
  }

  Future<void> notifyDonationAction({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String message,
    required bool isAccept,
  }) async {
    await _notificationRepository.createNotification(
      NotificationModel(
        id: '',
        userId: recipientId,
        title: isAccept ? '✅ Donation Accepted' : '❌ Donation Declined',
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
        senderId: senderId,
        senderName: senderName,
        type: isAccept ? 'offer_accepted' : 'offer_declined',
      ),
    );
  }
}
