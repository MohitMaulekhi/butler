import 'package:butler_client/butler_client.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../models/google_calendar_status.dart';

/// Service for managing Google Calendar OAuth and API operations
class GoogleCalendarService {
  final Client client;

  GoogleCalendarService(this.client);

  /// Connect user's Google Calendar via OAuth 2.0 flow
  Future<bool> connectGoogleCalendar(String userId) async {
    try {
      // Step 1: Get OAuth authorization URL from backend
      final authUrl = await client.calendar.getGoogleAuthUrl(userId);

      // Step 2: Open OAuth flow (works on mobile, web, desktop)
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'http', // Works for desktop and web
      );

      // Step 3: Extract authorization code from callback URL
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];

      if (code == null) {
        throw Exception('No authorization code received from Google');
      }

      // Step 4: Send code to backend to exchange for tokens
      final success = await client.calendar.handleGoogleCallback(code, userId);

      return success;
    } catch (e) {
      // Handle user cancelation gracefully
      if (e.toString().contains('CANCELED') ||
          e.toString().contains('USER_CANCELED')) {
        return false;
      }
      rethrow;
    }
  }

  /// Get current Google Calendar connection status
  Future<GoogleCalendarStatus> getConnectionStatus(String userId) async {
    final statusMap = await client.calendar.getGoogleConnectionStatus(userId);
    return GoogleCalendarStatus.fromMap(statusMap);
  }

  /// Sync events from Google Calendar
  Future<List<CalendarEvent>> syncEventsFromGoogle(
    String userId, {
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    return await client.calendar.syncFromGoogle(
      userId,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Push a local event to Google Calendar
  Future<String> pushEventToGoogle(String userId, CalendarEvent event) async {
    return await client.calendar.pushEventToGoogle(userId, event);
  }

  /// Disconnect Google Calendar
  Future<bool> disconnectGoogleCalendar(String userId) async {
    return await client.calendar.disconnectGoogle(userId);
  }
}
