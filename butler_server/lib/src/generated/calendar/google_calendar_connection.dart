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

abstract class GoogleCalendarConnection
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  GoogleCalendarConnection._({
    this.id,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiry,
    this.googleEmail,
    required this.isActive,
    DateTime? connectedAt,
    this.lastSyncAt,
  }) : connectedAt = connectedAt ?? DateTime.now();

  factory GoogleCalendarConnection({
    int? id,
    required String userId,
    required String accessToken,
    required String refreshToken,
    required DateTime tokenExpiry,
    String? googleEmail,
    required bool isActive,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
  }) = _GoogleCalendarConnectionImpl;

  factory GoogleCalendarConnection.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GoogleCalendarConnection(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      accessToken: jsonSerialization['accessToken'] as String,
      refreshToken: jsonSerialization['refreshToken'] as String,
      tokenExpiry: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['tokenExpiry'],
      ),
      googleEmail: jsonSerialization['googleEmail'] as String?,
      isActive: jsonSerialization['isActive'] as bool,
      connectedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['connectedAt'],
      ),
      lastSyncAt: jsonSerialization['lastSyncAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSyncAt']),
    );
  }

  static final t = GoogleCalendarConnectionTable();

  static const db = GoogleCalendarConnectionRepository._();

  @override
  int? id;

  String userId;

  String accessToken;

  String refreshToken;

  DateTime tokenExpiry;

  String? googleEmail;

  bool isActive;

  DateTime connectedAt;

  DateTime? lastSyncAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [GoogleCalendarConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GoogleCalendarConnection copyWith({
    int? id,
    String? userId,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    String? googleEmail,
    bool? isActive,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GoogleCalendarConnection',
      if (id != null) 'id': id,
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiry': tokenExpiry.toJson(),
      if (googleEmail != null) 'googleEmail': googleEmail,
      'isActive': isActive,
      'connectedAt': connectedAt.toJson(),
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GoogleCalendarConnection',
      if (id != null) 'id': id,
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiry': tokenExpiry.toJson(),
      if (googleEmail != null) 'googleEmail': googleEmail,
      'isActive': isActive,
      'connectedAt': connectedAt.toJson(),
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt?.toJson(),
    };
  }

  static GoogleCalendarConnectionInclude include() {
    return GoogleCalendarConnectionInclude._();
  }

  static GoogleCalendarConnectionIncludeList includeList({
    _i1.WhereExpressionBuilder<GoogleCalendarConnectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GoogleCalendarConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GoogleCalendarConnectionTable>? orderByList,
    GoogleCalendarConnectionInclude? include,
  }) {
    return GoogleCalendarConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GoogleCalendarConnection.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GoogleCalendarConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GoogleCalendarConnectionImpl extends GoogleCalendarConnection {
  _GoogleCalendarConnectionImpl({
    int? id,
    required String userId,
    required String accessToken,
    required String refreshToken,
    required DateTime tokenExpiry,
    String? googleEmail,
    required bool isActive,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
  }) : super._(
         id: id,
         userId: userId,
         accessToken: accessToken,
         refreshToken: refreshToken,
         tokenExpiry: tokenExpiry,
         googleEmail: googleEmail,
         isActive: isActive,
         connectedAt: connectedAt,
         lastSyncAt: lastSyncAt,
       );

  /// Returns a shallow copy of this [GoogleCalendarConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GoogleCalendarConnection copyWith({
    Object? id = _Undefined,
    String? userId,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    Object? googleEmail = _Undefined,
    bool? isActive,
    DateTime? connectedAt,
    Object? lastSyncAt = _Undefined,
  }) {
    return GoogleCalendarConnection(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      googleEmail: googleEmail is String? ? googleEmail : this.googleEmail,
      isActive: isActive ?? this.isActive,
      connectedAt: connectedAt ?? this.connectedAt,
      lastSyncAt: lastSyncAt is DateTime? ? lastSyncAt : this.lastSyncAt,
    );
  }
}

class GoogleCalendarConnectionUpdateTable
    extends _i1.UpdateTable<GoogleCalendarConnectionTable> {
  GoogleCalendarConnectionUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> accessToken(String value) => _i1.ColumnValue(
    table.accessToken,
    value,
  );

  _i1.ColumnValue<String, String> refreshToken(String value) => _i1.ColumnValue(
    table.refreshToken,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> tokenExpiry(DateTime value) =>
      _i1.ColumnValue(
        table.tokenExpiry,
        value,
      );

  _i1.ColumnValue<String, String> googleEmail(String? value) => _i1.ColumnValue(
    table.googleEmail,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> connectedAt(DateTime value) =>
      _i1.ColumnValue(
        table.connectedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastSyncAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSyncAt,
        value,
      );
}

class GoogleCalendarConnectionTable extends _i1.Table<int?> {
  GoogleCalendarConnectionTable({super.tableRelation})
    : super(tableName: 'google_calendar_connection') {
    updateTable = GoogleCalendarConnectionUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    accessToken = _i1.ColumnString(
      'accessToken',
      this,
    );
    refreshToken = _i1.ColumnString(
      'refreshToken',
      this,
    );
    tokenExpiry = _i1.ColumnDateTime(
      'tokenExpiry',
      this,
    );
    googleEmail = _i1.ColumnString(
      'googleEmail',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
    connectedAt = _i1.ColumnDateTime(
      'connectedAt',
      this,
      hasDefault: true,
    );
    lastSyncAt = _i1.ColumnDateTime(
      'lastSyncAt',
      this,
    );
  }

  late final GoogleCalendarConnectionUpdateTable updateTable;

  late final _i1.ColumnString userId;

  late final _i1.ColumnString accessToken;

  late final _i1.ColumnString refreshToken;

  late final _i1.ColumnDateTime tokenExpiry;

  late final _i1.ColumnString googleEmail;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime connectedAt;

  late final _i1.ColumnDateTime lastSyncAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    accessToken,
    refreshToken,
    tokenExpiry,
    googleEmail,
    isActive,
    connectedAt,
    lastSyncAt,
  ];
}

class GoogleCalendarConnectionInclude extends _i1.IncludeObject {
  GoogleCalendarConnectionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => GoogleCalendarConnection.t;
}

class GoogleCalendarConnectionIncludeList extends _i1.IncludeList {
  GoogleCalendarConnectionIncludeList._({
    _i1.WhereExpressionBuilder<GoogleCalendarConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GoogleCalendarConnection.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => GoogleCalendarConnection.t;
}

class GoogleCalendarConnectionRepository {
  const GoogleCalendarConnectionRepository._();

  /// Returns a list of [GoogleCalendarConnection]s matching the given query parameters.
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
  Future<List<GoogleCalendarConnection>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GoogleCalendarConnectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GoogleCalendarConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GoogleCalendarConnectionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<GoogleCalendarConnection>(
      where: where?.call(GoogleCalendarConnection.t),
      orderBy: orderBy?.call(GoogleCalendarConnection.t),
      orderByList: orderByList?.call(GoogleCalendarConnection.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [GoogleCalendarConnection] matching the given query parameters.
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
  Future<GoogleCalendarConnection?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GoogleCalendarConnectionTable>? where,
    int? offset,
    _i1.OrderByBuilder<GoogleCalendarConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GoogleCalendarConnectionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<GoogleCalendarConnection>(
      where: where?.call(GoogleCalendarConnection.t),
      orderBy: orderBy?.call(GoogleCalendarConnection.t),
      orderByList: orderByList?.call(GoogleCalendarConnection.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [GoogleCalendarConnection] by its [id] or null if no such row exists.
  Future<GoogleCalendarConnection?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<GoogleCalendarConnection>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [GoogleCalendarConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [GoogleCalendarConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<GoogleCalendarConnection>> insert(
    _i1.Session session,
    List<GoogleCalendarConnection> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<GoogleCalendarConnection>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [GoogleCalendarConnection] and returns the inserted row.
  ///
  /// The returned [GoogleCalendarConnection] will have its `id` field set.
  Future<GoogleCalendarConnection> insertRow(
    _i1.Session session,
    GoogleCalendarConnection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GoogleCalendarConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GoogleCalendarConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GoogleCalendarConnection>> update(
    _i1.Session session,
    List<GoogleCalendarConnection> rows, {
    _i1.ColumnSelections<GoogleCalendarConnectionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GoogleCalendarConnection>(
      rows,
      columns: columns?.call(GoogleCalendarConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GoogleCalendarConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GoogleCalendarConnection> updateRow(
    _i1.Session session,
    GoogleCalendarConnection row, {
    _i1.ColumnSelections<GoogleCalendarConnectionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GoogleCalendarConnection>(
      row,
      columns: columns?.call(GoogleCalendarConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GoogleCalendarConnection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GoogleCalendarConnection?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<GoogleCalendarConnectionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GoogleCalendarConnection>(
      id,
      columnValues: columnValues(GoogleCalendarConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GoogleCalendarConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GoogleCalendarConnection>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<GoogleCalendarConnectionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<GoogleCalendarConnectionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GoogleCalendarConnectionTable>? orderBy,
    _i1.OrderByListBuilder<GoogleCalendarConnectionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GoogleCalendarConnection>(
      columnValues: columnValues(GoogleCalendarConnection.t.updateTable),
      where: where(GoogleCalendarConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GoogleCalendarConnection.t),
      orderByList: orderByList?.call(GoogleCalendarConnection.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GoogleCalendarConnection]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GoogleCalendarConnection>> delete(
    _i1.Session session,
    List<GoogleCalendarConnection> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GoogleCalendarConnection>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GoogleCalendarConnection].
  Future<GoogleCalendarConnection> deleteRow(
    _i1.Session session,
    GoogleCalendarConnection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GoogleCalendarConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GoogleCalendarConnection>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GoogleCalendarConnectionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GoogleCalendarConnection>(
      where: where(GoogleCalendarConnection.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GoogleCalendarConnectionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GoogleCalendarConnection>(
      where: where?.call(GoogleCalendarConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
