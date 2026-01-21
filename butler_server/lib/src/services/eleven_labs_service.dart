import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class ElevenLabsService {
  final String apiKey;
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  ElevenLabsService(this.apiKey);

  Future<List<int>> textToSpeech(String text, String voiceId) async {
    final url = Uri.parse('$_baseUrl/text-to-speech/$voiceId');
    final response = await http.post(
      url,
      headers: {
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'model_id': 'eleven_flash_v2_5',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.5,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('ElevenLabs API error: ${response.statusCode} - ${response.body}');
    }

    return response.bodyBytes;
  }
}
