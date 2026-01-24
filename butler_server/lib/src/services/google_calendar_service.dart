import 'dart:convert';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class GoogleCalendarService {
  final String clientId;
  final String clientSecret;
  final String redirectUri;

  GoogleCalendarService({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
  });

  static const scopes = [CalendarApi.calendarScope];

  /// Generate OAuth URL
  String getAuthorizationUrl(String userId) {
    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'access_type': 'offline',
      'prompt': 'consent',
      'state': userId.toString(),
    });
    return authUrl.toString();
  }

  /// Exchange code for tokens
  Future<GoogleCalendarConnection> exchangeCodeForTokens(
    Session session,
    String code,
    String userId,
  ) async {
    final tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');
    final response = await http.post(
      tokenEndpoint,
      body: {
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to exchange code: ${response.body}');
    }

    final data = json.decode(response.body);
    final expiresIn = data['expires_in'] as int;
    final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    // Get Google email
    String? googleEmail;
    try {
      final userInfoResponse = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: {'Authorization': 'Bearer ${data['access_token']}'},
      );
      if (userInfoResponse.statusCode == 200) {
        final userInfo = json.decode(userInfoResponse.body);
        googleEmail = userInfo['email'];
      }
    } catch (e) {
      session.log('Failed to get Google email: $e');
    }

    final connection = GoogleCalendarConnection(
      userId: userId,
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
      tokenExpiry: tokenExpiry,
      googleEmail: googleEmail,
      isActive: true,
      connectedAt: DateTime.now(),
    );

    // Upsert connection
    final existing = await GoogleCalendarConnection.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (existing != null) {
      connection.id = existing.id;
      await GoogleCalendarConnection.db.updateRow(session, connection);
    } else {
      await GoogleCalendarConnection.db.insertRow(session, connection);
    }

    return connection;
  }

  /// Refresh access token
  Future<GoogleCalendarConnection> refreshAccessToken(
    Session session,
    GoogleCalendarConnection connection,
  ) async {
    final tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');
    final response = await http.post(
      tokenEndpoint,
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'refresh_token': connection.refreshToken,
        'grant_type': 'refresh_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to refresh token: ${response.body}');
    }

    final data = json.decode(response.body);
    final expiresIn = data['expires_in'] as int;

    connection.accessToken = data['access_token'];
    connection.tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    await GoogleCalendarConnection.db.updateRow(session, connection);
    return connection;
  }

  /// Get authenticated Calendar API client
  Future<CalendarApi> _getCalendarClient(Session session, String userId) async {
    var connection = await GoogleCalendarConnection.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.isActive.equals(true),
    );

    if (connection == null) {
      throw Exception('Google Calendar not connected');
    }

    // Auto-refresh if expired
    if (connection.tokenExpiry.isBefore(DateTime.now())) {
      connection = await refreshAccessToken(session, connection);
    }

    final credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        connection.accessToken,
        connection.tokenExpiry.toUtc(),
      ),
      connection.refreshToken,
      scopes,
    );

    final client = authenticatedClient(http.Client(), credentials);
    return CalendarApi(client);
  }

  /// Fetch Google Calendar events
  Future<List<CalendarEvent>> fetchGoogleEvents(
    Session session,
    String userId, {
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final calendarApi = await _getCalendarClient(session, userId);

    final events = await calendarApi.events.list(
      'primary',
      timeMin: (startTime ?? DateTime.now()).toUtc(),
      timeMax: endTime?.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    // Update last sync time
    final connection = await GoogleCalendarConnection.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (connection != null) {
      connection.lastSyncAt = DateTime.now();
      await GoogleCalendarConnection.db.updateRow(session, connection);
    }

    // Convert to Butler events
    final butlerEvents = <CalendarEvent>[];
    for (final event in events.items ?? []) {
      if (event.start?.dateTime != null && event.end?.dateTime != null) {
        butlerEvents.add(
          CalendarEvent(
            userId: userId,
            title: event.summary ?? 'Untitled Event',
            startTime: event.start!.dateTime!,
            endTime: event.end!.dateTime!,
            description: event.description,
          ),
        );
      }
    }

    return butlerEvents;
  }

  /// Create event in Google Calendar
  Future<String> createGoogleEvent(
    Session session,
    String userId,
    CalendarEvent event,
  ) async {
    final calendarApi = await _getCalendarClient(session, userId);

    final googleEvent = Event(
      summary: event.title,
      description: event.description,
      start: EventDateTime(dateTime: event.startTime.toUtc()),
      end: EventDateTime(dateTime: event.endTime.toUtc()),
    );

    final created = await calendarApi.events.insert(googleEvent, 'primary');
    return created.id ?? '';
  }

  /// Disconnect Google Calendar
  Future<void> revokeAccess(Session session, String userId) async {
    final connection = await GoogleCalendarConnection.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (connection != null) {
      // Revoke token with Google
      try {
        await http.post(
          Uri.parse('https://oauth2.googleapis.com/revoke'),
          body: {'token': connection.accessToken},
        );
      } catch (e) {
        session.log('Error revoking token: $e');
      }

      // Delete from database
      await GoogleCalendarConnection.db.deleteRow(session, connection);
    }
  }
}
