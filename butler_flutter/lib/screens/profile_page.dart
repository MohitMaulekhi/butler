import 'dart:convert';
import 'package:butler_flutter/main.dart';
import 'package:butler_client/butler_client.dart' as cli;
import 'package:butler_flutter/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
// ... skipped lines ...

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();

  // Personalization Controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _goalsController = TextEditingController();
  final _locationController = TextEditingController();

  // API Key Controllers
  final _controllers = <String, TextEditingController>{};
  final _connectedState = <String, bool>{};

  // Help texts for keys
  final _keyHelp = {
    'notion_token':
        '1. Go to notion.so/my-integrations\n2. Create new integration\n3. Copy "Internal Integration Secret"',
    'splitwise_key':
        '1. Go to secure.splitwise.com/apps\n2. Register an application\n3. Copy "API Key"',
    'github_token':
        '1. Go to GitHub Settings > Developer settings > PATs\n2. Generate new token (classic)\n3. Select "repo" scope',
    'trello_key': '1. Go to trello.com/app-key\n2. Copy "Personal Key"',
    'trello_token':
        '1. On the same page, click "Token"\n2. Authorize and copy token',
    'slack_token':
        '1. Create App at api.slack.com\n2. Install to Workspace\n3. Copy "Bot User OAuth Token"',
    'zoom_token':
        '1. Create Server-to-Server OAuth app on marketplace.zoom.us\n2. Get Account ID, Client ID, Client Secret\n3. Generate Access Token (complex) or use JWT if legacy.',
  };

  void _showHelpDialog(String label, String helpText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How to get $label'),
        content: Text(helpText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Define keys and labels
  final _integrationKeys = {
    'notion_token': 'Notion Integration Token',
    'splitwise_key': 'Splitwise API Key',
    'github_token': 'GitHub Token',
    'trello_key': 'Trello API Key',
    'trello_token': 'Trello Token',
    'slack_token': 'Slack Bot Token',
    'zoom_token': 'Zoom JWT/OAuth Token',
  };

  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    for (var key in _integrationKeys.keys) {
      _controllers[key] = TextEditingController();
      _connectedState[key] = false;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingProfile = true);
    try {
      await Future.wait([
        _loadProfile(),
        _loadApiKeys(),
      ]);
    } finally {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await client.profile.getProfile();
      if (mounted) {
        _nameController.text = profile.name;
        _bioController.text = profile.bio ?? '';
        _goalsController.text = profile.goals ?? '';
        _locationController.text = profile.location ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      final profile = cli.UserProfile(
        userId: client.authSessionManager.authInfo!.authUserId.toString(),
        name: _nameController.text,
        bio: _bioController.text,
        goals: _goalsController.text,
        location: _locationController.text,
      );

      await client.profile.updateProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  Future<void> _loadApiKeys() async {
    for (var key in _integrationKeys.keys) {
      final value = await _storage.read(key: key);
      if (mounted) {
        setState(() {
          _connectedState[key] = value != null && value.isNotEmpty;
        });
      }
    }
  }

  Future<void> _saveApiKey(String key, String value) async {
    if (value.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
    await _loadApiKeys();
  }

  Future<void> _autoDetectLocation() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final city = data['city'] ?? '';
        final country = data['country'] ?? '';
        final loc = '$city, $country';
        setState(() {
          _locationController.text = loc;
        });
      } else {
        throw Exception('API Error');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not detect location')),
        );
      }
    }
  }

  void _showSaveDialog(String key, String label) {
    final controller = _controllers[key]!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await _saveApiKey(key, controller.text);
              controller.clear();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label saved')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Personalization Section
        const Text(
          'Personal Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Bio (About You)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _goalsController,
          decoration: const InputDecoration(
            labelText: 'Goals',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _autoDetectLocation,
              icon: const Icon(Icons.my_location),
              tooltip: 'Auto-detect',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _saveProfile,
            child: const Text('Save Profile'),
          ),
        ),

        const Divider(height: 48),

        // API Keys Section
        const Text(
          'Integrations',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Enter API keys to enable features.'),
        const SizedBox(height: 16),

        ..._integrationKeys.entries.map((entry) {
          final key = entry.key;
          final label = entry.value;
          final isConnected = _connectedState[key] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(label),
              subtitle: Text(isConnected ? 'Connected' : 'Not connected'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showHelpDialog(
                      label,
                      _keyHelp[key] ?? 'No instructions available.',
                    ),
                  ),
                  Icon(
                    isConnected ? Icons.check_circle : Icons.circle_outlined,
                    color: isConnected ? Colors.green : null,
                  ),
                ],
              ),
              onTap: () => _showSaveDialog(key, label),
            ),
          );
        }),

        const SizedBox(height: 32),
        // Logout / Clear
        FilledButton.tonalIcon(
          onPressed: () async {
            await _storage.deleteAll();
            await _loadApiKeys();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All API keys cleared')),
              );
            }
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear All API Keys'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            var sessionManager = await SessionManager.instance;
            // we are relying on this method await sessionManager.signOutDevice();
            await sessionManager.signOutDevice();
            if (context.mounted) context.go(Routes.signinRoute);
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _goalsController.dispose();
    _locationController.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
