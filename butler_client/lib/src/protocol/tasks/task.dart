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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Task implements _i1.SerializableModel {
  Task._({
    this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
  });

  factory Task({
    int? id,
    required String title,
    required bool isCompleted,
    required DateTime createdAt,
    required String userId,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      isCompleted: jsonSerialization['isCompleted'] as bool,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      userId: jsonSerialization['userId'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  bool isCompleted;

  DateTime createdAt;

  String userId;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Task copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? userId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toJson(),
      'userId': userId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskImpl extends Task {
  _TaskImpl({
    int? id,
    required String title,
    required bool isCompleted,
    required DateTime createdAt,
    required String userId,
  }) : super._(
         id: id,
         title: title,
         isCompleted: isCompleted,
         createdAt: createdAt,
         userId: userId,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Task copyWith({
    Object? id = _Undefined,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? userId,
  }) {
    return Task(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
