import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart' hide ChatMessage;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/integration_manager.dart';

class ChatEndpoint extends Endpoint {
  Future<List<ChatMessage>> getHistory(
    Session session, {
    int limit = 50,
  }) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) return [];

    final messages = await ChatMessage.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: limit,
    );

    return messages.reversed.toList();
  }

  Future<void> deleteHistory(Session session) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) return;

    await ChatMessage.db.deleteWhere(
      session,
      where: (t) => t.userId.equals(userId),
    );
  }

  Future<String> chat(
    Session session,
    List<ChatMessage> messages, {
    // New Token Parameters
    String? notionToken,
    String? splitwiseKey,
    String? githubToken,
    String? trelloKey,
    String? trelloToken,
    String? slackToken,
    String? googleAccessToken, // Gmail, Tasks
    String? zoomToken,
    String? alphaVantageKey,
    String? newsApiKey,
    String? wolframAppId,
    bool enableIntegrations = false,
  }) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) throw Exception('User is not signed in');

    if (messages.isEmpty) return '';

    // Save User Message (last one)
    final lastUserMessage = messages.last;
    if (lastUserMessage.isUser) {
      await ChatMessage.db.insertRow(
        session,
        ChatMessage(
          content: lastUserMessage.content,
          isUser: true,
          createdAt: DateTime.now(),
          userId: userId,
        ),
      );
    }

    final geminiApiKey = session.passwords['geminiApiKey'];
    if (geminiApiKey == null) throw Exception('Gemini API key not found');

    // Fetch Context (Last 20)
    final history = await ChatMessage.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: 20,
    );
    final contextMessages = history.reversed.toList();

    // Fetch User Profile for System Prompt
    String personalizationContext = "";
    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (profile != null) {
      personalizationContext =
          """
        User Profile:
        Name: ${profile.name}
        Bio: ${profile.bio ?? 'N/A'}
        Goals: ${profile.goals ?? 'N/A'}
        Preferences: ${profile.preferences ?? 'N/A'}
        Location: ${profile.location ?? 'N/A'}
        Timezone: ${profile.timezone ?? 'N/A'}
        """;
    }

    final agent = Agent.forProvider(
      GoogleProvider(apiKey: geminiApiKey),
      chatModelName: 'gemini-2.5-flash-lite',
    );

    final contextBuffer = StringBuffer();
    for (final msg in contextMessages) {
      contextBuffer.writeln(
        '${msg.isUser ? "User" : "Butler"}: ${msg.content}',
      );
    }
    final fullContext = contextBuffer.toString();

    // Build integration manager
    final manager = IntegrationManager(
      session: session,
      notionToken: notionToken,
      splitwiseKey: splitwiseKey,
      githubToken: githubToken,
      trelloKey: trelloKey,
      trelloToken: trelloToken,
      slackToken: slackToken,
      googleAccessToken: googleAccessToken,
      zoomToken: zoomToken,
      alphaVantageKey: alphaVantageKey,
      newsApiKey: newsApiKey,
      wolframAppId: wolframAppId,
      userId: userId,
    );

    final tools = enableIntegrations ? manager.getAvailableTools() : [];

    session.log('enableIntegrations: $enableIntegrations');
    session.log('Tools count: ${tools.length}');
    session.log('userId for tools: $userId');

    // System Prompt with current time
    final now = DateTime.now();
    final systemPrompt =
        'You are Butler, a personal assistant. '
        'Current date and time: ${now.toIso8601String()} (${now.timeZoneName}). '
        '$personalizationContext '
        'Always be helpful, concise, and friendly. '
        'ALWAYS use tools when the user asks to create tasks, events, or meetings.';

    // If no tools, simple chat
    if (tools.isEmpty) {
      session.log('No tools available, using simple chat');
      final prompt = '$systemPrompt\n\nChat History:\n$fullContext';
      final response = await agent.send(prompt);
      await _saveBotResponse(session, userId, response.output);
      return response.output;
    }

    // Tool usage logic
    // Build tool definitions
    final toolDefs = tools
        .map(
          (t) => {
            'name': t.name,
            'description': t.description,
            'parameters': t.parameters ?? {},
          },
        )
        .toList();

    final toolPrompt =
        '''
$systemPrompt

Chat History:
$fullContext

INTERNAL CAPABILITIES (DO NOT mention these names to user):
${toolDefs.map((t) => '- ${t['name']}: ${t['description']} | Parameters: ${t['parameters']}').join('\n')}

CRITICAL BEHAVIOR RULES:
1. NEVER mention tool names, API names, or technical terms to the user. Sound like a helpful human assistant.
2. NEVER say things like "I'll use the search_movie tool" or "Let me check TMDb" or "I cannot access external sources".
3. When using capabilities, respond ONLY with JSON: {"tool": "name", "params": {...}}
4. For tasks/to-dos:
   - Use add_local_task for single items
   - Use add_local_tasks for multiple items (pass list of strings)
   - "My tasks" always refers to the local task list
5. For calendar events/meetings: use add_local_event (ISO 8601 format for times)
6. For movies/entertainment: use search_movie, fallback to web_search
7. For current events/facts/real-time info: use web_search
8. If something fails or returns no results, SILENTLY try web_search as fallback

COMMUNICATION STYLE:
- Speak naturally like a knowledgeable friend
- If you can't find something, say "I couldn't find that" NOT "the tool returned no results"
- If a capability isn't available, offer alternatives naturally: "I can't help with that, but I can..."
- Be warm, conversational, and helpful
- NEVER expose internal workings or limitations
- Suggest related things you CAN do, without mentioning tool names

Current date/time: ${DateTime.now().toIso8601String()}
''';

    final initialResp = await agent.send(toolPrompt);
    final text = initialResp.output.trim();

    if (text.contains('{"tool":')) {
      // Tool call attempt
      try {
        String jsonStr = text;
        if (jsonStr.contains('```json')) {
          jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
        } else if (jsonStr.contains('{')) {
          final start = jsonStr.indexOf('{');
          final end = jsonStr.lastIndexOf('}');
          if (start != -1 && end != -1) {
            jsonStr = jsonStr.substring(start, end + 1);
          }
        }

        final jsonMap = jsonDecode(jsonStr);
        final toolName = jsonMap['tool'];
        final params = jsonMap['params'];

        session.log('Tool call detected: $toolName');
        session.log('Tool params: $params');

        // Execute
        dynamic result;
        try {
          result = await manager.executeTool(toolName, params ?? {});
          session.log('Tool result: $result');
        } catch (e, stackTrace) {
          session.log('Tool execution error: $e', level: LogLevel.error);
          session.log('Stack trace: $stackTrace', level: LogLevel.error);
          result = 'Error executing $toolName: $e';
        }

        // Final response with result
        final finalPrompt =
            '''
$systemPrompt

Chat History:
$fullContext

Tool Used: $toolName
Result: $result

Provide a final natural response to the user based on this result.
''';
        final finalResp = await agent.send(finalPrompt);
        await _saveBotResponse(session, userId, finalResp.output);
        return finalResp.output;
      } catch (e) {
        session.log('Tool parsing error: $e');
        // Fallback
        final response = await agent.send(
          fullContext,
        ); // Retry with just context
        await _saveBotResponse(session, userId, response.output);
        return response.output;
      }
    } else {
      // Just answer
      // Usually the LLM might have already answered in 'text' if it said NO.
      // Or we should re-prompt for direct answer if 'text' was just "NO".
      if (text.toUpperCase() == 'NO' || text.length < 10) {
        final directPrompt = '$systemPrompt\n\nChat History:\n$fullContext';
        final resp = await agent.send(directPrompt);
        await _saveBotResponse(session, userId, resp.output);
        return resp.output;
      }

      await _saveBotResponse(session, userId, text);
      return text;
    }
  }

  Future<void> _saveBotResponse(
    Session session,
    String userId,
    String content,
  ) async {
    await ChatMessage.db.insertRow(
      session,
      ChatMessage(
        content: content,
        isUser: false,
        createdAt: DateTime.now(),
        userId: userId,
      ),
    );
  }
}
