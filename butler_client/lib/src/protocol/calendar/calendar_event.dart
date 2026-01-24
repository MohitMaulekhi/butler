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

abstract class CalendarEvent implements _i1.SerializableModel {
  CalendarEvent._({
    this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    required this.userId,
  });

  factory CalendarEvent({
    int? id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    required String userId,
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
      userId: jsonSerialization['userId'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  DateTime startTime;

  DateTime endTime;

  String? description;

  String userId;

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CalendarEvent copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? userId,
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
      'userId': userId,
    };
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
    required String userId,
  }) : super._(
         id: id,
         title: title,
         startTime: startTime,
         endTime: endTime,
         description: description,
         userId: userId,
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
    String? userId,
  }) {
    return CalendarEvent(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description is String? ? description : this.description,
      userId: userId ?? this.userId,
    );
  }
}
