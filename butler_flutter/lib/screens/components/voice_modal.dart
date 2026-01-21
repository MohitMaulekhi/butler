import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;

class VoiceModal extends StatefulWidget {
  const VoiceModal({super.key});

  @override
  State<VoiceModal> createState() => _VoiceModalState();
}

class _VoiceModalState extends State<VoiceModal> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Initializing...';
  bool _available = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _initSpeech();
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          // Creative Voice Visualization
          SizedBox(
            height: 80,
            child: _isListening 
              ? AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.scale(
                            scaleY: 0.5 + 0.5 * math.sin(_animationController.value * 2 * math.pi + index),
                            child: Container(
                              width: 10,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                )
              : Icon(
                  Icons.mic_none,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
          ),
          
          const SizedBox(height: 24),
          Text(
            _isListening ? 'Listening...' : (_text == 'Press to speak' ? 'Tap to Speak' : 'Paused'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(minHeight: 60),
            child: Text(
              _text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                iconSize: 24,
              ),
              
              FloatingActionButton.large(
                onPressed: _available ? _listen : null,
                backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
                elevation: _isListening ? 8 : 4,
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              
              IconButton.filled(
                onPressed: _text.isNotEmpty && 
                          !_text.startsWith('Initializing') &&
                          !_text.startsWith('Press') &&
                          !_text.startsWith('Error')
                    ? () => Navigator.pop(context, _text)
                    : null,
                icon: const Icon(Icons.send),
                iconSize: 24,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
