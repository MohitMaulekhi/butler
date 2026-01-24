import 'package:flutter/material.dart';
import 'package:butler_flutter/main.dart';
import 'package:butler_flutter/services/google_calendar_service.dart';
import 'package:butler_flutter/models/google_calendar_status.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

class GoogleCalendarSettingsScreen extends StatefulWidget {
  const GoogleCalendarSettingsScreen({super.key});

  @override
  State<GoogleCalendarSettingsScreen> createState() =>
      _GoogleCalendarSettingsScreenState();
}

class _GoogleCalendarSettingsScreenState
    extends State<GoogleCalendarSettingsScreen> {
  GoogleCalendarStatus? _status;
  bool _isLoading = false;
  late final GoogleCalendarService _service;

  @override
  void initState() {
    super.initState();
    _service = GoogleCalendarService(client);
    _loadStatus();
  }

  Future<String> _getUserId() async {
    // Get authenticated user ID from Serverpod auth module
    final authUserId = client.auth.authInfo?.authUserId;
    if (authUserId == null) {
      throw Exception('User not authenticated');
    }
    return authUserId.toString();
  }

  Future<void> _loadStatus() async {
    if (!mounted) return;

    final sessionManager = await SessionManager.instance;
    if (!sessionManager.isSignedIn) return;

    setState(() => _isLoading = true);

    try {
      final userId = await _getUserId();
      final status = await _service.getConnectionStatus(userId);

      if (!mounted) return;
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error loading status: $e', isError: true);
    }
  }

  Future<void> _handleConnect() async {
    final sessionManager = await SessionManager.instance;
    if (!sessionManager.isSignedIn) return;

    setState(() => _isLoading = true);

    try {
      final userId = await _getUserId();
      final success = await _service.connectGoogleCalendar(userId);

      if (!mounted) return;

      if (success) {
        _showSnackBar('✅ Google Calendar connected successfully!');
        await _loadStatus();
      } else {
        // User canceled or denied
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error connecting: ${e.toString()}', isError: true);
    }
  }

  Future<void> _handleDisconnect() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Google Calendar?'),
        content: const Text(
          'This will remove the connection to your Google Calendar. '
          'Your events in Butler will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final sessionManager = await SessionManager.instance;
    if (!sessionManager.isSignedIn) return;

    setState(() => _isLoading = true);

    try {
      final userId = await _getUserId();
      await _service.disconnectGoogleCalendar(userId);

      if (!mounted) return;
      _showSnackBar('Google Calendar disconnected');
      await _loadStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error disconnecting: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status?.isConnected ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Connection Status Card
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      size: 40,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                    title: const Text(
                      'Google Calendar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      isConnected
                          ? 'Connected${_status!.googleEmail != null ? ": ${_status!.googleEmail}" : ""}'
                          : 'Not connected',
                      style: TextStyle(
                        color: isConnected ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Connection Details (if connected)
                if (isConnected && _status != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connection Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _detailRow(
                            'Connected',
                            _status!.formattedConnectedTime,
                          ),
                          const SizedBox(height: 8),
                          _detailRow(
                            'Last Synced',
                            _status!.formattedLastSync,
                          ),
                          if (_status!.googleEmail != null) ...[
                            const SizedBox(height: 8),
                            _detailRow(
                              'Account',
                              _status!.googleEmail!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Info Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'About Google Calendar Sync',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Connect your Google Calendar to sync events\n'
                          '• Events from Google appear in Butler\n'
                          '• Create events that sync to Google Calendar\n'
                          '• Works on mobile, web, and desktop',
                          style: TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: isConnected
                      ? OutlinedButton.icon(
                          onPressed: _handleDisconnect,
                          icon: const Icon(Icons.link_off),
                          label: const Text('Disconnect Google Calendar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: _handleConnect,
                          icon: const Icon(Icons.link),
                          label: const Text('Connect Google Calendar'),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
