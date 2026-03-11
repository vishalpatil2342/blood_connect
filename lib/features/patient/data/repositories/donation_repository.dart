import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_connect/core/models/donation_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepository(firestore: ref.watch(firestoreProvider));
});

class DonationRepository {
  final FirebaseFirestore _firestore;

  DonationRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _donations => _firestore.collection('donations');

  Stream<List<Donation>> getUserDonations(String userId) {
    return _donations
        .where('donorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Donation.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> createDonation(Donation donation) async {
    await _donations.add(donation.toMap());
  }
}
