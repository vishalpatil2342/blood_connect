import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/database/app_database.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';

// Provider to fetch all blood requests from Drift
final bloodRequestsProvider = FutureProvider<List<LocalBloodRequest>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllRequests();
});

// Modern AsyncNotifier to handle adding a request
class BloodRequestNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state does nothing
  }

  Future<void> addRequest(LocalBloodRequestsCompanion request) async {
    state = const AsyncLoading();
    try {
      final db = ref.read(databaseProvider);
      await db.insertRequest(request);
      
      // Invalidate the fetch provider so the UI updates with the new list
      ref.invalidate(bloodRequestsProvider);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final bloodRequestActionProvider = AsyncNotifierProvider<BloodRequestNotifier, void>(
  () => BloodRequestNotifier(),
);