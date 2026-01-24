import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class CryptoService {
  final Session session;

  CryptoService(this.session);

  Future<String> getPrice(String coinId) async {
    // coinId e.g., bitcoin, ethereum
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price?ids=$coinId&vs_currencies=usd,eur&include_24hr_change=true',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return 'Error: ${response.statusCode}';
    }

    final data = jsonDecode(response.body);
    if (!data.containsKey(coinId)) {
      return 'Coin not found (try bitcoin, ethereum).';
    }

    final info = data[coinId];
    final usd = info['usd'];
    final change = info['usd_24h_change'];

    return '$coinId: \$$usd (24h: ${change?.toStringAsFixed(2)}%)';
  }
}
