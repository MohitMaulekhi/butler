import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart' hide ChatMessage;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/integration_manager.dart';

/// This is the endpoint that provides personal assistant functionality using the
/// Google Gemini API with optional service integrations.
class ChatEndpoint extends Endpoint {
  /// Chat with optional service integrations (GitHub, Travel, etc.).
  Future<String> chat(
    Session session,
    List<ChatMessage> messages, {
    String? githubToken,
    String? amadeusKey,
    String? weatherKey,
    bool enableIntegrations = false,
  }) async {
    // Authentication is optional for chat
    if (!session.isUserSignedIn) {
      throw Exception('User is not signed in');
    }

    if (messages.isEmpty) {
      return '';
    }

    final geminiApiKey = session.passwords['geminiApiKey'];
    if (geminiApiKey == null) {
      throw Exception('Gemini API key not found');
    }

    // Configure the Dartantic AI agent
    final agent = Agent.forProvider(
      GoogleProvider(apiKey: geminiApiKey),
      chatModelName: 'gemini-2.5-flash-lite',
    );

    // Build context string from messages
    final contextBuffer = StringBuffer();
    for (final msg in messages) {
      contextBuffer.writeln('${msg.isUser ? "User" : "Butler"}: ${msg.content}');
    }
    final fullContext = contextBuffer.toString();
    final lastMessage = messages.last.content;

    // Simple chat without integrations
    if (!enableIntegrations ||
        (githubToken == null && amadeusKey == null && weatherKey == null)) {
      session.log('Processing simple chat without integrations');

      final systemPrompt =
          'You are Butler, a helpful and friendly personal assistant. '
          'You help users with various tasks including answering questions, '
          'providing information, making suggestions, and assisting with daily activities. '
          'Be concise, helpful, and conversational in your responses. '
          'Always maintain a professional yet warm tone.';

      final prompt = '$systemPrompt\n\nChat History:\n$fullContext';
      final response = await agent.send(prompt);
      return response.output;
    }

    // Chat with integrations - use function calling
    return await _chatWithTools(
      session,
      agent,
      fullContext,
      lastMessage,
      githubToken,
      amadeusKey,
      weatherKey,
    );
  }

  /// Handles chat with tool calling using Gemini's native function calling.
  Future<String> _chatWithTools(
    Session session,
    Agent agent,
    String fullContext,
    String lastMessage,
    String? githubToken,
    String? amadeusKey,
    String? weatherKey,
  ) async {
    final manager = IntegrationManager(
      session: session,
      githubToken: githubToken,
      amadeusKey: amadeusKey,
      weatherKey: weatherKey,
    );

    // Get available tools
    final tools = manager.getAvailableTools();

    if (tools.isEmpty) {
      session.log('No tools available, falling back to simple chat');
      final response = await agent.send(fullContext);
      return response.output;
    }

    session.log('Available tools: ${tools.map((t) => t.name).join(", ")}');

    // Build tool definitions for Gemini
    final toolDefinitions = tools.map((tool) {
      return {
        'name': tool.name,
        'description': tool.description,
        'parameters': tool.parameters ?? {},
      };
    }).toList();

    // System prompt
    final systemPrompt =
        'You are Butler, a helpful AI assistant with access to tools. '
        'Use the available tools when appropriate to help the user. '
        'Available tools: ${toolDefinitions.map((t) => t['name']).join(", ")}. '
        'Call tools when needed to get accurate, real-time information.';

    final promptWithHistory = '$systemPrompt\n\nChat History:\n$fullContext';

    // Ask Gemini directly: should use a tool?
    final decisionPrompt =
        '''
$promptWithHistory

Available tools:
${toolDefinitions.map((t) => '- ${t['name']}: ${t['description']}').join('\n')}

Should you use a tool to answer the last user request? 
Respond with ONLY "YES" or "NO", nothing else.
''';

    final decisionResponse = await agent.send(decisionPrompt);
    final decision = decisionResponse.output.trim().toUpperCase();

    session.log('Tool decision: $decision');

    // If no tool needed, give direct answer
    if (decision != 'YES') {
      final directResponse = await agent.send(promptWithHistory);
      return directResponse.output;
    }

    // Tool needed - extract parameters
    final toolExtractionPrompt =
        '''
$promptWithHistory

Available tools:
${toolDefinitions.map((t) => '- ${t['name']}: ${t['description']}\n  Parameters: ${t['parameters']}').join('\n')}

Respond with ONLY valid JSON in this format:
{"tool": "tool_name", "params": {...}}

JSON only, no markdown, no explanation:
''';

    final toolResponse = await agent.send(toolExtractionPrompt);
    final toolOutput = toolResponse.output.trim();

    try {
      // Extract JSON (handle markdown wrappers)
      var jsonStr = toolOutput;
      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
      }

      session.log('Tool JSON: $jsonStr');

      final toolCall = json.decode(jsonStr) as Map<String, dynamic>;
      final toolName = toolCall['tool'] as String?;
      final params = toolCall['params'] as Map<String, dynamic>? ?? {};

      if (toolName == null) {
        final fallbackResponse = await agent.send(promptWithHistory);
        return fallbackResponse.output;
      }

      // Execute tool
      session.log('Executing: $toolName($params)');

      dynamic result;
      try {
        result = await manager.executeTool(toolName, params);

        // Check if result contains an error (from services)
        if (result is Map && result['error'] == true) {
          return 'Error: ${result['message']}\n\n'
              'Please check your API keys in the Profile settings.';
        }

        if (result is List &&
            result.isNotEmpty &&
            result.first is Map &&
            result.first['error'] == true) {
          return 'Error: ${result.first['message']}\n\n'
              'Please check your API keys in the Profile settings.';
        }
      } catch (e) {
        session.log('Tool execution failed: $e', level: LogLevel.error);
        return 'Sorry, I encountered an error while using the $toolName tool. '
            'This might be due to invalid API keys or a service issue.\n\n'
            'Please check your API keys in the Profile settings and try again.';
      }

      // Format result
      final formatPrompt =
          '''
Chat History:
$fullContext

Tool used: $toolName
Result: ${json.encode(result)}

Provide a helpful, natural response using this information.
''';

      final finalResponse = await agent.send(formatPrompt);
      return finalResponse.output;
    } catch (e) {
      session.log('Tool error: $e', level: LogLevel.error);
      final fallbackResponse = await agent.send(promptWithHistory);
      return fallbackResponse.output;
    }
  }
}
