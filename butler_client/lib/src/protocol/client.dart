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
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:butler_client/src/protocol/calendar/calendar_event.dart' as _i5;
import 'package:butler_client/src/protocol/chat/chat_message.dart' as _i6;
import 'dart:typed_data' as _i7;
import 'package:butler_client/src/protocol/tasks/task.dart' as _i8;
import 'package:butler_client/src/protocol/greetings/greeting.dart' as _i9;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i10;
import 'protocol.dart' as _i11;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointCalendar extends _i2.EndpointRef {
  EndpointCalendar(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'calendar';

  _i3.Future<_i5.CalendarEvent> addEvent(_i5.CalendarEvent event) =>
      caller.callServerEndpoint<_i5.CalendarEvent>(
        'calendar',
        'addEvent',
        {'event': event},
      );

  _i3.Future<List<_i5.CalendarEvent>> listEvents(
    DateTime start,
    DateTime end,
  ) => caller.callServerEndpoint<List<_i5.CalendarEvent>>(
    'calendar',
    'listEvents',
    {
      'start': start,
      'end': end,
    },
  );

  _i3.Future<void> deleteEvent(_i5.CalendarEvent event) =>
      caller.callServerEndpoint<void>(
        'calendar',
        'deleteEvent',
        {'event': event},
      );

  /// Get OAuth URL (user clicks "Connect Google Calendar")
  _i3.Future<String> getGoogleAuthUrl(String userId) =>
      caller.callServerEndpoint<String>(
        'calendar',
        'getGoogleAuthUrl',
        {'userId': userId},
      );

  /// Handle OAuth callback
  _i3.Future<bool> handleGoogleCallback(
    String code,
    String userId,
  ) => caller.callServerEndpoint<bool>(
    'calendar',
    'handleGoogleCallback',
    {
      'code': code,
      'userId': userId,
    },
  );

  /// Check connection status
  _i3.Future<Map<String, dynamic>> getGoogleConnectionStatus(String userId) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'calendar',
        'getGoogleConnectionStatus',
        {'userId': userId},
      );

  /// Sync events from Google
  _i3.Future<List<_i5.CalendarEvent>> syncFromGoogle(
    String userId, {
    DateTime? startTime,
    DateTime? endTime,
  }) => caller.callServerEndpoint<List<_i5.CalendarEvent>>(
    'calendar',
    'syncFromGoogle',
    {
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
    },
  );

  /// Push event to Google
  _i3.Future<String> pushEventToGoogle(
    String userId,
    _i5.CalendarEvent event,
  ) => caller.callServerEndpoint<String>(
    'calendar',
    'pushEventToGoogle',
    {
      'userId': userId,
      'event': event,
    },
  );

  /// Disconnect Google Calendar
  _i3.Future<bool> disconnectGoogle(String userId) =>
      caller.callServerEndpoint<bool>(
        'calendar',
        'disconnectGoogle',
        {'userId': userId},
      );
}

/// This is the endpoint that provides personal assistant functionality using the
/// Google Gemini API with optional service integrations.
/// {@category Endpoint}
class EndpointChat extends _i2.EndpointRef {
  EndpointChat(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chat';

  /// Fetch chat history for the authenticated user
  _i3.Future<List<_i6.ChatMessage>> getHistory({required int limit}) =>
      caller.callServerEndpoint<List<_i6.ChatMessage>>(
        'chat',
        'getHistory',
        {'limit': limit},
      );

  /// Delete chat history for the authenticated user
  _i3.Future<void> deleteHistory() => caller.callServerEndpoint<void>(
    'chat',
    'deleteHistory',
    {},
  );

  /// Chat with optional service integrations (GitHub, Travel, etc.).
  _i3.Future<String> chat(
    List<_i6.ChatMessage> messages, {
    String? githubToken,
    String? amadeusKey,
    String? weatherKey,
    required bool enableIntegrations,
  }) => caller.callServerEndpoint<String>(
    'chat',
    'chat',
    {
      'messages': messages,
      'githubToken': githubToken,
      'amadeusKey': amadeusKey,
      'weatherKey': weatherKey,
      'enableIntegrations': enableIntegrations,
    },
  );
}

/// {@category Endpoint}
class EndpointElevenLabs extends _i2.EndpointRef {
  EndpointElevenLabs(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'elevenLabs';

  _i3.Future<_i7.ByteData> textToSpeech(
    String text, {
    String? voiceId,
  }) => caller.callServerEndpoint<_i7.ByteData>(
    'elevenLabs',
    'textToSpeech',
    {
      'text': text,
      'voiceId': voiceId,
    },
  );
}

/// {@category Endpoint}
class EndpointNews extends _i2.EndpointRef {
  EndpointNews(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'news';

  _i3.Future<String> getTopHeadlines({
    required String country,
    String? category,
    required int pageSize,
  }) => caller.callServerEndpoint<String>(
    'news',
    'getTopHeadlines',
    {
      'country': country,
      'category': category,
      'pageSize': pageSize,
    },
  );

  _i3.Future<String> searchNews(String query) =>
      caller.callServerEndpoint<String>(
        'news',
        'searchNews',
        {'query': query},
      );
}

/// {@category Endpoint}
class EndpointTask extends _i2.EndpointRef {
  EndpointTask(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'task';

  _i3.Future<_i8.Task> addTask(_i8.Task task) =>
      caller.callServerEndpoint<_i8.Task>(
        'task',
        'addTask',
        {'task': task},
      );

  _i3.Future<List<_i8.Task>> listTasks() =>
      caller.callServerEndpoint<List<_i8.Task>>(
        'task',
        'listTasks',
        {},
      );

  _i3.Future<_i8.Task> updateTask(_i8.Task task) =>
      caller.callServerEndpoint<_i8.Task>(
        'task',
        'updateTask',
        {'task': task},
      );

  _i3.Future<void> deleteTask(_i8.Task task) => caller.callServerEndpoint<void>(
    'task',
    'deleteTask',
    {'task': task},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i9.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i9.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    auth = _i10.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i10.Caller auth;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i11.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    calendar = EndpointCalendar(this);
    chat = EndpointChat(this);
    elevenLabs = EndpointElevenLabs(this);
    news = EndpointNews(this);
    task = EndpointTask(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointCalendar calendar;

  late final EndpointChat chat;

  late final EndpointElevenLabs elevenLabs;

  late final EndpointNews news;

  late final EndpointTask task;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'calendar': calendar,
    'chat': chat,
    'elevenLabs': elevenLabs,
    'news': news,
    'task': task,
    'greeting': greeting,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'auth': modules.auth,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
