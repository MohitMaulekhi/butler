import 'package:serverpod/serverpod.dart';
import '../services/news_service.dart';

class NewsEndpoint extends Endpoint {
  Future<String> getTopHeadlines(
    Session session, {
    String? country,
    String? category,
    int pageSize = 20,
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
      pageSize: pageSize,
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
}
