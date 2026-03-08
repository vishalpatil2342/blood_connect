// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalBloodRequestsTable extends LocalBloodRequests
    with TableInfo<$LocalBloodRequestsTable, LocalBloodRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBloodRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patientNameMeta = const VerificationMeta(
    'patientName',
  );
  @override
  late final GeneratedColumn<String> patientName = GeneratedColumn<String>(
    'patient_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bloodGroupMeta = const VerificationMeta(
    'bloodGroup',
  );
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
    'blood_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hospitalNameMeta = const VerificationMeta(
    'hospitalName',
  );
  @override
  late final GeneratedColumn<String> hospitalName = GeneratedColumn<String>(
    'hospital_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urgencyMeta = const VerificationMeta(
    'urgency',
  );
  @override
  late final GeneratedColumn<String> urgency = GeneratedColumn<String>(
    'urgency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientName,
    bloodGroup,
    hospitalName,
    urgency,
    requestedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_blood_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBloodRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_name')) {
      context.handle(
        _patientNameMeta,
        patientName.isAcceptableOrUnknown(
          data['patient_name']!,
          _patientNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientNameMeta);
    }
    if (data.containsKey('blood_group')) {
      context.handle(
        _bloodGroupMeta,
        bloodGroup.isAcceptableOrUnknown(data['blood_group']!, _bloodGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_bloodGroupMeta);
    }
    if (data.containsKey('hospital_name')) {
      context.handle(
        _hospitalNameMeta,
        hospitalName.isAcceptableOrUnknown(
          data['hospital_name']!,
          _hospitalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hospitalNameMeta);
    }
    if (data.containsKey('urgency')) {
      context.handle(
        _urgencyMeta,
        urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta),
      );
    } else if (isInserting) {
      context.missing(_urgencyMeta);
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBloodRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBloodRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_name'],
      )!,
      bloodGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_group'],
      )!,
      hospitalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hospital_name'],
      )!,
      urgency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urgency'],
      )!,
      requestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_at'],
      )!,
    );
  }

  @override
  $LocalBloodRequestsTable createAlias(String alias) {
    return $LocalBloodRequestsTable(attachedDatabase, alias);
  }
}

class LocalBloodRequest extends DataClass
    implements Insertable<LocalBloodRequest> {
  final int id;
  final String patientName;
  final String bloodGroup;
  final String hospitalName;
  final String urgency;
  final DateTime requestedAt;
  const LocalBloodRequest({
    required this.id,
    required this.patientName,
    required this.bloodGroup,
    required this.hospitalName,
    required this.urgency,
    required this.requestedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patient_name'] = Variable<String>(patientName);
    map['blood_group'] = Variable<String>(bloodGroup);
    map['hospital_name'] = Variable<String>(hospitalName);
    map['urgency'] = Variable<String>(urgency);
    map['requested_at'] = Variable<DateTime>(requestedAt);
    return map;
  }

  LocalBloodRequestsCompanion toCompanion(bool nullToAbsent) {
    return LocalBloodRequestsCompanion(
      id: Value(id),
      patientName: Value(patientName),
      bloodGroup: Value(bloodGroup),
      hospitalName: Value(hospitalName),
      urgency: Value(urgency),
      requestedAt: Value(requestedAt),
    );
  }

  factory LocalBloodRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBloodRequest(
      id: serializer.fromJson<int>(json['id']),
      patientName: serializer.fromJson<String>(json['patientName']),
      bloodGroup: serializer.fromJson<String>(json['bloodGroup']),
      hospitalName: serializer.fromJson<String>(json['hospitalName']),
      urgency: serializer.fromJson<String>(json['urgency']),
      requestedAt: serializer.fromJson<DateTime>(json['requestedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patientName': serializer.toJson<String>(patientName),
      'bloodGroup': serializer.toJson<String>(bloodGroup),
      'hospitalName': serializer.toJson<String>(hospitalName),
      'urgency': serializer.toJson<String>(urgency),
      'requestedAt': serializer.toJson<DateTime>(requestedAt),
    };
  }

  LocalBloodRequest copyWith({
    int? id,
    String? patientName,
    String? bloodGroup,
    String? hospitalName,
    String? urgency,
    DateTime? requestedAt,
  }) => LocalBloodRequest(
    id: id ?? this.id,
    patientName: patientName ?? this.patientName,
    bloodGroup: bloodGroup ?? this.bloodGroup,
    hospitalName: hospitalName ?? this.hospitalName,
    urgency: urgency ?? this.urgency,
    requestedAt: requestedAt ?? this.requestedAt,
  );
  LocalBloodRequest copyWithCompanion(LocalBloodRequestsCompanion data) {
    return LocalBloodRequest(
      id: data.id.present ? data.id.value : this.id,
      patientName: data.patientName.present
          ? data.patientName.value
          : this.patientName,
      bloodGroup: data.bloodGroup.present
          ? data.bloodGroup.value
          : this.bloodGroup,
      hospitalName: data.hospitalName.present
          ? data.hospitalName.value
          : this.hospitalName,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      requestedAt: data.requestedAt.present
          ? data.requestedAt.value
          : this.requestedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBloodRequest(')
          ..write('id: $id, ')
          ..write('patientName: $patientName, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('hospitalName: $hospitalName, ')
          ..write('urgency: $urgency, ')
          ..write('requestedAt: $requestedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientName,
    bloodGroup,
    hospitalName,
    urgency,
    requestedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBloodRequest &&
          other.id == this.id &&
          other.patientName == this.patientName &&
          other.bloodGroup == this.bloodGroup &&
          other.hospitalName == this.hospitalName &&
          other.urgency == this.urgency &&
          other.requestedAt == this.requestedAt);
}

class LocalBloodRequestsCompanion extends UpdateCompanion<LocalBloodRequest> {
  final Value<int> id;
  final Value<String> patientName;
  final Value<String> bloodGroup;
  final Value<String> hospitalName;
  final Value<String> urgency;
  final Value<DateTime> requestedAt;
  const LocalBloodRequestsCompanion({
    this.id = const Value.absent(),
    this.patientName = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.hospitalName = const Value.absent(),
    this.urgency = const Value.absent(),
    this.requestedAt = const Value.absent(),
  });
  LocalBloodRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String patientName,
    required String bloodGroup,
    required String hospitalName,
    required String urgency,
    this.requestedAt = const Value.absent(),
  }) : patientName = Value(patientName),
       bloodGroup = Value(bloodGroup),
       hospitalName = Value(hospitalName),
       urgency = Value(urgency);
  static Insertable<LocalBloodRequest> custom({
    Expression<int>? id,
    Expression<String>? patientName,
    Expression<String>? bloodGroup,
    Expression<String>? hospitalName,
    Expression<String>? urgency,
    Expression<DateTime>? requestedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientName != null) 'patient_name': patientName,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (hospitalName != null) 'hospital_name': hospitalName,
      if (urgency != null) 'urgency': urgency,
      if (requestedAt != null) 'requested_at': requestedAt,
    });
  }

  LocalBloodRequestsCompanion copyWith({
    Value<int>? id,
    Value<String>? patientName,
    Value<String>? bloodGroup,
    Value<String>? hospitalName,
    Value<String>? urgency,
    Value<DateTime>? requestedAt,
  }) {
    return LocalBloodRequestsCompanion(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      hospitalName: hospitalName ?? this.hospitalName,
      urgency: urgency ?? this.urgency,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patientName.present) {
      map['patient_name'] = Variable<String>(patientName.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (hospitalName.present) {
      map['hospital_name'] = Variable<String>(hospitalName.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<String>(urgency.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBloodRequestsCompanion(')
          ..write('id: $id, ')
          ..write('patientName: $patientName, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('hospitalName: $hospitalName, ')
          ..write('urgency: $urgency, ')
          ..write('requestedAt: $requestedAt')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, email, password];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String name;
  final String email;
  final String password;
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      password: Value(password),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
    };
  }

  User copyWith({int? id, String? name, String? email, String? password}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.password == this.password);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> password;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String password,
  }) : name = Value(name),
       email = Value(email),
       password = Value(password);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? password,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? password,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalBloodRequestsTable localBloodRequests =
      $LocalBloodRequestsTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localBloodRequests,
    users,
  ];
}

typedef $$LocalBloodRequestsTableCreateCompanionBuilder =
    LocalBloodRequestsCompanion Function({
      Value<int> id,
      required String patientName,
      required String bloodGroup,
      required String hospitalName,
      required String urgency,
      Value<DateTime> requestedAt,
    });
typedef $$LocalBloodRequestsTableUpdateCompanionBuilder =
    LocalBloodRequestsCompanion Function({
      Value<int> id,
      Value<String> patientName,
      Value<String> bloodGroup,
      Value<String> hospitalName,
      Value<String> urgency,
      Value<DateTime> requestedAt,
    });

class $$LocalBloodRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBloodRequestsTable> {
  $$LocalBloodRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hospitalName => $composableBuilder(
    column: $table.hospitalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalBloodRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBloodRequestsTable> {
  $$LocalBloodRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hospitalName => $composableBuilder(
    column: $table.hospitalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBloodRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBloodRequestsTable> {
  $$LocalBloodRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hospitalName => $composableBuilder(
    column: $table.hospitalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );
}

class $$LocalBloodRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBloodRequestsTable,
          LocalBloodRequest,
          $$LocalBloodRequestsTableFilterComposer,
          $$LocalBloodRequestsTableOrderingComposer,
          $$LocalBloodRequestsTableAnnotationComposer,
          $$LocalBloodRequestsTableCreateCompanionBuilder,
          $$LocalBloodRequestsTableUpdateCompanionBuilder,
          (
            LocalBloodRequest,
            BaseReferences<
              _$AppDatabase,
              $LocalBloodRequestsTable,
              LocalBloodRequest
            >,
          ),
          LocalBloodRequest,
          PrefetchHooks Function()
        > {
  $$LocalBloodRequestsTableTableManager(
    _$AppDatabase db,
    $LocalBloodRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBloodRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBloodRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBloodRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> patientName = const Value.absent(),
                Value<String> bloodGroup = const Value.absent(),
                Value<String> hospitalName = const Value.absent(),
                Value<String> urgency = const Value.absent(),
                Value<DateTime> requestedAt = const Value.absent(),
              }) => LocalBloodRequestsCompanion(
                id: id,
                patientName: patientName,
                bloodGroup: bloodGroup,
                hospitalName: hospitalName,
                urgency: urgency,
                requestedAt: requestedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String patientName,
                required String bloodGroup,
                required String hospitalName,
                required String urgency,
                Value<DateTime> requestedAt = const Value.absent(),
              }) => LocalBloodRequestsCompanion.insert(
                id: id,
                patientName: patientName,
                bloodGroup: bloodGroup,
                hospitalName: hospitalName,
                urgency: urgency,
                requestedAt: requestedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalBloodRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBloodRequestsTable,
      LocalBloodRequest,
      $$LocalBloodRequestsTableFilterComposer,
      $$LocalBloodRequestsTableOrderingComposer,
      $$LocalBloodRequestsTableAnnotationComposer,
      $$LocalBloodRequestsTableCreateCompanionBuilder,
      $$LocalBloodRequestsTableUpdateCompanionBuilder,
      (
        LocalBloodRequest,
        BaseReferences<
          _$AppDatabase,
          $LocalBloodRequestsTable,
          LocalBloodRequest
        >,
      ),
      LocalBloodRequest,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String name,
      required String email,
      required String password,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<String> password,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> password = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                email: email,
                password: password,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                required String password,
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                password: password,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalBloodRequestsTableTableManager get localBloodRequests =>
      $$LocalBloodRequestsTableTableManager(_db, _db.localBloodRequests);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
