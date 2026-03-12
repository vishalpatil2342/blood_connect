import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
  );
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  Stream<User?> get authStateChange => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String location,
    String bloodType,
    String phone,
  ) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save extended profile data
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'bloodType': bloodType.isEmpty ? 'Unknown' : bloodType,
        'location': location.isEmpty ? 'Unknown Location' : location,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'email',
        'isAvailableForDonation': true,
      });

      // Check if any blood bank exists near this user
      if (location.isNotEmpty && location != 'Unknown Location') {
        final existingBanks = await _firestore
            .collection('blood_banks')
            .where('location', isEqualTo: location)
            .limit(1)
            .get();

        if (existingBanks.docs.isEmpty) {
          // Create a default blood bank for this new location
          final hospitalNames = [
            'City General Hospital',
            'Metro Life Care',
            'Unity Medical Center',
            'Lifeline Multispeciality',
            'Grace Community Hospital'
          ];
          final bankNames = [
            'Red Cross Blood Bank',
            'LifeSource Blood Center',
            'Guardian Blood Services',
            'Primum Blood Hub',
            'City Central Blood Bank'
          ];

          final randomHospital =
              hospitalNames[DateTime.now().millisecond % hospitalNames.length];
          final randomBank =
              bankNames[DateTime.now().microsecond % bankNames.length];

          await _firestore.collection('blood_banks').add({
            'name': randomBank,
            'hospitalName': randomHospital,
            'location': location,
            'inventory': {
              'A+': 15,
              'A-': 15,
              'B+': 15,
              'B-': 15,
              'AB+': 15,
              'AB-': 15,
              'O+': 15,
              'O-': 15,
            },
          });
        }
      }
    }

    return userCredential;
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);

    // Save extended profile data if new user
    if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': 'Phone User',
        'email': userCredential.user!.email ?? '',
        'phone': userCredential.user!.phoneNumber ?? '',
        'bloodType': 'Unknown',
        'location': 'Unknown Location',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'phone',
        'isAvailableForDonation': true,
      });
    }

    return userCredential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}
