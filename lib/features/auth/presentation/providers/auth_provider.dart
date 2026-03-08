import 'package:blood_connect/core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global provider for the database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Ensure the database is closed when the provider is destroyed
  ref.onDispose(() => database.close());

  return database;
});



