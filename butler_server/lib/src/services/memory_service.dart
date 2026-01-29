import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'embedding_service.dart';

class MemoryService {
  final EmbeddingService _embeddingService;
  final String _apiKey;
  final String _targetUrl;

  MemoryService({
    required EmbeddingService embeddingService,
    required String apiKey,
    required String indexName,
    String? environment,
    String? baseUrl,
  }) : _embeddingService = embeddingService,
       _apiKey = apiKey,
       _targetUrl =
           baseUrl ??
           'https://$indexName-$environment.svc.$environment.pinecone.io';

  Future<void> addMemory(Session session, String userId, String content) async {
    // 1. Get Embedding
    final embeddings = await _embeddingService.embedQuery(content);

    // 2. Upsert to Pinecone via REST API
    final url = Uri.parse('$_targetUrl/vectors/upsert');
    session.log('Attempting Pinecone Upsert to: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
          'X-Pinecone-API-Version': '2024-07',
        },
        body: jsonEncode({
          'vectors': [
            {
              'id': '${userId}_${DateTime.now().millisecondsSinceEpoch}',
              'values': embeddings,
              'metadata': {
                'userId': userId,
                'content': content,
                'timestamp': DateTime.now().toIso8601String(),
              },
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        session.log(
          'Pinecone Upsert Failed: ${response.statusCode} ${response.body}',
          level: LogLevel.error,
        );
        throw Exception('Pinecone upsert failed: ${response.body}');
      } else {
        session.log('Pinecone Upsert Success: ${response.statusCode}');
      }
    } catch (e) {
      session.log('Pinecone connection error: $e', level: LogLevel.error);
      rethrow;
    }

    // 3. Save to Postgres for UI
    await UserMemory.db.insertRow(
      session,
      UserMemory(
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<String>> searchMemories(String userId, String query) async {
    // 1. Get Embedding
    final embeddings = await _embeddingService.embedQuery(query);

    // 2. Query Pinecone
    final url = Uri.parse('$_targetUrl/query');
    // Using print since we don't have session here easily unless passed,
    // but wait, searchMemories signature in previous turn didn't have session.
    // I will add print for now or check if I can add session.
    print('Attempting Pinecone Query to: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
          'X-Pinecone-API-Version': '2024-07',
        },
        body: jsonEncode({
          'vector': embeddings,
          'topK': 5,
          'includeMetadata': true,
          'filter': {'userId': userId},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final matches = data['matches'] as List?;
        if (matches == null) return [];

        return matches
            .map((m) {
              final metadata = m['metadata'];
              return metadata != null
                  ? (metadata['content'] as String? ?? '')
                  : '';
            })
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        // Log but don't crash chat flow
        print('Pinecone Query Failed: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Pinecone search error: $e');
      return [];
    }
  }
}
