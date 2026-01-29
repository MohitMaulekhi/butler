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
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../endpoints/calendar_endpoint.dart' as _i4;
import '../endpoints/chat_endpoint.dart' as _i5;
import '../endpoints/eleven_labs_endpoint.dart' as _i6;
import '../endpoints/news_endpoint.dart' as _i7;
import '../endpoints/profile_endpoint.dart' as _i8;
import '../endpoints/task_endpoint.dart' as _i9;
import '../greetings/greeting_endpoint.dart' as _i10;
import 'package:butler_server/src/generated/calendar/calendar_event.dart'
    as _i11;
import 'package:butler_server/src/generated/chat_message.dart' as _i12;
import 'package:butler_server/src/generated/user_profile.dart' as _i13;
import 'package:butler_server/src/generated/tasks/task.dart' as _i14;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i15;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i16;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i17;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'calendar': _i4.CalendarEndpoint()
        ..initialize(
          server,
          'calendar',
          null,
        ),
      'chat': _i5.ChatEndpoint()
        ..initialize(
          server,
          'chat',
          null,
        ),
      'elevenLabs': _i6.ElevenLabsEndpoint()
        ..initialize(
          server,
          'elevenLabs',
          null,
        ),
      'news': _i7.NewsEndpoint()
        ..initialize(
          server,
          'news',
          null,
        ),
      'profile': _i8.ProfileEndpoint()
        ..initialize(
          server,
          'profile',
          null,
        ),
      'task': _i9.TaskEndpoint()
        ..initialize(
          server,
          'task',
          null,
        ),
      'greeting': _i10.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['calendar'] = _i1.EndpointConnector(
      name: 'calendar',
      endpoint: endpoints['calendar']!,
      methodConnectors: {
        'addEvent': _i1.MethodConnector(
          name: 'addEvent',
          params: {
            'event': _i1.ParameterDescription(
              name: 'event',
              type: _i1.getType<_i11.CalendarEvent>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendar'] as _i4.CalendarEndpoint).addEvent(
                    session,
                    params['event'],
                  ),
        ),
        'listEvents': _i1.MethodConnector(
          name: 'listEvents',
          params: {
            'start': _i1.ParameterDescription(
              name: 'start',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'end': _i1.ParameterDescription(
              name: 'end',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendar'] as _i4.CalendarEndpoint).listEvents(
                    session,
                    params['start'],
                    params['end'],
                  ),
        ),
        'deleteEvent': _i1.MethodConnector(
          name: 'deleteEvent',
          params: {
            'event': _i1.ParameterDescription(
              name: 'event',
              type: _i1.getType<_i11.CalendarEvent>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendar'] as _i4.CalendarEndpoint).deleteEvent(
                    session,
                    params['event'],
                  ),
        ),
        'updateEvent': _i1.MethodConnector(
          name: 'updateEvent',
          params: {
            'event': _i1.ParameterDescription(
              name: 'event',
              type: _i1.getType<_i11.CalendarEvent>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendar'] as _i4.CalendarEndpoint).updateEvent(
                    session,
                    params['event'],
                  ),
        ),
        'getGoogleAuthUrl': _i1.MethodConnector(
          name: 'getGoogleAuthUrl',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _i4.CalendarEndpoint)
                  .getGoogleAuthUrl(
                    session,
                    params['userId'],
                  ),
        ),
        'handleGoogleCallback': _i1.MethodConnector(
          name: 'handleGoogleCallback',
          params: {
            'code': _i1.ParameterDescription(
              name: 'code',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _i4.CalendarEndpoint)
                  .handleGoogleCallback(
                    session,
                    params['code'],
                    params['userId'],
                  ),
        ),
        'getGoogleConnectionStatus': _i1.MethodConnector(
          name: 'getGoogleConnectionStatus',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _i4.CalendarEndpoint)
                  .getGoogleConnectionStatus(
                    session,
                    params['userId'],
                  ),
        ),
        'syncFromGoogle': _i1.MethodConnector(
          name: 'syncFromGoogle',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'startTime': _i1.ParameterDescription(
              name: 'startTime',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'endTime': _i1.ParameterDescription(
              name: 'endTime',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _i4.CalendarEndpoint)
                  .syncFromGoogle(
                    session,
                    params['userId'],
                    startTime: params['startTime'],
                    endTime: params['endTime'],
                  ),
        ),
        'pushEventToGoogle': _i1.MethodConnector(
          name: 'pushEventToGoogle',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'event': _i1.ParameterDescription(
              name: 'event',
              type: _i1.getType<_i11.CalendarEvent>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _i4.CalendarEndpoint)
                  .pushEventToGoogle(
                    session,
                    params['userId'],
                    params['event'],
                  ),
        ),
        'disconnectGoogle': _i1.MethodConnector(
          name: 'disconnectGoogle',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _i4.CalendarEndpoint)
                  .disconnectGoogle(
                    session,
                    params['userId'],
                  ),
        ),
      },
    );
    connectors['chat'] = _i1.EndpointConnector(
      name: 'chat',
      endpoint: endpoints['chat']!,
      methodConnectors: {
        'createSession': _i1.MethodConnector(
          name: 'createSession',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).createSession(
                session,
                params['title'],
              ),
        ),
        'getSessions': _i1.MethodConnector(
          name: 'getSessions',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i5.ChatEndpoint).getSessions(session),
        ),
        'deleteSession': _i1.MethodConnector(
          name: 'deleteSession',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).deleteSession(
                session,
                params['sessionId'],
              ),
        ),
        'updateSessionTitle': _i1.MethodConnector(
          name: 'updateSessionTitle',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'newTitle': _i1.ParameterDescription(
              name: 'newTitle',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i5.ChatEndpoint).updateSessionTitle(
                    session,
                    params['sessionId'],
                    params['newTitle'],
                  ),
        ),
        'getSessionHistory': _i1.MethodConnector(
          name: 'getSessionHistory',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i5.ChatEndpoint).getSessionHistory(
                    session,
                    params['sessionId'],
                    limit: params['limit'],
                  ),
        ),
        'chat': _i1.MethodConnector(
          name: 'chat',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'messages': _i1.ParameterDescription(
              name: 'messages',
              type: _i1.getType<List<_i12.ChatMessage>>(),
              nullable: false,
            ),
            'notionToken': _i1.ParameterDescription(
              name: 'notionToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'splitwiseKey': _i1.ParameterDescription(
              name: 'splitwiseKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'githubToken': _i1.ParameterDescription(
              name: 'githubToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'trelloKey': _i1.ParameterDescription(
              name: 'trelloKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'trelloToken': _i1.ParameterDescription(
              name: 'trelloToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'slackToken': _i1.ParameterDescription(
              name: 'slackToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'googleAccessToken': _i1.ParameterDescription(
              name: 'googleAccessToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'zoomToken': _i1.ParameterDescription(
              name: 'zoomToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'alphaVantageKey': _i1.ParameterDescription(
              name: 'alphaVantageKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'newsApiKey': _i1.ParameterDescription(
              name: 'newsApiKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'wolframAppId': _i1.ParameterDescription(
              name: 'wolframAppId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'enableIntegrations': _i1.ParameterDescription(
              name: 'enableIntegrations',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).chat(
                session,
                params['sessionId'],
                params['messages'],
                notionToken: params['notionToken'],
                splitwiseKey: params['splitwiseKey'],
                githubToken: params['githubToken'],
                trelloKey: params['trelloKey'],
                trelloToken: params['trelloToken'],
                slackToken: params['slackToken'],
                googleAccessToken: params['googleAccessToken'],
                zoomToken: params['zoomToken'],
                alphaVantageKey: params['alphaVantageKey'],
                newsApiKey: params['newsApiKey'],
                wolframAppId: params['wolframAppId'],
                enableIntegrations: params['enableIntegrations'],
              ),
        ),
      },
    );
    connectors['elevenLabs'] = _i1.EndpointConnector(
      name: 'elevenLabs',
      endpoint: endpoints['elevenLabs']!,
      methodConnectors: {
        'textToSpeech': _i1.MethodConnector(
          name: 'textToSpeech',
          params: {
            'text': _i1.ParameterDescription(
              name: 'text',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'voiceId': _i1.ParameterDescription(
              name: 'voiceId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['elevenLabs'] as _i6.ElevenLabsEndpoint)
                  .textToSpeech(
                    session,
                    params['text'],
                    voiceId: params['voiceId'],
                  ),
        ),
      },
    );
    connectors['news'] = _i1.EndpointConnector(
      name: 'news',
      endpoint: endpoints['news']!,
      methodConnectors: {
        'getTopHeadlines': _i1.MethodConnector(
          name: 'getTopHeadlines',
          params: {
            'country': _i1.ParameterDescription(
              name: 'country',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'pageSize': _i1.ParameterDescription(
              name: 'pageSize',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['news'] as _i7.NewsEndpoint).getTopHeadlines(
                    session,
                    country: params['country'],
                    category: params['category'],
                    pageSize: params['pageSize'],
                  ),
        ),
        'searchNews': _i1.MethodConnector(
          name: 'searchNews',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['news'] as _i7.NewsEndpoint).searchNews(
                session,
                params['query'],
              ),
        ),
        'getLocation': _i1.MethodConnector(
          name: 'getLocation',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['news'] as _i7.NewsEndpoint).getLocation(session),
        ),
      },
    );
    connectors['profile'] = _i1.EndpointConnector(
      name: 'profile',
      endpoint: endpoints['profile']!,
      methodConnectors: {
        'getProfile': _i1.MethodConnector(
          name: 'getProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i8.ProfileEndpoint)
                  .getProfile(session),
        ),
        'updateProfile': _i1.MethodConnector(
          name: 'updateProfile',
          params: {
            'profile': _i1.ParameterDescription(
              name: 'profile',
              type: _i1.getType<_i13.UserProfile>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['profile'] as _i8.ProfileEndpoint).updateProfile(
                    session,
                    params['profile'],
                  ),
        ),
      },
    );
    connectors['task'] = _i1.EndpointConnector(
      name: 'task',
      endpoint: endpoints['task']!,
      methodConnectors: {
        'addTask': _i1.MethodConnector(
          name: 'addTask',
          params: {
            'task': _i1.ParameterDescription(
              name: 'task',
              type: _i1.getType<_i14.Task>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i9.TaskEndpoint).addTask(
                session,
                params['task'],
              ),
        ),
        'addTasks': _i1.MethodConnector(
          name: 'addTasks',
          params: {
            'tasks': _i1.ParameterDescription(
              name: 'tasks',
              type: _i1.getType<List<_i14.Task>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i9.TaskEndpoint).addTasks(
                session,
                params['tasks'],
              ),
        ),
        'listTasks': _i1.MethodConnector(
          name: 'listTasks',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['task'] as _i9.TaskEndpoint).listTasks(session),
        ),
        'updateTask': _i1.MethodConnector(
          name: 'updateTask',
          params: {
            'task': _i1.ParameterDescription(
              name: 'task',
              type: _i1.getType<_i14.Task>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i9.TaskEndpoint).updateTask(
                session,
                params['task'],
              ),
        ),
        'deleteTask': _i1.MethodConnector(
          name: 'deleteTask',
          params: {
            'task': _i1.ParameterDescription(
              name: 'task',
              type: _i1.getType<_i14.Task>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i9.TaskEndpoint).deleteTask(
                session,
                params['task'],
              ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i10.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i15.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth'] = _i16.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i17.Endpoints()
      ..initializeEndpoints(server);
  }
}
