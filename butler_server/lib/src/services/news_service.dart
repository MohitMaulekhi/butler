import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// NewsData.io News Service
/// API Docs: https://newsdata.io/documentation
class NewsService {
  final Session session;
  final String apiKey;

  NewsService(this.session, this.apiKey);

  /// Get top headlines for a country
  Future<String> getHeadlines({
    String country = 'in', // Default to India
    String? category,
    int pageSize = 10,
  }) async {
    final jsonBody = await fetchRawHeadlines(
      country: country,
      category: category,
    );
    return _formatArticles(jsonBody);
  }

  /// Fetch raw headlines from NewsData.io
  Future<String> fetchRawHeadlines({
    String country = 'in',
    String? category,
    int pageSize = 10,
  }) async {
    // NewsData.io API endpoint
    var urlStr =
        'https://newsdata.io/api/1/latest?apikey=$apiKey&country=$country&size=$pageSize';

    // Add category if provided (valid: business, entertainment, environment, food, health, politics, science, sports, technology, top, tourism, world)
    if (category != null && category.isNotEmpty) {
      urlStr += '&category=$category';
    }

    session.log('Fetching news from NewsData.io: $urlStr');
    final url = Uri.parse(urlStr);

    try {
      final response = await http.get(url);
      session.log('NewsData.io response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        session.log(
          'NewsData.io error: ${response.body}',
          level: LogLevel.error,
        );
        return '{"status": "error", "message": "${response.reasonPhrase}"}';
      }

      return response.body;
    } catch (e) {
      session.log('NewsData.io exception: $e', level: LogLevel.error);
      return '{"status": "error", "message": "$e"}';
    }
  }

  /// Search news by keyword
  Future<String> searchNews(String query) async {
    final jsonBody = await fetchRawSearch(query);
    return _formatArticles(jsonBody);
  }

  /// Fetch raw search results from NewsData.io
  Future<String> fetchRawSearch(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'https://newsdata.io/api/1/latest?apikey=$apiKey&q=$encodedQuery',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return '{"status": "error", "message": "${response.reasonPhrase}"}';
      }

      return response.body;
    } catch (e) {
      return '{"status": "error", "message": "$e"}';
    }
  }

  /// Format articles for display
  String _formatArticles(String jsonBody) {
    try {
      final data = jsonDecode(jsonBody);

      // NewsData.io uses 'status' field: 'success' or 'error'
      if (data['status'] == 'error') {
        return 'Error: ${data['results']?['message'] ?? data['message'] ?? 'Unknown error'}';
      }

      // NewsData.io uses 'results' instead of 'articles'
      final articles = data['results'] as List?;
      if (articles == null || articles.isEmpty) {
        return 'No news found.';
      }

      final buffer = StringBuffer();
      for (var a in articles.take(10)) {
        final title = a['title'] ?? 'No title';
        final source = a['source_name'] ?? a['source_id'] ?? 'Unknown';
        buffer.writeln('- $title ($source)');
      }
      return buffer.toString();
    } catch (e) {
      session.log('Error parsing news: $e', level: LogLevel.error);
      return 'Error parsing news: $e';
    }
  }
}
