import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class MovieService {
  final Session session;
  final String apiKey;

  MovieService(this.session, this.apiKey);

  Future<String> searchMovie(String query) async {
    final url = Uri.parse(
      'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return 'Error: ${response.statusCode}';
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List;
    if (results.isEmpty) return 'No movies found.';

    final buffer = StringBuffer();
    for (var m in results.take(5)) {
      final title = m['title'];
      final date = m['release_date'] ?? 'Unknown';
      final overview = m['overview'] ?? '';
      final rating = m['vote_average'];
      buffer.writeln('**$title** ($date) - Rating: $rating\n$overview\n');
    }
    return buffer.toString();
  }
}
