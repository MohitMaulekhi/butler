import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:serverpod/serverpod.dart';

/// This is the endpoint that provides personal assistant functionality using the
/// Google Gemini API. It extends the Endpoint class and implements the
/// chat method.
class TestEndpoint extends Endpoint {
  /// Pass in a message and get a personal assistant response back.
  Future<String> chat(Session session, String message) async {
    // Check if the user is signed in.
    if (!session.isUserSignedIn) {
      throw Exception('User is not signed in');
    }

    // Serverpod automatically loads your passwords.yaml file and makes the
    // passwords available in the session.passwords map.
    final geminiApiKey = session.passwords['geminiApiKey'];
    if (geminiApiKey == null) {
      throw Exception('Gemini API key not found');
    }

    // Configure the Dartantic AI agent for Gemini before sending the prompt.
    final agent = Agent.forProvider(
      GoogleProvider(apiKey: geminiApiKey),
      chatModelName: 'gemini-2.5-flash-lite',
    );

    // System prompt for the personal assistant
    final systemPrompt =
        'You are Butler, a helpful and friendly personal assistant. '
        'You help users with various tasks including answering questions, '
        'providing information, making suggestions, and assisting with daily activities. '
        'Be concise, helpful, and conversational in your responses. '
        'Always maintain a professional yet warm tone.';

    final prompt = '$systemPrompt\n\nUser: $message';

    final response = await agent.send(prompt);

    final responseText = response.output;

    // Check if the response is empty.
    if (responseText.isEmpty) {
      throw Exception('No response from Gemini API');
    }

    return responseText;
  }
}
