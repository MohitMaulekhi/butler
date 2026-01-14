import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class TavilyService {
  static const String _baseUrl = 'https://api.tavily.com';
  final String apiKey;
  final Session session;

  TavilyService(this.session, this.apiKey);

  Future<dynamic> search(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'api_key': apiKey,
          'query': query,
          'search_depth': 'basic',
          'include_answer': true,
          'max_results': 5,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        session.log('Tavily Error: ${response.statusCode} - ${response.body}', level: LogLevel.error);
        return {'error': true, 'message': 'Failed to perform web search'};
      }
    } catch (e) {
      session.log('Tavily Exception: $e', level: LogLevel.error);
      return {'error': true, 'message': e.toString()};
    }
  }
}
