import 'package:butler_client/butler_client.dart';
import 'package:flutter/material.dart';
import 'package:butler_flutter/main.dart';
import 'package:butler_flutter/services/google_calendar_service.dart';
import 'package:butler_flutter/screens/settings/google_calendar_settings_screen.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2;

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  List<CalendarEvent>? _events;
  bool _isLoading = true;
  bool _isSyncing = false;
  DateTime _selectedDate = DateTime.now();
  late final GoogleCalendarService _googleService;

  @override
  void initState() {
    super.initState();
    _googleService = GoogleCalendarService(client);
    loadEvents();
  }

  Future<String> _getUserId() async {
    final authUserId = client.auth.authInfo?.authUserId;
    if (authUserId == null) {
      throw Exception('User not authenticated');
    }
    return authUserId.toString();
  }

  Future<void> loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final end = start.add(const Duration(days: 1));

      final events = await client.calendar.listEvents(start, end);
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    }
  }

  Future<void> _addEvent(
    String title,
    TimeOfDay time,
    int durationMinutes,
  ) async {
    try {
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        time.hour,
        time.minute,
      );
      final endTime = startTime.add(Duration(minutes: durationMinutes));

      final event = CalendarEvent(
        userId: await _getUserId(),
        title: title,
        startTime: startTime,
        endTime: endTime,
      );
      await client.calendar.addEvent(event);
      loadEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')),
        );
      }
    }
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    try {
      await client.calendar.deleteEvent(event);
      loadEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      loadEvents();
    }
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Time'),
                trailing: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final duration = int.tryParse(durationController.text) ?? 60;
                  _addEvent(titleController.text, selectedTime, duration);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCalendar(CalendarEvent event) {
    final add2.Event calendarEvent = add2.Event(
      title: event.title,
      description: event.description ?? '',
      location: 'Butler App Event',
      startDate: event.startTime,
      endDate: event.endTime,
      allDay: false,
    );
    add2.Add2Calendar.addEvent2Cal(calendarEvent);
  }

  Future<void> _syncGoogleCalendar() async {
    setState(() => _isSyncing = true);
    try {
      final userId = await _getUserId();
      final googleEvents = await _googleService.syncEventsFromGoogle(userId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Synced ${googleEvents.length} events from Google Calendar',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Reload local events to show updates
      await loadEvents();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _showGoogleCalendarSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoogleCalendarSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(_selectedDate),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _isSyncing ? null : _syncGoogleCalendar,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      tooltip: 'Sync Google Calendar',
                    ),
                    IconButton(
                      onPressed: _showGoogleCalendarSettings,
                      icon: const Icon(Icons.settings),
                      tooltip: 'Google Calendar Settings',
                    ),
                    IconButton(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      tooltip: 'Select Date',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events == null || _events!.isEmpty
                ? const Center(child: Text('No events for this day'))
                : ListView.builder(
                    itemCount: _events!.length,
                    itemBuilder: (context, index) {
                      final event = _events![index];
                      final timeFormat = DateFormat.jm();
                      return ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(timeFormat.format(event.startTime)),
                            Text(
                              '${event.endTime.difference(event.startTime).inMinutes}m',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        title: Text(event.title),
                        subtitle: event.description != null
                            ? Text(event.description!)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: () => _addToCalendar(event),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteEvent(event),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
