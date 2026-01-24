import 'dart:convert';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class GmailService {
  final Session session;

  GmailService(this.session);

  Future<String> sendEmail(
    String accessToken,
    String recipient,
    String subject,
    String body,
  ) async {
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().add(Duration(hours: 1)).toUtc(),
        ),
        null,
        [gmail.GmailApi.gmailSendScope],
      ),
    );

    final api = gmail.GmailApi(client);

    final message = gmail.Message()
      ..raw = _createEmail(recipient, subject, body);

    try {
      await api.users.messages.send(message, 'me');
      return 'Email sent to $recipient';
    } catch (e) {
      return 'Failed to send email: $e';
    }
  }

  String _createEmail(String to, String subject, String body) {
    final email =
        'To: $to\r\n'
        'Subject: $subject\r\n'
        'Content-Type: text/plain; charset="UTF-8"\r\n\r\n'
        '$body';
    return base64UrlEncode(utf8.encode(email));
  }
}
