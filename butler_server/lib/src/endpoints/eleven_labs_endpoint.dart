import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../services/eleven_labs_service.dart';

class ElevenLabsEndpoint extends Endpoint {
  
  Future<ByteData> textToSpeech(Session session, String text, {String? voiceId}) async {
    final apiKey = session.passwords['elevenLabsApiKey'];
    if (apiKey == null) {
      // Fallback or throw. For now throw to alert user.
      throw Exception('ElevenLabs API key not found in passwords');
    }
    
    // Default voice: Adam (pNInz6obpgDQGcFmaJgB) - A generic male voice, often used.
    final voice = voiceId ?? 'pqHfZKP75CvOlQylNhV4';
    
    final service = ElevenLabsService(apiKey);
    final bytes = await service.textToSpeech(text, voice);
    
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}
