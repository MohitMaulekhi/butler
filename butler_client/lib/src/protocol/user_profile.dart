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

abstract class UserProfile implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
