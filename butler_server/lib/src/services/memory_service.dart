import 'package:butler_server/src/services/embedding_service.dart';
import 'package:serverpod/serverpod.dart';

class MemoryService {
  final EmbeddingService _embeddingService;

  MemoryService(String apiKey) : _embeddingService = EmbeddingService(apiKey);

  Future<void> addMemory(
    Session session,
    String userId,
    String content,
  ) async {
    try {
      final embedding = await _embeddingService.embed(content);
      final embeddingString = '[${embedding.join(',')}]';

      // Insert using raw SQL because Serverpod doesn't support vector type yet in ORM
      final query = '''
        INSERT INTO "user_memory" ("userId", "content", "createdAt", "embedding")
        VALUES (@userId, @content, @createdAt, @embedding::vector)
      ''';

      await session.db.unsafeQuery(
        query,
        parameters: QueryParameters.named({
          'userId': userId,
          'content': content,
          'createdAt': DateTime.now(),
          'embedding': embeddingString,
        }),
      );
    } catch (e) {
      session.log('Error adding memory: $e', level: LogLevel.error);
      rethrow;
    }
  }

  Future<List<String>> searchMemories(
    Session session,
    String userId,
    String queryText, {
    int limit = 5,
  }) async {
    try {
      final embedding = await _embeddingService.embed(queryText);
      final embeddingString = '[${embedding.join(',')}]';

      // Search using cosine distance operator <=>
      // We also filter by userId
      final query = '''
        SELECT "content"
        FROM "user_memory"
        WHERE "userId" = @userId
        ORDER BY "embedding" <=> @embedding::vector
        LIMIT @limit
      ''';

      final result = await session.db.unsafeQuery(
        query,
        parameters: QueryParameters.named({
          'userId': userId,
          'embedding': embeddingString,
          'limit': limit,
        }),
      );

      return result.map((row) => row.first as String).toList();
    } catch (e) {
      session.log('Error searching memories: $e', level: LogLevel.error);
      return [];
    }
  }
}
