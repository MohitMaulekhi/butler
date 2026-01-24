import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class SlackService {
  final Session session;
  final String token;
  // Token can be Bot User OAuth Token (xoxb-...) or User OAuth Token (xoxp-...)

  SlackService(this.session, this.token);

  Future<String> sendMessage(String channel, String text) async {
    final url = Uri.parse('https://slack.com/api/chat.postMessage');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'channel': channel,
        'text': text,
      }),
    );

    if (response.statusCode != 200) {
      return 'HTTP Error: ${response.statusCode}';
    }

    final data = jsonDecode(response.body);
    if (data['ok'] != true) {
      return 'Slack API Error: ${data['error']}';
    }

    return 'Message sent to $channel.';
  }
}
