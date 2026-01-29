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

abstract class UserMemory
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserMemory._({
    this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory UserMemory({
    int? id,
    required String userId,
    required String content,
    required DateTime createdAt,
  }) = _UserMemoryImpl;

  factory UserMemory.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserMemory(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      content: jsonSerialization['content'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = UserMemoryTable();

  static const db = UserMemoryRepository._();

  @override
  int? id;

  String userId;

  String content;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserMemory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserMemory copyWith({
    int? id,
    String? userId,
    String? content,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserMemory',
      if (id != null) 'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserMemory',
      if (id != null) 'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toJson(),
    };
  }

  static UserMemoryInclude include() {
    return UserMemoryInclude._();
  }

  static UserMemoryIncludeList includeList({
    _i1.WhereExpressionBuilder<UserMemoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserMemoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserMemoryTable>? orderByList,
    UserMemoryInclude? include,
  }) {
    return UserMemoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserMemory.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserMemory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserMemoryImpl extends UserMemory {
  _UserMemoryImpl({
    int? id,
    required String userId,
    required String content,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         content: content,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UserMemory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserMemory copyWith({
    Object? id = _Undefined,
    String? userId,
    String? content,
    DateTime? createdAt,
  }) {
    return UserMemory(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserMemoryUpdateTable extends _i1.UpdateTable<UserMemoryTable> {
  UserMemoryUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> content(String value) => _i1.ColumnValue(
    table.content,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class UserMemoryTable extends _i1.Table<int?> {
  UserMemoryTable({super.tableRelation}) : super(tableName: 'user_memory') {
    updateTable = UserMemoryUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final UserMemoryUpdateTable updateTable;

  late final _i1.ColumnString userId;

  late final _i1.ColumnString content;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    content,
    createdAt,
  ];
}

class UserMemoryInclude extends _i1.IncludeObject {
  UserMemoryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserMemory.t;
}

class UserMemoryIncludeList extends _i1.IncludeList {
  UserMemoryIncludeList._({
    _i1.WhereExpressionBuilder<UserMemoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserMemory.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserMemory.t;
}

class UserMemoryRepository {
  const UserMemoryRepository._();

  /// Returns a list of [UserMemory]s matching the given query parameters.
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
  Future<List<UserMemory>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserMemoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserMemoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserMemoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserMemory>(
      where: where?.call(UserMemory.t),
      orderBy: orderBy?.call(UserMemory.t),
      orderByList: orderByList?.call(UserMemory.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [UserMemory] matching the given query parameters.
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
  Future<UserMemory?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserMemoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserMemoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserMemoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<UserMemory>(
      where: where?.call(UserMemory.t),
      orderBy: orderBy?.call(UserMemory.t),
      orderByList: orderByList?.call(UserMemory.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [UserMemory] by its [id] or null if no such row exists.
  Future<UserMemory?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<UserMemory>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [UserMemory]s in the list and returns the inserted rows.
  ///
  /// The returned [UserMemory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<UserMemory>> insert(
    _i1.Session session,
    List<UserMemory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserMemory>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [UserMemory] and returns the inserted row.
  ///
  /// The returned [UserMemory] will have its `id` field set.
  Future<UserMemory> insertRow(
    _i1.Session session,
    UserMemory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserMemory>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserMemory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserMemory>> update(
    _i1.Session session,
    List<UserMemory> rows, {
    _i1.ColumnSelections<UserMemoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserMemory>(
      rows,
      columns: columns?.call(UserMemory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserMemory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserMemory> updateRow(
    _i1.Session session,
    UserMemory row, {
    _i1.ColumnSelections<UserMemoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserMemory>(
      row,
      columns: columns?.call(UserMemory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserMemory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserMemory?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserMemoryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserMemory>(
      id,
      columnValues: columnValues(UserMemory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserMemory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserMemory>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserMemoryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserMemoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserMemoryTable>? orderBy,
    _i1.OrderByListBuilder<UserMemoryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserMemory>(
      columnValues: columnValues(UserMemory.t.updateTable),
      where: where(UserMemory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserMemory.t),
      orderByList: orderByList?.call(UserMemory.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserMemory]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserMemory>> delete(
    _i1.Session session,
    List<UserMemory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserMemory>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserMemory].
  Future<UserMemory> deleteRow(
    _i1.Session session,
    UserMemory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserMemory>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserMemory>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserMemoryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserMemory>(
      where: where(UserMemory.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserMemoryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserMemory>(
      where: where?.call(UserMemory.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
