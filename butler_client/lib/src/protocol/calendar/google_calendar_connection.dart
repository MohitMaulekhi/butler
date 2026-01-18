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

abstract class GoogleCalendarConnection implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  String accessToken;

  String refreshToken;

  DateTime tokenExpiry;

  String? googleEmail;

  bool isActive;

  DateTime connectedAt;

  DateTime? lastSyncAt;

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
