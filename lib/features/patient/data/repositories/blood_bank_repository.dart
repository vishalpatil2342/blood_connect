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

  Future<int> requestBlood({
    required String bankId,
    required String bloodType,
    required int units,
    required String patientName,
    required String urgency,
    required String location,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final bankDoc = _bloodBanks.doc(bankId);
      final snapshot = await transaction.get(bankDoc);

      if (!snapshot.exists) {
        throw Exception('Blood Bank not found');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final inventory = Map<String, int>.from(data['inventory'] ?? {});
      final currentUnits = inventory[bloodType] ?? 0;

      if (currentUnits < units) {
        throw Exception('Insufficient blood units available ($currentUnits units left)');
      }

      // Decrement units
      final newUnits = currentUnits - units;
      inventory[bloodType] = newUnits;

      // Update inventory
      transaction.update(bankDoc, {'inventory': inventory});

      // Add to blood_requests
      final requestRef = _firestore.collection('requests').doc(); // Keep consistent with existing collection
      transaction.set(requestRef, {
        'patientName': patientName,
        'city': location,
        'hospital': data['hospitalName'] ?? '',
        'bloodType': bloodType,
        'mobile': '', // UI should handle this
        'requesterId': '', // UI should handle this
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return newUnits;
    });
  }

  Future<void> addBloodBank(BloodBankModel bloodBank) async {
    await _bloodBanks.add(bloodBank.toMap());
  }
}
