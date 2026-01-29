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

abstract class ChatSession
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatSession._({
    this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession({
    int? id,
    required String userId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChatSessionImpl;

  factory ChatSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSession(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      title: jsonSerialization['title'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = ChatSessionTable();

  static const db = ChatSessionRepository._();

  @override
  int? id;

  String userId;

  String title;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatSession copyWith({
    int? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static ChatSessionInclude include() {
    return ChatSessionInclude._();
  }

  static ChatSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatSessionTable>? orderByList,
    ChatSessionInclude? include,
  }) {
    return ChatSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatSessionImpl extends ChatSession {
  _ChatSessionImpl({
    int? id,
    required String userId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         title: title,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatSession copyWith({
    Object? id = _Undefined,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatSessionUpdateTable extends _i1.UpdateTable<ChatSessionTable> {
  ChatSessionUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class ChatSessionTable extends _i1.Table<int?> {
  ChatSessionTable({super.tableRelation}) : super(tableName: 'chat_session') {
    updateTable = ChatSessionUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final ChatSessionUpdateTable updateTable;

  late final _i1.ColumnString userId;

  late final _i1.ColumnString title;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    title,
    createdAt,
    updatedAt,
  ];
}

class ChatSessionInclude extends _i1.IncludeObject {
  ChatSessionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatSession.t;
}

class ChatSessionIncludeList extends _i1.IncludeList {
  ChatSessionIncludeList._({
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatSession.t;
}

class ChatSessionRepository {
  const ChatSessionRepository._();

  /// Returns a list of [ChatSession]s matching the given query parameters.
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
  Future<List<ChatSession>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ChatSession>(
      where: where?.call(ChatSession.t),
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ChatSession] matching the given query parameters.
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
  Future<ChatSession?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ChatSession>(
      where: where?.call(ChatSession.t),
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ChatSession] by its [id] or null if no such row exists.
  Future<ChatSession?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ChatSession>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ChatSession]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ChatSession>> insert(
    _i1.Session session,
    List<ChatSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ChatSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ChatSession] and returns the inserted row.
  ///
  /// The returned [ChatSession] will have its `id` field set.
  Future<ChatSession> insertRow(
    _i1.Session session,
    ChatSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatSession>> update(
    _i1.Session session,
    List<ChatSession> rows, {
    _i1.ColumnSelections<ChatSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatSession>(
      rows,
      columns: columns?.call(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatSession> updateRow(
    _i1.Session session,
    ChatSession row, {
    _i1.ColumnSelections<ChatSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatSession>(
      row,
      columns: columns?.call(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatSession?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatSessionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatSession>(
      id,
      columnValues: columnValues(ChatSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatSession>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ChatSessionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatSessionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatSessionTable>? orderBy,
    _i1.OrderByListBuilder<ChatSessionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatSession>(
      columnValues: columnValues(ChatSession.t.updateTable),
      where: where(ChatSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatSession.t),
      orderByList: orderByList?.call(ChatSession.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatSession>> delete(
    _i1.Session session,
    List<ChatSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatSession].
  Future<ChatSession> deleteRow(
    _i1.Session session,
    ChatSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatSession>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ChatSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatSession>(
      where: where(ChatSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatSession>(
      where: where?.call(ChatSession.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
