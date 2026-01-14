import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'email_service.dart';
import 'github_service.dart';
import 'news_service.dart';
import 'travel_service.dart';
import 'tavily_service.dart';

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
  final String? githubToken;
  final String? amadeusKey;
  final String? weatherKey;
  final String? newsApiKey;
  final String? tavilyApiKey;

  IntegrationManager({
    required this.session,
    this.githubToken,
    this.amadeusKey,
    this.weatherKey,
    this.newsApiKey,
    this.tavilyApiKey,
  });

  /// Gets list of available tools based on provided tokens.
  List<ToolSchema> getAvailableTools() {
    final tools = <ToolSchema>[];

    if (githubToken != null) {
      tools.addAll([
        ToolSchema(
          name: 'list_repos',
          description: 'List user\'s GitHub repositories',
        ),
        ToolSchema(
          name: 'get_issues',
          description: 'Get issues from a GitHub repository',
          parameters: {
            'owner': 'string',
            'repo': 'string',
          },
        ),
      ]);
    }

    if (amadeusKey != null) {
      tools.add(
        ToolSchema(
          name: 'search_flights',
          description: 'Search for flights between cities',
          parameters: {
            'origin': 'string (airport code like SFO)',
            'destination': 'string (airport code like NYC)',
            'date': 'string (YYYY-MM-DD)',
          },
        ),
      );
    }

    if (weatherKey != null) {
      tools.add(
        ToolSchema(
          name: 'get_weather',
          description: 'Get current weather forecast for a city',
          parameters: {'city': 'string'},
        ),
      );
    }

    // Task Management
    tools.addAll([
      ToolSchema(
        name: 'create_task',
        description: 'Create a new task',
        parameters: {'title': 'string'},
      ),
      ToolSchema(
        name: 'list_tasks',
        description: 'List all tasks',
      ),
      ToolSchema(
        name: 'complete_task',
        description: 'Mark a task as completed',
        parameters: {'id': 'integer'},
      ),
    ]);

    // Email
    tools.add(
      ToolSchema(
        name: 'send_email',
        description: 'Send an email',
        parameters: {
          'recipient': 'string',
          'subject': 'string',
          'body': 'string',
        },
      ),
    );

    // Calendar
    tools.addAll([
      ToolSchema(
        name: 'schedule_event',
        description: 'Schedule a calendar event',
        parameters: {
          'title': 'string',
          'time': 'string (ISO 8601, e.g. 2023-10-27T10:00:00)',
          'duration': 'integer (minutes)',
          'description': 'string (optional)',
        },
      ),
      ToolSchema(
        name: 'check_schedule',
        description: 'Check schedule for a specific date',
        parameters: {'date': 'string (YYYY-MM-DD)'},
      ),
    ]);

    // News
    if (newsApiKey != null) {
      tools.addAll([
        ToolSchema(
          name: 'get_top_headlines',
          description: 'Get top news headlines',
          parameters: {
            'country': 'string (us, gb, etc. default us)',
            'category': 'string (business, technology, etc. optional)',
          },
        ),
        ToolSchema(
          name: 'search_news',
          description: 'Search for news articles',
          parameters: {'query': 'string'},
        ),
      ]);
    }



    if (tavilyApiKey != null) {
      tools.add(
        ToolSchema(
          name: 'web_search',
          description: 'Search the web for information using Tavily',
          parameters: {'query': 'string'},
        ),
      );
    }

    return tools;
  }

  /// Executes a tool by name.
  Future<dynamic> executeTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    session.log('Executing tool: $toolName with args: $arguments');

    switch (toolName) {
      // GitHub
      case 'list_repos':
        if (githubToken == null) throw Exception('GitHub token required');
        return await GitHubService.listRepositories(session, githubToken!);

      case 'get_issues':
        if (githubToken == null) throw Exception('GitHub token required');
        final owner = arguments['owner'] as String;
        final repo = arguments['repo'] as String;
        return await GitHubService.getIssues(
          session,
          githubToken!,
          owner,
          repo,
        );

      // Travel
      case 'search_flights':
        if (amadeusKey == null) throw Exception('Amadeus API key required');
        return await TravelService.searchFlights(
          session,
          origin: arguments['origin'],
          destination: arguments['destination'],
          date: arguments['date'],
          amadeusKey: amadeusKey!,
        );

      case 'get_weather':
        if (weatherKey == null) throw Exception('Weather API key required');
        final city = arguments['city'] as String;
        return await TravelService.getWeather(session, city, weatherKey!);

      // Task Management
      case 'create_task':
        final title = arguments['title'] as String;
        final task = Task(
          title: title,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        await Task.db.insertRow(session, task);
        return task;

      case 'list_tasks':
        return await Task.db.find(
          session,
          orderBy: (t) => t.createdAt,
        );

      case 'complete_task':
        final id = arguments['id'];
        final taskId = id is int ? id : int.parse(id.toString());
        final task = await Task.db.findById(session, taskId);
        if (task == null) return {'error': true, 'message': 'Task not found'};
        
        task.isCompleted = true;
        await Task.db.updateRow(session, task);
        return task;

      // Email
      case 'send_email':
        return await EmailService.sendEmail(
          session: session,
          recipient: arguments['recipient'],
          subject: arguments['subject'],
          html: arguments['body'],
        );

      // Calendar
      case 'schedule_event':
        final title = arguments['title'] as String;
        final timeStr = arguments['time'] as String;
        final duration = arguments['duration'] is int 
            ? arguments['duration'] as int 
            : int.parse(arguments['duration'].toString());
        final description = arguments['description'] as String?;

        final startTime = DateTime.parse(timeStr);
        final endTime = startTime.add(Duration(minutes: duration));

        final event = CalendarEvent(
          title: title,
          startTime: startTime,
          endTime: endTime,
          description: description,
        );
        await CalendarEvent.db.insertRow(session, event);
        return event;

      case 'check_schedule':
        final dateStr = arguments['date'] as String;
        final date = DateTime.parse(dateStr);
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(Duration(days: 1));

        return await CalendarEvent.db.find(
          session,
          where: (e) => (e.startTime >= start) & (e.startTime < end),
          orderBy: (e) => e.startTime,
        );

      // News
      case 'get_top_headlines':
        if (newsApiKey == null) throw Exception('News API key required');
        final service = NewsService(session, newsApiKey!);
        return await service.getTopHeadlines(
          country: arguments['country'] ?? 'us',
          category: arguments['category'],
        );

      case 'search_news':
        if (newsApiKey == null) throw Exception('News API key required');
        final service = NewsService(session, newsApiKey!);
        return await service.searchNews(arguments['query']);



      case 'web_search':
        if (tavilyApiKey == null) throw Exception('Tavily API key required');
        final service = TavilyService(session, tavilyApiKey!);
        return await service.search(arguments['query']);

      default:
        throw Exception('Unknown tool: $toolName');
    }
  }
}
