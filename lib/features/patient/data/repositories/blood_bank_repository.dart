import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

final bloodBankRepositoryProvider = Provider<BloodBankRepository>((ref) {
  return BloodBankRepository(firestore: ref.watch(firestoreProvider));
});

class BloodBankRepository {
  final FirebaseFirestore _firestore;

  BloodBankRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _bloodBanks => _firestore.collection('blood_banks');

  Stream<List<BloodBankModel>> getBloodBanks() {
    return _bloodBanks.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => BloodBankModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
}
