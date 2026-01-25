import 'package:butler_client/butler_client.dart' as protocol;
import 'package:butler_flutter/main.dart';
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
  bool _autoPlayAudio = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _autoPlayAudio = prefs.getBool('auto_play_audio') ?? true;
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
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceModal(),
    );

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_messages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    _autoPlayAudio ? Icons.volume_up : Icons.volume_off,
                  ),
                  onPressed: () async {
                    if (_autoPlayAudio) {
                      await _audioPlayer.stop();
                    }
                    setState(() {
                      _autoPlayAudio = !_autoPlayAudio;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('auto_play_audio', _autoPlayAudio);
                  },
                  tooltip: _autoPlayAudio
                      ? 'Mute Auto-play'
                      : 'Enable Auto-play',
                ),
                OutlinedButton.icon(
                  onPressed: _resetChat,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear Chat'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text('Start a conversation with Butler'),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: message.isError
                              ? Colors.red.shade100
                              : message.isUser
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: message.isUser
                            ? Text(
                                message.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            : MarkdownBody(
                                data: message.text,
                                onTapLink: (text, href, title) {
                                  if (href != null) {
                                    launchUrl(
                                      Uri.parse(href),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                styleSheet: MarkdownStyleSheet.fromTheme(
                                  Theme.of(context),
                                ).copyWith(
                                  p: const TextStyle(color: Colors.black87),
                                  a: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                selectable: true,
                              ),
                      ),
                    );
                  },
                ),
        ),
        if (_isLoading) const LinearProgressIndicator(),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: _isLoading ? null : _openVoiceModal,
                icon: const Icon(Icons.mic),
                tooltip: 'Voice Chat',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
