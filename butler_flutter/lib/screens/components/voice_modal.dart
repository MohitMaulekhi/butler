import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceModal extends StatefulWidget {
  const VoiceModal({super.key});

  @override
  State<VoiceModal> createState() => _VoiceModalState();
}

class _VoiceModalState extends State<VoiceModal> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Initializing...';
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
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
          _text = 'Press the button and start speaking';
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
                if (val.hasConfidenceRating && val.confidence > 0) {
                  // Optional: use confidence
                }
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isListening ? 'Listening...' : 'Not Listening',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton.large(
                onPressed: _available ? _listen : null,
                backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _text.isNotEmpty && 
                          _text != 'Press the button and start speaking' && 
                          _text != 'Initializing...' &&
                          _text != 'Listening...' &&
                          !_text.startsWith('Error') &&
                          !_text.startsWith('Microphone') &&
                          !_text.startsWith('Speech recognition not available')
                    ? () => Navigator.pop(context, _text)
                    : null,
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
