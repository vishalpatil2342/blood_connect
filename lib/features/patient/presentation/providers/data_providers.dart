import 'package:blood_connect/core/providers/firebase_providers.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/core/models/user_model.dart';
import 'package:blood_connect/features/patient/data/repositories/donor_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/request_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/donation_repository.dart';
import 'package:blood_connect/core/models/donation_model.dart';
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

// User's Own Requests Provider
final myRequestsProvider = StreamProvider<List<BloodRequest>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(requestRepositoryProvider).getUserRequests(user.uid);
});

// User's Own Donations Provider
final myDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
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

// Filtered Donors Provider (obs: now depends on the search query provider automatically)
final filteredDonorsProvider = Provider<List<UserModel>>((ref) {
  final query = ref.watch(donorSearchQueryProvider);
  final donorsAsync = ref.watch(allDonorsProvider);
  
  return donorsAsync.when(
    data: (donors) {
      if (query.isEmpty) return donors;
      final lowercaseQuery = query.toLowerCase();
      return donors.where((donor) {
        return donor.name.toLowerCase().contains(lowercaseQuery) ||
               donor.bloodType.toLowerCase().contains(lowercaseQuery) ||
               donor.location.toLowerCase().contains(lowercaseQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
