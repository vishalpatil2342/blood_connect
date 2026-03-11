import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository(firestore: ref.watch(firestoreProvider));
});

class RequestRepository {
  final FirebaseFirestore _firestore;

  RequestRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _requests => _firestore.collection('requests');

  Stream<List<BloodRequest>> getEmergencyRequests() {
    return _requests
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<BloodRequest>> getUserRequests(String userId) {
    return _requests
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> createRequest(BloodRequest request) async {
    await _requests.add(request.toMap());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _requests.doc(requestId).update({'status': status});
  }
}
