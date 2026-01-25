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
        _userEmail = _profile?.name ?? '';
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
                      errorBuilder: (_, _, _) => Container(
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

    final isWide = MediaQuery.of(context).size.width >= 900;
    // final theme = Theme.of(context); // This line is now redundant as theme is declared above

    // Common card decoration for a premium feel
    BoxDecoration sectionDecoration() => BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );

    // Common input decoration for consistency and borders
    InputDecoration fieldDecoration(String label, IconData icon) =>
        InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerLow.withValues(
            alpha: 0.5,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        );

    final profileCard = Container(
      padding: const EdgeInsets.all(24),
      decoration: sectionDecoration(),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showAvatarPicker,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      avatarUrls[_selectedAvatarIndex],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name.isEmpty ? 'User' : _name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final personalInfo = Container(
      padding: const EdgeInsets.all(24),
      decoration: sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Personal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _name,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: fieldDecoration('Display Name', Icons.person),
            onChanged: (v) => _name = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _bio,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: fieldDecoration('Bio', Icons.info_outline),
            maxLines: 2,
            onChanged: (v) => _bio = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _goals,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: fieldDecoration('Goals', Icons.flag_outlined),
            maxLines: 2,
            onChanged: (v) => _goals = v,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _locationController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: fieldDecoration(
                    'Location',
                    Icons.location_on_outlined,
                  ),
                  onChanged: (v) => _location = v,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: _autoDetectLocation,
                icon: const Icon(Icons.my_location),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Profile'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final connectedServices = Container(
      padding: const EdgeInsets.all(24),
      decoration: sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Connected Services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._integrationKeys.entries.map((entry) {
            final isConnected = _connectedState[entry.key] ?? false;
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForIntegration(entry.key),
                      color: isConnected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    entry.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.help_outline, size: 18),
                        onPressed: () => _showHelpDialog(
                          entry.value,
                          _keyHelp[entry.key] ?? '',
                        ),
                        tooltip: 'How to connect',
                      ),
                      Switch(
                        value: isConnected,
                        onChanged: (_) =>
                            _showSaveDialog(entry.key, entry.value),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  onTap: () => _showSaveDialog(entry.key, entry.value),
                ),
                if (entry.key != _integrationKeys.keys.last)
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              await _storage.deleteAll();
              for (var key in _integrationKeys.keys) {
                _connectedState[key] = false;
              }
              setState(() {});
            },
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear All Secrets'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  profileCard,
                                  const SizedBox(height: 24),
                                  personalInfo,
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  connectedServices,
                                  const SizedBox(height: 32),
                                  FilledButton.icon(
                                    onPressed: () async {
                                      final sessionManager =
                                          await SessionManager.instance;
                                      await sessionManager.signOutAllDevices();
                                      if (context.mounted) {
                                        context.go(Routes.signinRoute);
                                      }
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.errorContainer,
                                      foregroundColor:
                                          theme.colorScheme.onErrorContainer,
                                      minimumSize: const Size(
                                        double.infinity,
                                        60,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: const Icon(Icons.logout_rounded),
                                    label: const Text(
                                      'Log Out',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            profileCard,
                            const SizedBox(height: 24),
                            personalInfo,
                            const SizedBox(height: 32),
                            connectedServices,
                            const SizedBox(height: 32),
                            FilledButton.icon(
                              onPressed: () async {
                                final sessionManager =
                                    await SessionManager.instance;
                                await sessionManager.signOutAllDevices();
                                if (context.mounted) {
                                  context.go(Routes.signinRoute);
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.errorContainer,
                                foregroundColor:
                                    theme.colorScheme.onErrorContainer,
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Log Out'),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
