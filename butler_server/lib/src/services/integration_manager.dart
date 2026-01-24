import 'package:serverpod/serverpod.dart';
import 'github_service.dart';
import 'notion_service.dart';
import 'splitwise_service.dart';
import 'trello_service.dart';
import 'slack_service.dart';
import 'google_tasks_service.dart';
import 'zoom_service.dart';
import 'gmail_service.dart';
import 'movie_service.dart';
import 'wolfram_service.dart';
import 'stock_service.dart';
import 'crypto_service.dart';
import 'news_service.dart';
import 'weather_service.dart';
import 'tavily_service.dart';
import '../generated/protocol.dart';

/// Tool schema for Gemini.
class ToolSchema {
  final String name;
  final String description;
  final Map<String, dynamic>? parameters;

  ToolSchema({
    required this.name,
    required this.description,
    this.parameters,
  });
}

/// Integration manager coordinating all services.
class IntegrationManager {
  final Session session;
  // User Keys
  final String? notionToken;
  final String? splitwiseKey;
  final String? githubToken;
  final String? trelloKey;
  final String? trelloToken;
  final String? slackToken;
  final String? googleAccessToken; // For Tasks, Gmail, Calendar
  final String? zoomToken;
  final String? alphaVantageKey;
  final String? newsApiKey; // User provided as per plan
  final String? wolframAppId; // User provided as per plan
  final String? userId; // For local task/calendar creation

  // Server Keys (loaded from passwords)
  // Weather, TMDB, CoinGecko(free)

  IntegrationManager({
    required this.session,
    this.notionToken,
    this.splitwiseKey,
    this.githubToken,
    this.trelloKey,
    this.trelloToken,
    this.slackToken,
    this.googleAccessToken,
    this.zoomToken,
    this.alphaVantageKey,
    this.newsApiKey,
    this.wolframAppId,
    this.userId,
  });

  /// Gets list of available tools based on provided tokens.
  List<ToolSchema> getAvailableTools() {
    final tools = <ToolSchema>[];

    // User-Key Services
    if (notionToken != null) {
      tools.add(
        ToolSchema(
          name: 'create_notion_page',
          description: 'Create a new page in Notion',
          parameters: {'title': 'string', 'content': 'string'},
        ),
      );
      tools.add(
        ToolSchema(
          name: 'search_notion',
          description: 'Search Notion pages',
          parameters: {'query': 'string'},
        ),
      );
    }

    if (splitwiseKey != null) {
      tools.add(
        ToolSchema(
          name: 'get_splitwise_friends',
          description: 'List Splitwise friends and balances',
        ),
      );
      // tools.add(ToolSchema(name: 'add_expense', ...)); // Skipped for complexity
    }

    if (githubToken != null) {
      tools.add(
        ToolSchema(name: 'list_repos', description: 'List GitHub repositories'),
      );
      tools.add(
        ToolSchema(
          name: 'get_issues',
          description: 'Get GitHub issues',
          parameters: {'owner': 'string', 'repo': 'string'},
        ),
      );
    }

    if (googleAccessToken != null) {
      tools.add(
        ToolSchema(
          name: 'send_gmail',
          description: 'Send an email via Gmail',
          parameters: {'to': 'string', 'subject': 'string', 'body': 'string'},
        ),
      );
      tools.add(
        ToolSchema(name: 'list_google_tasks', description: 'List Google Tasks'),
      );
      tools.add(
        ToolSchema(
          name: 'create_google_task',
          description: 'Create a Google Task',
          parameters: {'title': 'string'},
        ),
      );
    }

    if (zoomToken != null) {
      tools.add(
        ToolSchema(
          name: 'create_zoom_meeting',
          description: 'Create a Zoom meeting',
          parameters: {'topic': 'string'},
        ),
      );
    }

    if (trelloKey != null && trelloToken != null) {
      tools.add(
        ToolSchema(
          name: 'create_trello_card',
          description: 'Create a Trello card',
          parameters: {'board': 'string', 'list': 'string', 'card': 'string'},
        ),
      );
    }

    if (slackToken != null) {
      tools.add(
        ToolSchema(
          name: 'send_slack_message',
          description: 'Send a Slack message',
          parameters: {'channel': 'string', 'message': 'string'},
        ),
      );
    }

    if (alphaVantageKey != null) {
      tools.add(
        ToolSchema(
          name: 'get_stock_price',
          description: 'Get stock price',
          parameters: {'symbol': 'string'},
        ),
      );
    }

    tools.add(
      ToolSchema(
        name: 'get_news',
        description: 'Get top news headlines',
        parameters: {'country': 'string (us, gb, in, etc. two-letter code)'},
      ),
    );

    if (wolframAppId != null) {
      tools.add(
        ToolSchema(
          name: 'ask_wolfram',
          description: 'Ask Wolfram Alpha a question',
          parameters: {'query': 'string'},
        ),
      );
    }

    // Server-Key Services (Always check, but only add if key exists on server)
    final tmdbKey = session.passwords['tmdbKey'];
    if (tmdbKey != null) {
      tools.add(
        ToolSchema(
          name: 'search_movie',
          description: 'Search for a movie',
          parameters: {'query': 'string'},
        ),
      );
    }

    final weatherKey = session.passwords['openWeatherKey']; // Use explicit name
    if (weatherKey != null) {
      tools.add(
        ToolSchema(
          name: 'get_weather',
          description: 'Get weather forecast',
          parameters: {'city': 'string'},
        ),
      );
    }

    // CoinGecko is free
    tools.add(
      ToolSchema(
        name: 'get_crypto_price',
        description: 'Get cryptocurrency price',
        parameters: {'id': 'string'},
      ),
    );

    // Tavily Web Search (check for server key)
    final tavilyKey = session.passwords['tavilyApiKey'];
    if (tavilyKey != null) {
      tools.add(
        ToolSchema(
          name: 'web_search',
          description:
              'Search the web for current information, news, facts, or any query',
          parameters: {'query': 'string (the search query)'},
        ),
      );
    }

    // Local Task/Calendar (always available when userId is present)
    if (userId != null) {
      tools.add(
        ToolSchema(
          name: 'add_local_task',
          description: 'Add a task to the local Butler task list',
          parameters: {'title': 'string (task title)'},
        ),
      );
      tools.add(
        ToolSchema(
          name: 'add_local_event',
          description: 'Add a calendar event to the local Butler calendar',
          parameters: {
            'title': 'string (event title)',
            'startTime': 'string (ISO 8601 datetime, e.g. 2026-01-25T10:00:00)',
            'endTime': 'string (ISO 8601 datetime)',
            'description': 'string (optional description)',
          },
        ),
      );
    }

    return tools;
  }

  /// Executes a tool by name.
  Future<dynamic> executeTool(
    String toolName,
    Map<String, dynamic> args,
  ) async {
    session.log('Executing tool: $toolName with args: $args');

    switch (toolName) {
      case 'create_notion_page':
        return await NotionService(
          session,
          notionToken!,
        ).createPage(title: args['title'], content: args['content']);
      case 'search_notion':
        return await NotionService(session, notionToken!).search(args['query']);

      case 'get_splitwise_friends':
        return await SplitwiseService(session, splitwiseKey!).getFriends();

      case 'list_repos':
        return await GitHubService.listRepositories(session, githubToken!);
      case 'get_issues':
        return await GitHubService.getIssues(
          session,
          githubToken!,
          args['owner'],
          args['repo'],
        );

      case 'send_gmail':
        return await GmailService(session).sendEmail(
          googleAccessToken!,
          args['to'],
          args['subject'],
          args['body'],
        );
      case 'list_google_tasks':
        return await GoogleTasksService(
          session,
        ).listTaskLists(googleAccessToken!);
      case 'create_google_task':
        return await GoogleTasksService(
          session,
        ).addTask(googleAccessToken!, args['title']);

      case 'create_zoom_meeting':
        return await ZoomService(
          session,
          zoomToken!,
        ).createMeeting(args['topic']);

      case 'create_trello_card':
        return await TrelloService(
          session,
          trelloKey!,
          trelloToken!,
        ).createCard(args['board'], args['list'], args['card']);

      case 'send_slack_message':
        return await SlackService(
          session,
          slackToken!,
        ).sendMessage(args['channel'], args['message']);

      case 'get_stock_price':
        return await StockService(
          session,
          alphaVantageKey!,
        ).getStockPrice(args['symbol']);

      case 'get_news':
        return await NewsService(session, newsApiKey!).getHeadlines(
          country: args['country'] ?? 'us',
        );

      case 'ask_wolfram':
        return await WolframService(
          session,
          wolframAppId!,
        ).query(args['query']);

      case 'search_movie':
        final key = session.passwords['tmdbKey'];
        if (key == null) return 'TMDB Key not configured on server.';
        return await MovieService(session, key).searchMovie(args['query']);

      case 'get_weather':
        final key = session.passwords['openWeatherKey'];
        // Reusing TravelService's weather logic? No, TravelService was deleted?
        // Wait, I deleted TravelService. I need to make sure I have logic for Weather.
        // I did NOT creating a WeatherService file in previous steps.
        // I should have created one or I need to inline it or rely on a new file.
        // I will add a simple HTTP call here for now or realize I missed a file.
        // Let's implement it here or creating a `weather_service.dart` is cleaner.
        // I'll inline for now to save tool calls, it's simple.
        if (key == null) return 'Weather Key not configured.';
        return await WeatherService(session, key).getWeather(args['city']);

      case 'web_search':
        final key = session.passwords['tavilyApiKey'];
        if (key == null) return 'Tavily API Key not configured on server.';
        final result = await TavilyService(session, key).search(args['query']);
        // Format the result nicely
        if (result['error'] == true) {
          return 'Web search failed: ${result['message']}';
        }
        final answer = result['answer'] ?? '';
        final results = result['results'] as List? ?? [];
        final buffer = StringBuffer();
        if (answer.isNotEmpty) {
          buffer.writeln('Answer: $answer\n');
        }
        buffer.writeln('Sources:');
        for (var r in results.take(3)) {
          buffer.writeln('- ${r['title']}: ${r['url']}');
        }
        return buffer.toString();

      case 'get_crypto_price':
        return await CryptoService(session).getPrice(args['id']);

      case 'add_local_task':
      case 'create_task':
      case 'add_task':
      case 'create_local_task':
        if (userId == null) return 'User not authenticated';
        final taskTitle =
            args['title'] ?? args['name'] ?? args['task'] ?? 'Untitled Task';
        final task = Task(
          title: taskTitle as String,
          isCompleted: false,
          createdAt: DateTime.now(),
          userId: userId!,
        );
        await Task.db.insertRow(session, task);
        return 'Task "$taskTitle" created successfully!';

      case 'add_local_event':
      case 'create_event':
      case 'add_event':
      case 'create_calendar_event':
      case 'create_meeting':
      case 'add_meeting':
        if (userId == null) return 'User not authenticated';
        final eventTitle =
            args['title'] ?? args['name'] ?? args['topic'] ?? 'Untitled Event';
        // Handle flexible time parsing
        DateTime startTime;
        DateTime endTime;
        try {
          startTime = DateTime.parse(
            args['startTime'] ??
                args['start_time'] ??
                args['start'] ??
                DateTime.now().toIso8601String(),
          );
          endTime = DateTime.parse(
            args['endTime'] ??
                args['end_time'] ??
                args['end'] ??
                startTime.add(Duration(hours: 1)).toIso8601String(),
          );
        } catch (e) {
          // If parsing fails, use reasonable defaults
          startTime = DateTime.now().add(Duration(hours: 1));
          endTime = startTime.add(Duration(hours: 1));
        }
        final event = CalendarEvent(
          title: eventTitle as String,
          startTime: startTime,
          endTime: endTime,
          description: args['description'] as String?,
          userId: userId!,
        );
        await CalendarEvent.db.insertRow(session, event);
        return 'Calendar event "$eventTitle" created successfully!';

      default:
        throw Exception('Unknown tool: $toolName');
    }
  }
}
