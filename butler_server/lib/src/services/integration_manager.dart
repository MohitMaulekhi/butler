import 'package:serverpod/serverpod.dart';
import 'github_service.dart';
import 'travel_service.dart';

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

  IntegrationManager({
    required this.session,
    this.githubToken,
    this.amadeusKey,
    this.weatherKey,
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

    return tools;
  }

  /// Executes a tool by name.
  Future<dynamic> executeTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    session.log('Executing tool: $toolName with args: $arguments');

    switch (toolName) {
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

      default:
        throw Exception('Unknown tool: $toolName');
    }
  }
}
