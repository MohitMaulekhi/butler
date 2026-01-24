import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class WolframService {
  final Session session;
  final String appId;

  WolframService(this.session, this.appId);

  Future<String> query(String input) async {
    final url = Uri.parse(
      'http://api.wolframalpha.com/v1/result?appid=$appId&i=$input',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      session.log('Wolfram error: ${response.body}');
      return 'Error: ${response.body} (Status: ${response.statusCode})';
    }

    return response.body;
  }
}
