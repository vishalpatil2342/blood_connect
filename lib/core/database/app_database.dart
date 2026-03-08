import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// 1. ADD THIS: Create the Users table
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get password => text()(); 
}

// Example Table for caching Blood Requests locally
class LocalBloodRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patientName => text()();
  TextColumn get bloodGroup => text()();
  TextColumn get hospitalName => text()();
  TextColumn get urgency => text()();
  DateTimeColumn get requestedAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. UPDATE THIS: Add 'Users' to the tables array
@DriftDatabase(tables: [LocalBloodRequests, Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  Future<List<LocalBloodRequest>> getAllRequests() => select(localBloodRequests).get();
  Future<int> insertRequest(LocalBloodRequestsCompanion entry) => into(localBloodRequests).insert(entry);
  
  // 3. ADD THIS: Method to insert a User
  Future<int> insertUser(UsersCompanion entry) => into(users).insert(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'blood_connect_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}