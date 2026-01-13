import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../services/news_service.dart';

class NewsEndpoint extends Endpoint {
  Future<String> getTopHeadlines(Session session, {String country = 'us', String? category, int pageSize = 20}) async {
    final newsApiKey = session.passwords['newsApiKey'];
    if (newsApiKey == null) {
      throw Exception('News API key not found in server passwords');
    }
    
    final service = NewsService(session, newsApiKey);
    final result = await service.getTopHeadlines(country: country, category: category, pageSize: pageSize);
    return jsonEncode(result);
  }

  Future<String> searchNews(Session session, String query) async {
    final newsApiKey = session.passwords['newsApiKey'];
    if (newsApiKey == null) {
      throw Exception('News API key not found in server passwords');
    }

    final service = NewsService(session, newsApiKey);
    final result = await service.searchNews(query);
    return jsonEncode(result);
  }
}
