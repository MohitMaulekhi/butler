import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;
import 'package:butler_flutter/main.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

class VoiceModal extends StatefulWidget {
  const VoiceModal({super.key});

  @override
  State<VoiceModal> createState() => _VoiceModalState();
}

class _VoiceModalState extends State<VoiceModal>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Initializing...';
  bool _available = false;
  late AnimationController _animationController;
  String _userName = 'User';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _initSpeech();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final profile = await client.profile.getProfile();
      final sessionManager = await SessionManager.instance;
      if (mounted) {
        setState(() {
          _userName = profile.name.isNotEmpty ? profile.name : 'User';
          _userEmail =
              sessionManager.signedInUser?.email ??
              sessionManager.signedInUser?.userName ??
              '';
        });
      }
    } catch (e) {
      debugPrint('Failed to load user info: $e');
    }
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    // Check permission first
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _text = 'Microphone permission denied. Please enable it in settings.';
        });
      }
      openAppSettings();
      return;
    }

    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _text = 'Microphone permission required.';
        });
      }
      return;
    }

    try {
      _available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('Speech Status: $val');
          if (mounted) {
            setState(() {
              if (val == 'done' || val == 'notListening') {
                _isListening = false;
              } else if (val == 'listening') {
                _isListening = true;
              }
            });
          }
        },
        onError: (val) {
          debugPrint('Speech Error: ${val.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _text = 'Error: ${val.errorMsg}';
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Speech Init Error: $e');
      if (mounted) {
        setState(() {
          _text = 'Initialization Error: $e';
        });
      }
      return;
    }

    if (mounted) {
      if (_available) {
        setState(() {
          _text = 'Press to speak';
        });
        _listen();
      } else {
        setState(() {
          _text = "Speech recognition not available on this device";
        });
      }
    }
  }

  void _listen() async {
    if (!_isListening) {
      if (_available) {
        setState(() {
          _isListening = true;
          _text = 'Listening...';
        });

        try {
          await _speech.listen(
            onResult: (val) {
              setState(() {
                _text = val.recognizedWords;
              });
            },
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            cancelOnError: true,
            listenMode: stt.ListenMode.confirmation,
          );
        } catch (e) {
          debugPrint('Listen Error: $e');
          setState(() {
            _isListening = false;
            _text = 'Error starting listening: $e';
          });
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Spacer(),

          // Profile / Context
          Column(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=a042581f4e29026024d',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_getGreeting()}, $_userName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_userEmail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _userEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
            ],
          ),

          const Spacer(),

          // Visualization
          SizedBox(
            height: 120,
            child: _isListening
                ? AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(7, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Transform.scale(
                              scaleY:
                                  0.5 +
                                  0.8 *
                                      math.sin(
                                        _animationController.value *
                                                3 *
                                                math.pi +
                                            index,
                                      ),
                              child: Container(
                                width: 12,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.mic_none,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ),
          ),

          const SizedBox(height: 32),
          Text(
            _isListening
                ? 'Listening...'
                : _text == 'Press to speak'
                ? 'Tap to Speak'
                : 'Paused',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 16),
          // Transcription
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(minHeight: 60),
            child: Text(
              _text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
