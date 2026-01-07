import 'package:butler_flutter/main.dart';
import 'package:butler_flutter/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();
  final _githubController = TextEditingController();
  final _amadeusController = TextEditingController();
  final _weatherController = TextEditingController();

  bool _githubConnected = false;
  bool _amadeusConnected = false;
  bool _weatherConnected = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final github = await _storage.read(key: 'github_token');
    final amadeus = await _storage.read(key: 'amadeus_key');
    final weather = await _storage.read(key: 'weather_key');

    if (mounted) {
      setState(() {
        _githubConnected = github != null && github.isNotEmpty;
        _amadeusConnected = amadeus != null && amadeus.isNotEmpty;
        _weatherConnected = weather != null && weather.isNotEmpty;
      });
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

  void _showSaveDialog(
    String service,
    String storageKey,
    TextEditingController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save $service Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter API key',
            border: OutlineInputBorder(),
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
              await _saveApiKey(storageKey, controller.text);
              controller.clear();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$service key saved')),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'API Keys',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.code),
            title: const Text('GitHub'),
            subtitle: Text(_githubConnected ? 'Connected' : 'Not connected'),
            trailing: _githubConnected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.circle_outlined),
            onTap: () =>
                _showSaveDialog('GitHub', 'github_token', _githubController),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.flight),
            title: const Text('Amadeus (Travel)'),
            subtitle: Text(_amadeusConnected ? 'Connected' : 'Not connected'),
            trailing: _amadeusConnected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.circle_outlined),
            onTap: () =>
                _showSaveDialog('Amadeus', 'amadeus_key', _amadeusController),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: const Text('OpenWeather'),
            subtitle: Text(_weatherConnected ? 'Connected' : 'Not connected'),
            trailing: _weatherConnected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.circle_outlined),
            onTap: () => _showSaveDialog(
              'OpenWeather',
              'weather_key',
              _weatherController,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        // Logout button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text(
                    'Are you sure you want to logout?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              // If confirmed, logout and navigate to signin
              if (confirm == true && context.mounted) {
                // Use global client from main.dart
                await client.auth.signOutDevice();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                    ),
                  );
                  context.go(Routes.signinRoute);
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
        const SizedBox(height: 12),
        // Clear API Keys button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.tonalIcon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All API Keys?'),
                  content: const Text(
                    'This will remove all saved API keys. You can add them again anytime.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await _storage.deleteAll();
                await _loadApiKeys();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All API keys cleared'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear All API Keys'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  void dispose() {
    _githubController.dispose();
    _amadeusController.dispose();
    _weatherController.dispose();
    super.dispose();
  }
}
