import 'package:mailer/mailer.dart' as mail;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';

class EmailService {
  static SmtpServer? _smtpServer;
  static String? _fromEmail;
  static bool _initialized = false;

  static Future<void> init(Session session) async {
    if (_initialized) return;

    final username = session.serverpod.getPassword('emailEmail');
    final password = session.serverpod.getPassword('emailPassword');

    if (username == null || password == null) {
      session.log(
        'Email credentials (emailEmail, emailPassword) not found in passwords.yaml. Email functionality disabled.',
        level: LogLevel.error,
      );
      return;
    }

    _fromEmail = username;
    // Configure SMTP server for Gmail by default as per previous settings
    // For production, this might need to be configurable
    _smtpServer = gmail(username, password);
    _initialized = true;
  }

  static Future<bool> sendEmail({
    required Session session,
    required String recipient,
    required String subject,
    required String html,
    String? text,
  }) async {
    // Ensure initialized
    if (!_initialized) {
      await init(session);
    }

    if (!_initialized || _smtpServer == null || _fromEmail == null) {
      session.log(
        'EmailService not initialized or credentials missing. Cannot send email to $recipient',
        level: LogLevel.warning,
      );
      return false;
    }

    final message = mail.Message()
      ..from = mail.Address(_fromEmail!, 'Butler App')
      ..recipients.add(recipient)
      ..subject = subject
      ..text =
          text ??
          html // Simple fallback
      ..html = html;

    try {
      await mail.send(message, _smtpServer!);
      return true;
    } catch (e) {
      session.log(
        'Failed to send email to $recipient: $e',
        level: LogLevel.error,
        exception: e,
      );

      return false;
    }
  }

  // Wrapper for OTP specific use case
  static Future<bool> sendValidationCode({
    required Session session,
    required String recipient,
    required String validationCode,
    bool isPasswordReset = false,
  }) async {
    final subject = isPasswordReset
        ? 'Reset your password'
        : 'Verify your email';
    final action = isPasswordReset ? 'password reset' : 'email verification';
    final html =
        '''
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>$subject</h2>
        <p>Your $action code is:</p>
        <h1 style="color: #4a90e2; letter-spacing: 5px;">$validationCode</h1>
        <p>If you didn't request this, please ignore this email.</p>
      </div>
    ''';

    return sendEmail(
      session: session,
      recipient: recipient,
      subject: subject,
      html: html,
      text: 'Your $action code is: $validationCode',
    );
  }
}
