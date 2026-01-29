import 'package:langchain/langchain.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class EmbeddingService implements Embeddings {
  final GenerativeModel _model;

  EmbeddingService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-embedding-001',
        apiKey: apiKey,
      );

  @override
  Future<List<List<double>>> embedDocuments(List<Document> documents) async {
    final batch = documents
        .map((d) => EmbedContentRequest(Content.text(d.pageContent)))
        .toList();

    final response = await _model.batchEmbedContents(batch);
    return response.embeddings
        .map((e) => e.values.take(1024).toList())
        .toList();
  }

  @override
  Future<List<double>> embedQuery(String query) async {
    final response = await _model.embedContent(Content.text(query));
    return response.embedding.values.take(1024).toList();
  }
}
