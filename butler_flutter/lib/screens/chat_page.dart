import 'package:butler_client/butler_client.dart' as protocol;
import 'package:butler_flutter/main.dart';
import 'package:butler_flutter/config/avatars.dart';
import 'package:butler_flutter/screens/components/voice_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _storage = const FlutterSecureStorage();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<UiChatMessage> _messages = [];
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _autoPlayAudio = false; // Default OFF
  String _userName = 'User';
  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadPreferences();
    _loadUserName();
    _loadAvatarPreference();
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

  Future<void> _loadHistory() async {
    // Add auth check
    final sessionManager = await SessionManager.instance;
    if (!sessionManager.isSignedIn) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final history = await client.chat.getHistory(limit: 50);

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

  Future<void> _resetChat() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await client.chat.deleteHistory();
      if (mounted) {
        setState(() {
          _messages.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to clear chat: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear chat: $e')),
        );
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
      final githubToken = await _storage.read(key: 'github_token');

      // New Keys
      final notionToken = await _storage.read(key: 'notion_token');
      final splitwiseKey = await _storage.read(key: 'splitwise_key');
      final trelloKey = await _storage.read(key: 'trello_key');
      final trelloToken = await _storage.read(key: 'trello_token');
      final slackToken = await _storage.read(key: 'slack_token');
      final zoomToken = await _storage.read(key: 'zoom_token');
      // Server-side keys are managed by the server now (AlphaVantage, News, Wolfram)

      // Google Auth? Use global client auth token?
      // Usually need specific scope token. For now passing what we have if possible?
      // Or skip until we have better google auth.
      // We'll pass null for googleAccessToken for now or try to get it?
      String? googleAccessToken;
      // If signed in with Google, we might be able to get accessToken from SocialSignin?
      // Ignoring Google services for moment unless we have the token stored.

      // Convert history to protocol messages
      final history = _messages
          .where((m) => !m.isError)
          .map((m) => m.toProtocol())
          .toList();

      // Use global client from main.dart
      final response = await client.chat.chat(
        history,
        githubToken: githubToken,
        notionToken: notionToken,
        splitwiseKey: splitwiseKey,
        trelloKey: trelloKey,
        trelloToken: trelloToken,
        slackToken: slackToken,
        zoomToken: zoomToken,
        // Server keys (alphaVantage, etc.) are handled by server secrets
        googleAccessToken: googleAccessToken,
        enableIntegrations: true,
      );

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
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
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

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit from HomePage parent
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header - Only show on mobile or when not in desktop layout
            if (!isWide)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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
                            Icons.delete_outline,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _resetChat,
                          tooltip: 'Clear Chat',
                        ),
                        IconButton(
                          icon: Icon(
                            _autoPlayAudio ? Icons.volume_up : Icons.volume_off,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () async {
                            if (_autoPlayAudio) {
                              await _audioPlayer.stop();
                            }
                            setState(() {
                              _autoPlayAudio = !_autoPlayAudio;
                            });
                            final prefs = await SharedPreferences.getInstance();
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
                            avatarUrls[_selectedAvatarIndex < avatarUrls.length
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
                      color: theme.colorScheme.primary.withOpacity(0.2),
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
                                            .withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHigh,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Text(
                                          message.text,
                                          style: theme.textTheme.bodyLarge,
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
                                                        .withOpacity(0.9),
                                                  ),
                                              code: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    backgroundColor: theme
                                                        .colorScheme
                                                        .surfaceContainerLow,
                                                    fontFamily: 'monospace',
                                                  ),
                                              codeblockDecoration:
                                                  BoxDecoration(
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
                      color: theme.colorScheme.primary.withOpacity(0.5),
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
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _isLoading ? null : _openVoiceModal,
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
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    fillColor: Colors.transparent,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              IconButton(
                                onPressed: _isLoading ? null : _sendMessage,
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

  protocol.ChatMessage toProtocol() {
    return protocol.ChatMessage(
      content: text,
      isUser: isUser,
      createdAt: DateTime.now(),
      userId: '',
    );
  }
}
