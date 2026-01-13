import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class CalendarEndpoint extends Endpoint {
  Future<CalendarEvent> addEvent(Session session, CalendarEvent event) async {
    await CalendarEvent.db.insertRow(session, event);
    return event;
  }

  Future<List<CalendarEvent>> listEvents(Session session, DateTime start, DateTime end) async {
    return await CalendarEvent.db.find(
      session,
      where: (e) => (e.startTime >= start) & (e.endTime <= end),
      orderBy: (e) => e.startTime,
    );
  }

  Future<void> deleteEvent(Session session, CalendarEvent event) async {
    await CalendarEvent.db.deleteRow(session, event);
  }
}
