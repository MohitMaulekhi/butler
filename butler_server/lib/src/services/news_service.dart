import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  final String apiKey;
  final Session session;

  NewsService(this.session, this.apiKey);

  Future<dynamic> getTopHeadlines({String country = 'us', String? category, int pageSize = 20}) async {
    try {
      final uri = Uri.parse('$_baseUrl/top-headlines').replace(queryParameters: {
        'country': country,
        if (category != null) 'category': category,
        'pageSize': pageSize.toString(),
        'apiKey': apiKey,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        session.log('NewsAPI Error: ${response.statusCode} - ${response.body}', level: LogLevel.error);
        return {'error': true, 'message': 'Failed to fetch news'};
      }
    } catch (e) {
      session.log('NewsAPI Exception: $e', level: LogLevel.error);
      return {'error': true, 'message': e.toString()};
    }
  }

  Future<dynamic> searchNews(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/everything').replace(queryParameters: {
        'q': query,
        'apiKey': apiKey,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        session.log('NewsAPI Error: ${response.statusCode} - ${response.body}', level: LogLevel.error);
        return {'error': true, 'message': 'Failed to search news'};
      }
    } catch (e) {
      session.log('NewsAPI Exception: $e', level: LogLevel.error);
      return {'error': true, 'message': e.toString()};
    }
  }
}
