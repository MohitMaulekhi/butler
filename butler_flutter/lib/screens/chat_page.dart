import 'package:butler_client/butler_client.dart' as protocol;
import 'package:butler_flutter/main.dart';
import 'package:butler_flutter/screens/components/voice_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

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

  void _resetChat() {
    setState(() {
      _messages.clear();
    });
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
      final amadeusKey = await _storage.read(key: 'amadeus_key');
      final weatherKey = await _storage.read(key: 'weather_key');

      // Convert history to protocol messages
      final history = _messages
          .where((m) => !m.isError)
          .map((m) => m.toProtocol())
          .toList();

      // Use global client from main.dart
      final response = await client.chat.chat(
        history,
        githubToken: githubToken,
        amadeusKey: amadeusKey,
        weatherKey: weatherKey,
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
      final list = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(_autoPlayAudio ? Icons.volume_up : Icons.volume_off),
                  onPressed: () {
                    setState(() {
                      _autoPlayAudio = !_autoPlayAudio;
                    });
                  },
                  tooltip: _autoPlayAudio ? 'Mute Auto-play' : 'Enable Auto-play',
                ),
                OutlinedButton.icon(
                  onPressed: _resetChat,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Chat'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
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
                                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                  p: const TextStyle(color: Colors.black87),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    return protocol.ChatMessage(content: text, isUser: isUser);
  }
}
