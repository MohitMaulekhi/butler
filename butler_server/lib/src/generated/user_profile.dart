/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class UserProfile
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserProfile._({
    this.id,
    required this.userId,
    required this.name,
    this.bio,
    this.goals,
    this.preferences,
    this.phoneNumber,
    this.timezone,
    this.dateOfBirth,
    this.location,
  });

  factory UserProfile({
    int? id,
    required String userId,
    required String name,
    String? bio,
    String? goals,
    String? preferences,
    String? phoneNumber,
    String? timezone,
    DateTime? dateOfBirth,
    String? location,
  }) = _UserProfileImpl;

  factory UserProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProfile(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      name: jsonSerialization['name'] as String,
      bio: jsonSerialization['bio'] as String?,
      goals: jsonSerialization['goals'] as String?,
      preferences: jsonSerialization['preferences'] as String?,
      phoneNumber: jsonSerialization['phoneNumber'] as String?,
      timezone: jsonSerialization['timezone'] as String?,
      dateOfBirth: jsonSerialization['dateOfBirth'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['dateOfBirth'],
            ),
      location: jsonSerialization['location'] as String?,
    );
  }

  static final t = UserProfileTable();

  static const db = UserProfileRepository._();

  @override
  int? id;

  String userId;

  String name;

  String? bio;

  String? goals;

  String? preferences;

  String? phoneNumber;

  String? timezone;

  DateTime? dateOfBirth;

  String? location;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserProfile copyWith({
    int? id,
    String? userId,
    String? name,
    String? bio,
    String? goals,
    String? preferences,
    String? phoneNumber,
    String? timezone,
    DateTime? dateOfBirth,
    String? location,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      if (bio != null) 'bio': bio,
      if (goals != null) 'goals': goals,
      if (preferences != null) 'preferences': preferences,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (timezone != null) 'timezone': timezone,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth?.toJson(),
      if (location != null) 'location': location,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      if (bio != null) 'bio': bio,
      if (goals != null) 'goals': goals,
      if (preferences != null) 'preferences': preferences,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (timezone != null) 'timezone': timezone,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth?.toJson(),
      if (location != null) 'location': location,
    };
  }

  static UserProfileInclude include() {
    return UserProfileInclude._();
  }

  static UserProfileIncludeList includeList({
    _i1.WhereExpressionBuilder<UserProfileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserProfileTable>? orderByList,
    UserProfileInclude? include,
  }) {
    return UserProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserProfile.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserProfileImpl extends UserProfile {
  _UserProfileImpl({
    int? id,
    required String userId,
    required String name,
    String? bio,
    String? goals,
    String? preferences,
    String? phoneNumber,
    String? timezone,
    DateTime? dateOfBirth,
    String? location,
  }) : super._(
         id: id,
         userId: userId,
         name: name,
         bio: bio,
         goals: goals,
         preferences: preferences,
         phoneNumber: phoneNumber,
         timezone: timezone,
         dateOfBirth: dateOfBirth,
         location: location,
       );

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserProfile copyWith({
    Object? id = _Undefined,
    String? userId,
    String? name,
    Object? bio = _Undefined,
    Object? goals = _Undefined,
    Object? preferences = _Undefined,
    Object? phoneNumber = _Undefined,
    Object? timezone = _Undefined,
    Object? dateOfBirth = _Undefined,
    Object? location = _Undefined,
  }) {
    return UserProfile(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      bio: bio is String? ? bio : this.bio,
      goals: goals is String? ? goals : this.goals,
      preferences: preferences is String? ? preferences : this.preferences,
      phoneNumber: phoneNumber is String? ? phoneNumber : this.phoneNumber,
      timezone: timezone is String? ? timezone : this.timezone,
      dateOfBirth: dateOfBirth is DateTime? ? dateOfBirth : this.dateOfBirth,
      location: location is String? ? location : this.location,
    );
  }
}

class UserProfileUpdateTable extends _i1.UpdateTable<UserProfileTable> {
  UserProfileUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> bio(String? value) => _i1.ColumnValue(
    table.bio,
    value,
  );

  _i1.ColumnValue<String, String> goals(String? value) => _i1.ColumnValue(
    table.goals,
    value,
  );

  _i1.ColumnValue<String, String> preferences(String? value) => _i1.ColumnValue(
    table.preferences,
    value,
  );

  _i1.ColumnValue<String, String> phoneNumber(String? value) => _i1.ColumnValue(
    table.phoneNumber,
    value,
  );

  _i1.ColumnValue<String, String> timezone(String? value) => _i1.ColumnValue(
    table.timezone,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> dateOfBirth(DateTime? value) =>
      _i1.ColumnValue(
        table.dateOfBirth,
        value,
      );

  _i1.ColumnValue<String, String> location(String? value) => _i1.ColumnValue(
    table.location,
    value,
  );
}

class UserProfileTable extends _i1.Table<int?> {
  UserProfileTable({super.tableRelation}) : super(tableName: 'user_profile') {
    updateTable = UserProfileUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    bio = _i1.ColumnString(
      'bio',
      this,
    );
    goals = _i1.ColumnString(
      'goals',
      this,
    );
    preferences = _i1.ColumnString(
      'preferences',
      this,
    );
    phoneNumber = _i1.ColumnString(
      'phoneNumber',
      this,
    );
    timezone = _i1.ColumnString(
      'timezone',
      this,
    );
    dateOfBirth = _i1.ColumnDateTime(
      'dateOfBirth',
      this,
    );
    location = _i1.ColumnString(
      'location',
      this,
    );
  }

  late final UserProfileUpdateTable updateTable;

  late final _i1.ColumnString userId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString bio;

  late final _i1.ColumnString goals;

  late final _i1.ColumnString preferences;

  late final _i1.ColumnString phoneNumber;

  late final _i1.ColumnString timezone;

  late final _i1.ColumnDateTime dateOfBirth;

  late final _i1.ColumnString location;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    name,
    bio,
    goals,
    preferences,
    phoneNumber,
    timezone,
    dateOfBirth,
    location,
  ];
}

class UserProfileInclude extends _i1.IncludeObject {
  UserProfileInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserProfile.t;
}

class UserProfileIncludeList extends _i1.IncludeList {
  UserProfileIncludeList._({
    _i1.WhereExpressionBuilder<UserProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserProfile.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserProfile.t;
}

class UserProfileRepository {
  const UserProfileRepository._();

  /// Returns a list of [UserProfile]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UserProfile>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserProfileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserProfileTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserProfile>(
      where: where?.call(UserProfile.t),
      orderBy: orderBy?.call(UserProfile.t),
      orderByList: orderByList?.call(UserProfile.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [UserProfile] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UserProfile?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserProfileTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserProfileTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<UserProfile>(
      where: where?.call(UserProfile.t),
      orderBy: orderBy?.call(UserProfile.t),
      orderByList: orderByList?.call(UserProfile.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [UserProfile] by its [id] or null if no such row exists.
  Future<UserProfile?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<UserProfile>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [UserProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [UserProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<UserProfile>> insert(
    _i1.Session session,
    List<UserProfile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserProfile>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [UserProfile] and returns the inserted row.
  ///
  /// The returned [UserProfile] will have its `id` field set.
  Future<UserProfile> insertRow(
    _i1.Session session,
    UserProfile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserProfile>> update(
    _i1.Session session,
    List<UserProfile> rows, {
    _i1.ColumnSelections<UserProfileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserProfile>(
      rows,
      columns: columns?.call(UserProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserProfile> updateRow(
    _i1.Session session,
    UserProfile row, {
    _i1.ColumnSelections<UserProfileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserProfile>(
      row,
      columns: columns?.call(UserProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserProfile?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserProfileUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserProfile>(
      id,
      columnValues: columnValues(UserProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserProfile>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserProfileUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserProfileTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserProfileTable>? orderBy,
    _i1.OrderByListBuilder<UserProfileTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserProfile>(
      columnValues: columnValues(UserProfile.t.updateTable),
      where: where(UserProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserProfile.t),
      orderByList: orderByList?.call(UserProfile.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserProfile]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserProfile>> delete(
    _i1.Session session,
    List<UserProfile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserProfile>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserProfile].
  Future<UserProfile> deleteRow(
    _i1.Session session,
    UserProfile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserProfile>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserProfileTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserProfile>(
      where: where(UserProfile.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserProfileTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserProfile>(
      where: where?.call(UserProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
