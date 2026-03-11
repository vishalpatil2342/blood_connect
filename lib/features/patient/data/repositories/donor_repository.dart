import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_connect/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  return DonorRepository(firestore: ref.watch(firestoreProvider));
});

class DonorRepository {
  final FirebaseFirestore _firestore;

  DonorRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _users => _firestore.collection('users');

  Stream<List<UserModel>> getAllDonors() {
    return _users
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap(),SetOptions(merge: true));
  }

  Stream<UserModel?> getUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }
}
