import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/google_calendar_service.dart';

class CalendarEndpoint extends Endpoint {
  GoogleCalendarService? _googleService;

  GoogleCalendarService _getGoogleService(Session session) {
    if (_googleService == null) {
      // Read flat variables from passwords
      final clientId = session.passwords['googleCalendarClientId'];
      final clientSecret = session.passwords['googleCalendarClientSecret'];
      final redirectUri = session.passwords['googleCalendarRedirectUri'];

      if (clientId == null || clientSecret == null || redirectUri == null) {
        throw Exception(
          'Google Calendar credentials not configured in passwords.yaml',
        );
      }

      _googleService = GoogleCalendarService(
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
      );
    }
    return _googleService!;
  }

  // ============ Local Calendar Methods ============

  Future<CalendarEvent> addEvent(Session session, CalendarEvent event) async {
    await CalendarEvent.db.insertRow(session, event);
    return event;
  }

  Future<List<CalendarEvent>> listEvents(
    Session session,
    DateTime start,
    DateTime end,
  ) async {
    return await CalendarEvent.db.find(
      session,
      where: (e) => (e.startTime >= start) & (e.endTime <= end),
      orderBy: (e) => e.startTime,
    );
  }

  Future<void> deleteEvent(Session session, CalendarEvent event) async {
    await CalendarEvent.db.deleteRow(session, event);
  }

  // ============ Google Calendar Methods ============

  /// Get OAuth URL (user clicks "Connect Google Calendar")
  Future<String> getGoogleAuthUrl(Session session, String userId) async {
    if (!session.isUserSignedIn) {
      throw Exception('User must be logged in');
    }
    return _getGoogleService(session).getAuthorizationUrl(userId);
  }

  /// Handle OAuth callback
  Future<bool> handleGoogleCallback(
    Session session,
    String code,
    String userId,
  ) async {
    if (!session.isUserSignedIn) {
      throw Exception('User must be logged in');
    }

    try {
      await _getGoogleService(session).exchangeCodeForTokens(
        session,
        code,
        userId,
      );
      return true;
    } catch (e) {
      session.log('OAuth error: $e', level: LogLevel.error);
      return false;
    }
  }

  /// Check connection status
  Future<Map<String, dynamic>> getGoogleConnectionStatus(
    Session session,
    String userId,
  ) async {
    if (!session.isUserSignedIn) {
      throw Exception('User must be logged in');
    }

    final connection = await GoogleCalendarConnection.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.isActive.equals(true),
    );

    return {
      'isConnected': connection != null,
      'googleEmail': connection?.googleEmail,
      'connectedAt': connection?.connectedAt.toIso8601String(),
      'lastSyncAt': connection?.lastSyncAt?.toIso8601String(),
    };
  }

  /// Sync events from Google
  Future<List<CalendarEvent>> syncFromGoogle(
    Session session,
    String userId, {
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!session.isUserSignedIn) {
      throw Exception('User must be logged in');
    }

    return await _getGoogleService(session).fetchGoogleEvents(
      session,
      userId,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Push event to Google
  Future<String> pushEventToGoogle(
    Session session,
    String userId,
    CalendarEvent event,
  ) async {
    if (!session.isUserSignedIn) {
      throw Exception('User must be logged in');
    }

    return await _getGoogleService(session).createGoogleEvent(
      session,
      userId,
      event,
    );
  }

  /// Disconnect Google Calendar
  Future<bool> disconnectGoogle(Session session, String userId) async {
    if (!session.isUserSignedIn) {
      throw Exception('User must be logged in');
    }

    try {
      await _getGoogleService(session).revokeAccess(session, userId);
      return true;
    } catch (e) {
      session.log('Disconnect error: $e', level: LogLevel.error);
      return false;
    }
  }
}
