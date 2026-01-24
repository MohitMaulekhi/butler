import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class ZoomService {
  final Session session;
  final String
  jwtToken; // For simplicity in V1, assuming user provides a JWT or OAuth Access Token

  ZoomService(this.session, this.jwtToken);

  Future<String> createMeeting(String topic) async {
    // Assuming 'me' logic works with the provided token context
    final url = Uri.parse('https://api.zoom.us/v2/users/me/meetings');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topic,
        'type': 2, // Scheduled meeting (defaultish) or 1 for instant
      }),
    );

    if (response.statusCode != 201) {
      return 'Error creating meeting: ${response.statusCode} - ${response.body}';
    }

    final data = jsonDecode(response.body);
    return 'Meeting created: ${data['join_url']}';
  }
}
