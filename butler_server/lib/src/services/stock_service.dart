import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class StockService {
  final Session session;
  final String apiKey;

  StockService(this.session, this.apiKey);

  Future<String> getStockPrice(String symbol) async {
    final url = Uri.parse(
      'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return 'Error: ${response.statusCode}';
    }

    final data = jsonDecode(response.body);
    final quote = data['Global Quote'];
    if (quote == null || quote.isEmpty) {
      return 'Symbol not found or limit reached.';
    }

    final price = quote['05. price'];
    final change = quote['09. change'];
    final percent = quote['10. change percent'];

    return 'Price of $symbol: \$$price (Change: $change / $percent)';
  }
}
