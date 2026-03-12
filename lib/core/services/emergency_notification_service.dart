import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/core/models/notification_model.dart';
import 'package:blood_connect/core/utils/blood_compatibility.dart';
import 'package:blood_connect/features/patient/data/repositories/donor_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emergencyNotificationServiceProvider = Provider<EmergencyNotificationService>((ref) {
  return EmergencyNotificationService(
    donorRepository: ref.watch(donorRepositoryProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

class EmergencyNotificationService {
  final DonorRepository _donorRepository;
  final NotificationRepository _notificationRepository;

  EmergencyNotificationService({
    required DonorRepository donorRepository,
    required NotificationRepository notificationRepository,
  })  : _donorRepository = donorRepository,
        _notificationRepository = notificationRepository;

  Future<void> broadcastEmergencyRequest(BloodRequest request) async {
    // 1. Get all donors
    final donors = await _donorRepository.getAllDonors().first;

    // 2. Filter by location (same city) and compatibility
    final nearbyCompatibleDonors = donors.where((donor) {
      // Don't notify the requester
      if (donor.uid == request.requesterId) return false;

      // Match city
      if (donor.location.toLowerCase() != request.city.toLowerCase()) return false;

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
          message: 'A patient (${request.patientName}) needs ${request.bloodType} blood at ${request.hospital} in ${request.city}.',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    });

    await Future.wait(futures);
  }

  Future<void> notifyBankStockZero(BloodBankModel bank, String bloodType) async {
    // 1. Get all donors
    final donors = await _donorRepository.getAllDonors().first;

    // 2. Filter by location (same city) and compatibility (people who can donate THIS blood type)
    final nearbyCompatibleDonors = donors.where((donor) {
      // Match city
      if (donor.location.toLowerCase() != bank.location.toLowerCase()) return false;

      // Check if this donor CAN donate the blood type that is now at zero
      return BloodCompatibility.canDonate(
        donorBloodType: donor.bloodType,
        receiverBloodType: bloodType,
      );
    }).toList();

    // 3. Create notifications
    final futures = nearbyCompatibleDonors.map((donor) {
      return _notificationRepository.createNotification(
        NotificationModel(
          id: '',
          userId: donor.uid,
          title: '⚠️ Critical Stock Alert: $bloodType',
          message: '${bank.name} (${bank.hospitalName}) has run out of $bloodType blood. If you are compatible, please consider donating today!',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    });

    await Future.wait(futures);
  }
}
