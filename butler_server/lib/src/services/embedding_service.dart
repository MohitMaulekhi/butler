import 'package:google_generative_ai/google_generative_ai.dart';

class EmbeddingService {
  final GenerativeModel _model;

  EmbeddingService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-embedding-001', apiKey: apiKey);

  Future<List<double>> embed(String text) async {
    final response = await _model.batchEmbedContents([
      EmbedContentRequest(Content.text(text)),
    ]);
    final embedding = response.embeddings.first;
    return embedding.values;
  }
}
