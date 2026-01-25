import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import '../services/news_service.dart';

class NewsEndpoint extends Endpoint {
  Future<String> getTopHeadlines(
    Session session, {
    String? country,
    String? category,
    int pageSize = 10,
  }) async {
    final newsApiKey = session.passwords['newsApiKey'];
    if (newsApiKey == null) {
      throw Exception('News API key not found in server passwords');
    }

    // Fallback to 'us' if no country provided
    // Ideally the client should provide the country code based on its location.
    final targetCountry = (country != null && country.isNotEmpty)
        ? country
        : 'us';

    final service = NewsService(session, newsApiKey);
    final result = await service.fetchRawHeadlines(
      country: targetCountry,
      category: category,
      pageSize: pageSize > 10 ? 10 : pageSize,
    );
    return result;
  }

  Future<String> searchNews(Session session, String query) async {
    final newsApiKey = session.passwords['newsApiKey'];
    if (newsApiKey == null) {
      throw Exception('News API key not found in server passwords');
    }

    final service = NewsService(session, newsApiKey);
    final result = await service.fetchRawSearch(query);
    return result;
  }
  Future<String> getLocation(Session session) async {
    try {
      // Use ip-api.com via server (safe from mixed content)
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['countryCode']?.toString().toLowerCase() ?? 'us';
      }
    } catch (e) {
      session.log('Failed to detect location: $e', level: LogLevel.warning);
    }
    return 'us';
  }
}
