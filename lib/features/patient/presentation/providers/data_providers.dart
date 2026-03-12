import 'package:blood_connect/core/providers/firebase_providers.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/core/models/user_model.dart';
import 'package:blood_connect/features/patient/data/repositories/donor_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/request_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/donation_repository.dart';
import 'package:blood_connect/core/models/donation_model.dart';
import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:blood_connect/features/patient/data/repositories/blood_bank_repository.dart';
import 'package:blood_connect/core/models/notification_model.dart';
import 'package:blood_connect/features/patient/data/repositories/notification_repository.dart';
import 'package:blood_connect/core/utils/blood_compatibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Current User Profile Provider
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(donorRepositoryProvider).getUserProfile(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Emergency Requests Provider
final emergencyRequestsProvider = StreamProvider<List<BloodRequest>>((ref) {
  return ref.watch(requestRepositoryProvider).getEmergencyRequests();
});

// Compatible Emergency Requests Provider
final compatibleEmergencyRequestsProvider = Provider<AsyncValue<List<BloodRequest>>>((ref) {
  final requestsAsync = ref.watch(emergencyRequestsProvider);
  final userAsync = ref.watch(userProfileProvider);

  return requestsAsync.when(
    data: (requests) {
      return userAsync.when(
        data: (user) {
          if (user == null) return AsyncValue.data(requests);
          
          final filtered = requests.where((request) {
            return BloodCompatibility.canDonate(
              donorBloodType: user.bloodType,
              receiverBloodType: request.bloodType,
            );
          }).toList();
          
          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncLoading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    },
    loading: () => const AsyncLoading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// User's Own Requests Provider
final myRequestsProvider = StreamProvider<List<BloodRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(requestRepositoryProvider).getUserRequests(user.uid);
});

// User's Own Donations Provider
final myDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(donationRepositoryProvider).getUserDonations(user.uid);
});

// All Donors Provider
final allDonorsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(donorRepositoryProvider).getAllDonors();
});

// Search Query Provider
class DonorSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final donorSearchQueryProvider = NotifierProvider<DonorSearchQuery, String>(() {
  return DonorSearchQuery();
});

// Availability Filter Provider
class DonorAvailabilityFilter extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle(bool value) => state = value;
}

final donorAvailabilityFilterProvider =
    NotifierProvider<DonorAvailabilityFilter, bool>(() {
      return DonorAvailabilityFilter();
    });

// lib/features/patient/presentation/providers/data_providers.dart
final filteredDonorsProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final query = ref.watch(donorSearchQueryProvider).toLowerCase();
  final isAvailableOnly = ref.watch(donorAvailabilityFilterProvider);
  final donorsAsync = ref.watch(allDonorsProvider);
  final currentUser = ref.watch(firebaseAuthProvider).currentUser;

  return donorsAsync.whenData((donors) {
    // 1. First, always filter out the current user
    var filtered = donors;
    if (currentUser != null) {
      filtered = filtered
          .where((donor) => donor.uid != currentUser.uid)
          .toList();
    }

    // 2. Filter by availability if toggled
    if (isAvailableOnly) {
      filtered = filtered
          .where((donor) => donor.isAvailableForDonation)
          .toList();
    }

    // 3. Then, apply the search query if it's not empty
    if (query.isEmpty) return filtered;

    return filtered.where((donor) {
      return donor.name.toLowerCase().contains(query) ||
          donor.bloodType.toLowerCase().contains(query) ||
          donor.location.toLowerCase().contains(query);
    }).toList();
  });
});

// Blood Banks Provider
final bloodBanksProvider = StreamProvider<List<BloodBankModel>>((ref) {
  return ref.watch(bloodBankRepositoryProvider).getBloodBanks();
});

// Nearby Blood Banks Provider (Filtered by user location)
final nearbyBloodBanksProvider = Provider<AsyncValue<List<BloodBankModel>>>((ref) {
  final bloodBanksAsync = ref.watch(bloodBanksProvider);
  final userProfileAsync = ref.watch(userProfileProvider);

  return bloodBanksAsync.when(
    data: (bloodBanks) {
      return userProfileAsync.when(
        data: (user) {
          if (user == null) return const AsyncValue.data([]);
          final filtered = bloodBanks
              .where((bank) =>
                  bank.location.toLowerCase() == user.location.toLowerCase())
              .toList();
          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncLoading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    },
    loading: () => const AsyncLoading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// User Notifications Provider
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(notificationRepositoryProvider)
      .getUserNotifications(user.uid);
});
