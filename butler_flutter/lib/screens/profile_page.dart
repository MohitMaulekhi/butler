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
// ... skipped lines ...

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();
  cli.UserProfile? _userProfile;

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
  String _userEmail = '';
  int _selectedAvatarIndex = 0;

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
      // Load user email from auth
      final sessionManager = await SessionManager.instance;
      if (sessionManager.isSignedIn) {
        final userInfo = sessionManager.signedInUser;
        if (mounted) {
          setState(() {
            _userEmail = userInfo?.email ?? userInfo?.userName ?? 'No email';
          });
        }
      }

      await Future.wait([
        _loadProfile(),
        _loadApiKeys(),
        _loadAvatarPreference(),
      ]);
    } finally {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await client.profile.getProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;

          var name = profile.name;
          if (name == 'User') {
            // Try to get name from auth
            // We can't access sessionManager inside here easily unless we fetch it again,
            // but we can trust the profile endpoint returned 'User' if it was default.
            // Actually, let's fetch sessionManager to check.
          }
        });

        final sessionManager = await SessionManager.instance;
        String displayName = profile.name;
        if ((displayName == 'User' || displayName.isEmpty) &&
            sessionManager.isSignedIn) {
          displayName = sessionManager.signedInUser?.userName ?? 'User';
          // If we have a better name, we might want to update the controller to it,
          // so the user can save it as their profile name.
        }

        setState(() {
          _nameController.text = displayName;
          _bioController.text = profile.bio ?? '';
          _goalsController.text = profile.goals ?? '';
          _locationController.text = profile.location ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _loadAvatarPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          final index = prefs.getInt('selected_avatar_index') ?? 0;
          if (index >= 0 && index < avatarUrls.length) {
            _selectedAvatarIndex = index;
          } else {
            _selectedAvatarIndex = 0;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading avatar preference: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      final profile =
          _userProfile?.copyWith(
            name: _nameController.text,
            bio: _bioController.text,
            goals: _goalsController.text,
            location: _locationController.text,
          ) ??
          cli.UserProfile(
            userId: client.authSessionManager.authInfo!.authUserId.toString(),
            name: _nameController.text,
            bio: _bioController.text,
            goals: _goalsController.text,
            location: _locationController.text,
          );

      final updatedProfile = await client.profile.updateProfile(profile);
      if (mounted) _userProfile = updatedProfile;

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
                  setState(() {
                    _selectedAvatarIndex = index;
                  });
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        );
                      },
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

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);

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
                                  avatarUrls[_selectedAvatarIndex <
                                          avatarUrls.length
                                      ? _selectedAvatarIndex
                                      : 0],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: theme.colorScheme.primary,
                                      ),
                                    );
                                  },
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
                                _nameController.text.isEmpty
                                    ? 'User'
                                    : _nameController.text,
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
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.info_outline),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _goalsController,
                    decoration: InputDecoration(
                      labelText: 'Goals',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flag),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
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
                  const SizedBox(height: 32),

                  // Integrations
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
                                    onPressed: () {
                                      final helpText =
                                          _keyHelp[key] ??
                                          'No instructions available.';
                                      _showHelpDialog(label, helpText);
                                    },
                                  ),
                                  Switch(
                                    value: isConnected,
                                    onChanged: (val) {
                                      if (val) {
                                        _showSaveDialog(key, label);
                                      } else {
                                        // Make user clear it explicitly or handle disconnect
                                        _showSaveDialog(
                                          key,
                                          label,
                                        ); // For now just re-open to edit/clear
                                      }
                                    },
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

  IconData _getIconForIntegration(String key) {
    if (key.contains('github')) return Icons.code;
    if (key.contains('slack')) return Icons.work; // Placeholder for Slack
    if (key.contains('notion')) return Icons.note;
    if (key.contains('zoom')) return Icons.video_call;
    if (key.contains('trello')) return Icons.dashboard;
    if (key.contains('split')) return Icons.attach_money;
    return Icons.extension;
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
