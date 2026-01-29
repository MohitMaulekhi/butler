import 'package:butler_client/butler_client.dart' as protocol;
import 'package:butler_flutter/main.dart';
import 'package:butler_flutter/config/avatars.dart';
import 'package:butler_flutter/screens/components/chat_sidebar.dart';
import 'package:butler_flutter/screens/components/voice_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final List<protocol.ChatSession> sessions;
  final VoidCallback? onSessionsUpdated;

  const ChatPage({
    super.key,
    this.sessions = const [],
    this.onSessionsUpdated,
  });

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final _storage = const FlutterSecureStorage();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<UiChatMessage> _messages = [];
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _autoPlayAudio = false; // Default OFF
  String _userName = 'User';
  int _selectedAvatarIndex = 0;

  // Session State - Removed local _sessions, using widget.sessions
  int? _currentSessionId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Sessions loaded by parent
    _loadPreferences();
    _loadUserName();
    _loadAvatarPreference();
  }

  // _loadSessions removed, using widget.sessions

  void _selectSession(protocol.ChatSession session) {
    if (_currentSessionId == session.id) return;
    setState(() {
      _currentSessionId = session.id;
      _messages.clear(); // Clear UI immediately
    });
    _loadHistory(session.id);
    // On mobile, close drawer if open
    if (MediaQuery.of(context).size.width < 900 &&
        (_scaffoldKey.currentState?.isDrawerOpen ?? false)) {
      Navigator.pop(context); // Close drawer
    }
  }

  Future<void> _createNewChat() async {
    setState(() {
      _currentSessionId = null;
      _messages.clear();
    });
    widget.onSessionsUpdated?.call();

    // On mobile, close drawer if open
    if (MediaQuery.of(context).size.width < 900 &&
        (_scaffoldKey.currentState?.isDrawerOpen ?? false)) {
      Navigator.pop(context); // Close drawer
    }
  }

  Future<void> _deleteSession(protocol.ChatSession session) async {
    try {
      await client.chat.deleteSession(session.id!);
      widget.onSessionsUpdated?.call();
      if (_currentSessionId == session.id) {
        _createNewChat(); // Reset if deleted active
      }
    } catch (e) {
      debugPrint('Failed to delete session: $e');
    }
  }

  Future<void> _loadAvatarPreference() async {
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
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await client.profile.getProfile();
      if (mounted) {
        setState(() {
          _userName = profile.name.isNotEmpty ? profile.name : 'User';
        });
      }
    } catch (e) {
      debugPrint('Failed to load user name: $e');
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _autoPlayAudio =
            prefs.getBool('auto_play_audio') ?? false; // Default OFF
      });
    }
  }

  Future<void> loadSession(int sessionId) async {
    // Find session object if needed, but for now just load history
    final session = widget.sessions.where((s) => s.id == sessionId).firstOrNull;
    if (session != null) {
      _selectSession(session);
    } else {
      // Just load history if not in list (edge case)
      setState(() {
        _currentSessionId = sessionId;
        _messages.clear();
      });
      await _loadHistory(sessionId);
    }
  }

  // Public method to reset/clear chat, mapped to New Chat now
  Future<void> reset() => _createNewChat();
  Future<void> _loadHistory(int? sessionId) async {
    if (sessionId == null) return;

    // Add auth check
    final sessionManager = client.authSessionManager;
    if (sessionManager.authInfo == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final history = await client.chat.getSessionHistory(sessionId, limit: 50);

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(
            history.map(
              (m) => UiChatMessage(
                text: m.content,
                isUser: m.isUser,
              ),
            ),
          );
          _isLoading = false;
        });

        // Scroll to bottom after a slight delay to let list render
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    } catch (e) {
      debugPrint('Failed to load history: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openVoiceModal() async {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final result = await (isWide
        ? showDialog<String>(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  maxHeight: 650,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: const VoiceModal(),
                ),
              ),
            ),
          )
        : showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const VoiceModal(),
          ));

    if (result != null && result.isNotEmpty) {
      _messageController.text = result;
      _sendMessage();
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(UiChatMessage(text: message, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // 1. Create session if needed
      if (_currentSessionId == null) {
        try {
          // Use first 30 chars as title or "New Chat"
          final title = message.length > 30
              ? '${message.substring(0, 30)}...'
              : message;
          final session = await client.chat.createSession(title);
          setState(() {
            _currentSessionId = session.id;
            // widget.sessions.insert(0, session); // Parent handles list update
          });
          widget.onSessionsUpdated?.call();
        } catch (e) {
          debugPrint('Failed to create session: $e');
        }
      }

      if (_currentSessionId == null) {
        throw Exception('Could not create session');
      }

      final githubToken = await _storage.read(key: 'github_token');
      // New Keys
      final notionToken = await _storage.read(key: 'notion_token');
      final splitwiseKey = await _storage.read(key: 'splitwise_key');
      final trelloKey = await _storage.read(key: 'trello_key');
      final trelloToken = await _storage.read(key: 'trello_token');
      final slackToken = await _storage.read(key: 'slack_token');
      final zoomToken = await _storage.read(key: 'zoom_token');
      String? googleAccessToken;

      // Convert history to protocol messages
      final history = _messages
          .where((m) => !m.isError)
          .map((m) => m.toProtocol(_currentSessionId!))
          .toList();

      // Use global client from main.dart
      final response = await client.chat.chat(
        _currentSessionId!,
        history,
        githubToken: githubToken,
        notionToken: notionToken,
        splitwiseKey: splitwiseKey,
        trelloKey: trelloKey,
        trelloToken: trelloToken,
        slackToken: slackToken,
        zoomToken: zoomToken,
        googleAccessToken: googleAccessToken,
        enableIntegrations: true,
      );

      // Reload sessions to update updated_at or if title changes (optional)
      widget.onSessionsUpdated?.call();

      if (mounted) {
        setState(() {
          _messages.add(UiChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();

        if (_autoPlayAudio) {
          _speak(response);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            UiChatMessage(
              text: 'Error: ${e.toString()}',
              isUser: false,
              isError: true,
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _speak(String text) async {
    try {
      // Don't block UI
      final bytes = await client.elevenLabs.textToSpeech(text);
      // ByteData to Uint8List
      final list = bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      );
      await _audioPlayer.play(BytesSource(list));
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: $e')),
        );
      }
    }
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: color),
        label: Text(label),
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          _messageController.text = label;
          _sendMessage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    final sidebar = ChatSidebar(
      sessions: widget.sessions,
      selectedSessionId: _currentSessionId,
      onSessionSelected: _selectSession,
      onNewChat: _createNewChat,
      onDeleteSession: _deleteSession,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: !isWide
          ? Drawer(
              child: sidebar,
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            // if (isWide) sidebar, // Hidden on Desktop now as per requirements
            Expanded(
              child: Column(
                children: [
                  // Custom Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 40 : 20,
                      vertical: isWide ? 24 : 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _userName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: _createNewChat,
                              tooltip: 'New Chat',
                            ),
                            IconButton(
                              icon: Icon(
                                _autoPlayAudio
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () async {
                                if (_autoPlayAudio) {
                                  await _audioPlayer.stop();
                                }
                                setState(() {
                                  _autoPlayAudio = !_autoPlayAudio;
                                });
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool(
                                  'auto_play_audio',
                                  _autoPlayAudio,
                                );
                              },
                              tooltip: _autoPlayAudio ? 'Mute' : 'Unmute',
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                avatarUrls[_selectedAvatarIndex <
                                        avatarUrls.length
                                    ? _selectedAvatarIndex
                                    : 0],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Suggestions - More minimal on desktop
                  if (_messages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'What can I help with today?',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildSuggestionChip(
                                context,
                                'Weather Today',
                                Icons.wb_sunny_rounded,
                                Colors.orange,
                              ),
                              _buildSuggestionChip(
                                context,
                                'View Agenda',
                                Icons.calendar_today_rounded,
                                Colors.red,
                              ),
                              _buildSuggestionChip(
                                context,
                                'Trending Movies',
                                Icons.music_note_rounded,
                                Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 850),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 40 : 16,
                            vertical: 24,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isUser = message.isUser;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: Row(
                                mainAxisAlignment: isUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isUser) ...[
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.transparent,
                                        child: Icon(
                                          Icons.smart_toy,
                                          size: 24,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: message.isError
                                            ? theme.colorScheme.errorContainer
                                                  .withValues(alpha: 0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (message.isError)
                                            Text(
                                              message.text,
                                              style: TextStyle(
                                                color: theme.colorScheme.error,
                                              ),
                                            )
                                          else if (isUser)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme
                                                    .surfaceContainerHigh,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      24,
                                                    ),
                                              ),
                                              child: Text(
                                                message.text,
                                                style:
                                                    theme.textTheme.bodyLarge,
                                              ),
                                            )
                                          else
                                            MarkdownBody(
                                              data: message.text,
                                              onTapLink: (text, href, title) {
                                                if (href != null) {
                                                  launchUrl(
                                                    Uri.parse(href),
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                }
                                              },
                                              styleSheet:
                                                  MarkdownStyleSheet.fromTheme(
                                                    theme,
                                                  ).copyWith(
                                                    p: theme.textTheme.bodyLarge
                                                        ?.copyWith(
                                                          height: 1.6,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.9,
                                                              ),
                                                        ),
                                                    code: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          backgroundColor: theme
                                                              .colorScheme
                                                              .surfaceContainerLow,
                                                          fontFamily:
                                                              'monospace',
                                                        ),
                                                    codeblockDecoration: BoxDecoration(
                                                      color: theme
                                                          .colorScheme
                                                          .surfaceContainerLow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                              selectable: true,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Input Area
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            if (!isWide)
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _openVoiceModal,
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      tooltip: 'Voice Chat',
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        decoration: InputDecoration(
                                          hintText: 'Ask anything...',
                                          hintStyle: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                          fillColor: Colors.transparent,
                                        ),
                                        onSubmitted: (_) => _sendMessage(),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _sendMessage,
                                      icon: Icon(
                                        Icons.arrow_upward_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                      tooltip: 'Send',
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

class UiChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  UiChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  protocol.ChatMessage toProtocol(int sessionId) {
    return protocol.ChatMessage(
      content: text,
      isUser: isUser,
      createdAt: DateTime.now(),
      userId: '',
      sessionId: sessionId,
    );
  }
}
