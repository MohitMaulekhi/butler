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

abstract class UserMemory implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  String content;

  DateTime createdAt;

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
