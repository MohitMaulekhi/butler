import 'dart:convert';
import 'package:butler_flutter/main.dart';
import 'package:butler_client/butler_client.dart' as cli;
import 'package:butler_flutter/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:butler_flutter/config/avatars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();

  // State
  bool _isLoading = true;
  String? _error;
  String _userEmail = '';
  int _selectedAvatarIndex = 0;

  // Profile data
  cli.UserProfile? _profile;
  String _name = '';
  String _bio = '';
  String _goals = '';
  String _location = '';
  final _locationController = TextEditingController();

  // Integration keys
  final _connectedState = <String, bool>{};
  final _integrationKeys = {
    'notion_token': 'Notion Integration Token',
    'splitwise_key': 'Splitwise API Key',
    'github_token': 'GitHub Token',
    'trello_key': 'Trello API Key',
    'trello_token': 'Trello Token',
    'slack_token': 'Slack Bot Token',
    'zoom_token': 'Zoom JWT/OAuth Token',
  };

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
        '1. Create Server-to-Server OAuth app on marketplace.zoom.us\n2. Get Account ID, Client ID, Client Secret\n3. Generate Access Token',
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user email from auth session
      final authInfo = client.authSessionManager.authInfo;
      if (authInfo != null) {
        _userEmail = _profile?.name ?? 'No email';
      }

      // Load profile from server

      final profile = await client.profile.getProfile();

      _profile = profile;
      _name = profile.name;
      _bio = profile.bio ?? '';
      _goals = profile.goals ?? '';
      _location = profile.location ?? '';
      _locationController.text = _location;

      // If name is default, try to get from auth
      if (_name == 'User' && authInfo != null) {
        _name = _profile?.name ?? 'User';
      }

      // Load avatar preference
      final prefs = await SharedPreferences.getInstance();
      _selectedAvatarIndex = prefs.getInt('selected_avatar_index') ?? 0;
      if (_selectedAvatarIndex >= avatarUrls.length) {
        _selectedAvatarIndex = 0;
      }

      // Load API key connection states
      for (var key in _integrationKeys.keys) {
        final value = await _storage.read(key: key);
        _connectedState[key] = value != null && value.isNotEmpty;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      final profile = cli.UserProfile(
        id: _profile?.id,
        userId: _profile?.userId ?? '',
        name: _name,
        bio: _bio,
        goals: _goals,
        location: _location,
      );

      final updated = await client.profile.updateProfile(profile);
      _profile = updated;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  Future<void> _autoDetectLocation() async {
    try {
      // Use CORS-friendly API to detect user's location from browser
      // ipapi.co supports CORS and works in Flutter Web
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final city = data['city'] ?? '';
        final country = data['country_name'] ?? '';
        setState(() {
          _location = '$city, $country';
          _locationController.text = _location;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location detected: $_location')),
          );
        }
      } else {
        throw Exception('Failed to get location');
      }
    } catch (e) {
      debugPrint('Location detection error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not detect location')),
        );
      }
    }
  }

  Future<void> _saveApiKey(String key, String value) async {
    if (value.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
    final val = await _storage.read(key: key);
    setState(() {
      _connectedState[key] = val != null && val.isNotEmpty;
    });
  }

  void _showSaveDialog(String key, String label) {
    final controller = TextEditingController();
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

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Avatar'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: avatarUrls.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedAvatarIndex;
              return GestureDetector(
                onTap: () async {
                  setState(() => _selectedAvatarIndex = index);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('selected_avatar_index', index);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          )
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      avatarUrls[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, _) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 40),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIntegration(String key) {
    if (key.contains('github')) return Icons.code;
    if (key.contains('slack')) return Icons.work;
    if (key.contains('notion')) return Icons.note;
    if (key.contains('zoom')) return Icons.video_call;
    if (key.contains('trello')) return Icons.dashboard;
    if (key.contains('split')) return Icons.attach_money;
    return Icons.extension;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading profile', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _initialize,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'Profile & Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showAvatarPicker,
                          child: Stack(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  avatarUrls[_selectedAvatarIndex],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name.isEmpty ? 'User' : _name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _userEmail,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information
                  Text(
                    'Personal Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: _name,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                    ),
                    onChanged: (v) => _name = v,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: _bio,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.info_outline),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                    ),
                    maxLines: 2,
                    onChanged: (v) => _bio = v,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: _goals,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Goals',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flag),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                    ),
                    maxLines: 2,
                    onChanged: (v) => _goals = v,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Location',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLow,
                          ),
                          onChanged: (v) => _location = v,
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
                  const SizedBox(height: 32),

                  // Connected Services
                  Text(
                    'Connected Services',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: _integrationKeys.entries.map((entry) {
                        final key = entry.key;
                        final label = entry.value;
                        final isConnected = _connectedState[key] ?? false;

                        return Column(
                          children: [
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getIconForIntegration(key),
                                  size: 20,
                                  color: isConnected
                                      ? theme.colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),
                              title: Text(
                                label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () => _showHelpDialog(
                                      label,
                                      _keyHelp[key] ?? 'No instructions',
                                    ),
                                  ),
                                  Switch(
                                    value: isConnected,
                                    onChanged: (_) =>
                                        _showSaveDialog(key, label),
                                    activeColor: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                              onTap: () => _showSaveDialog(key, label),
                            ),
                            if (entry.key != _integrationKeys.keys.last)
                              Divider(
                                height: 1,
                                indent: 60,
                                color: theme.colorScheme.outlineVariant
                                    .withOpacity(0.2),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await _storage.deleteAll();
                      for (var key in _integrationKeys.keys) {
                        _connectedState[key] = false;
                      }
                      setState(() {});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All API keys cleared')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear All API Keys'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 12),

                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        final sessionManager = await SessionManager.instance;
                        await sessionManager.signOutAllDevices();
                        if (context.mounted) {
                          context.go(Routes.signinRoute);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $e')),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
