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

abstract class CalendarEvent
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CalendarEvent._({
    this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
  });

  factory CalendarEvent({
    int? id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
  }) = _CalendarEventImpl;

  factory CalendarEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEvent(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      startTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      description: jsonSerialization['description'] as String?,
    );
  }

  static final t = CalendarEventTable();

  static const db = CalendarEventRepository._();

  @override
  int? id;

  String title;

  DateTime startTime;

  DateTime endTime;

  String? description;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CalendarEvent copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CalendarEvent',
      if (id != null) 'id': id,
      'title': title,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      if (description != null) 'description': description,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CalendarEvent',
      if (id != null) 'id': id,
      'title': title,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      if (description != null) 'description': description,
    };
  }

  static CalendarEventInclude include() {
    return CalendarEventInclude._();
  }

  static CalendarEventIncludeList includeList({
    _i1.WhereExpressionBuilder<CalendarEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarEventTable>? orderByList,
    CalendarEventInclude? include,
  }) {
    return CalendarEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CalendarEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventImpl extends CalendarEvent {
  _CalendarEventImpl({
    int? id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
  }) : super._(
         id: id,
         title: title,
         startTime: startTime,
         endTime: endTime,
         description: description,
       );

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CalendarEvent copyWith({
    Object? id = _Undefined,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    Object? description = _Undefined,
  }) {
    return CalendarEvent(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description is String? ? description : this.description,
    );
  }
}

class CalendarEventUpdateTable extends _i1.UpdateTable<CalendarEventTable> {
  CalendarEventUpdateTable(super.table);

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> startTime(DateTime value) =>
      _i1.ColumnValue(
        table.startTime,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> endTime(DateTime value) =>
      _i1.ColumnValue(
        table.endTime,
        value,
      );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );
}

class CalendarEventTable extends _i1.Table<int?> {
  CalendarEventTable({super.tableRelation})
    : super(tableName: 'calendar_event') {
    updateTable = CalendarEventUpdateTable(this);
    title = _i1.ColumnString(
      'title',
      this,
    );
    startTime = _i1.ColumnDateTime(
      'startTime',
      this,
    );
    endTime = _i1.ColumnDateTime(
      'endTime',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
  }

  late final CalendarEventUpdateTable updateTable;

  late final _i1.ColumnString title;

  late final _i1.ColumnDateTime startTime;

  late final _i1.ColumnDateTime endTime;

  late final _i1.ColumnString description;

  @override
  List<_i1.Column> get columns => [
    id,
    title,
    startTime,
    endTime,
    description,
  ];
}

class CalendarEventInclude extends _i1.IncludeObject {
  CalendarEventInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CalendarEvent.t;
}

class CalendarEventIncludeList extends _i1.IncludeList {
  CalendarEventIncludeList._({
    _i1.WhereExpressionBuilder<CalendarEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CalendarEvent.t;
}

class CalendarEventRepository {
  const CalendarEventRepository._();

  /// Returns a list of [CalendarEvent]s matching the given query parameters.
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
  Future<List<CalendarEvent>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CalendarEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarEventTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<CalendarEvent>(
      where: where?.call(CalendarEvent.t),
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [CalendarEvent] matching the given query parameters.
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
  Future<CalendarEvent?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CalendarEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<CalendarEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarEventTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<CalendarEvent>(
      where: where?.call(CalendarEvent.t),
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [CalendarEvent] by its [id] or null if no such row exists.
  Future<CalendarEvent?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<CalendarEvent>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [CalendarEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<CalendarEvent>> insert(
    _i1.Session session,
    List<CalendarEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<CalendarEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [CalendarEvent] and returns the inserted row.
  ///
  /// The returned [CalendarEvent] will have its `id` field set.
  Future<CalendarEvent> insertRow(
    _i1.Session session,
    CalendarEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CalendarEvent>> update(
    _i1.Session session,
    List<CalendarEvent> rows, {
    _i1.ColumnSelections<CalendarEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CalendarEvent>(
      rows,
      columns: columns?.call(CalendarEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarEvent> updateRow(
    _i1.Session session,
    CalendarEvent row, {
    _i1.ColumnSelections<CalendarEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarEvent>(
      row,
      columns: columns?.call(CalendarEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarEvent?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<CalendarEventUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarEvent>(
      id,
      columnValues: columnValues(CalendarEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CalendarEvent>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<CalendarEventUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CalendarEventTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarEventTable>? orderBy,
    _i1.OrderByListBuilder<CalendarEventTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CalendarEvent>(
      columnValues: columnValues(CalendarEvent.t.updateTable),
      where: where(CalendarEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CalendarEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CalendarEvent>> delete(
    _i1.Session session,
    List<CalendarEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CalendarEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CalendarEvent].
  Future<CalendarEvent> deleteRow(
    _i1.Session session,
    CalendarEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CalendarEvent>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CalendarEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CalendarEvent>(
      where: where(CalendarEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CalendarEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CalendarEvent>(
      where: where?.call(CalendarEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
