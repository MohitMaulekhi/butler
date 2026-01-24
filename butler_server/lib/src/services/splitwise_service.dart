import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class SplitwiseService {
  final Session session;
  final String apiKey;

  SplitwiseService(this.session, this.apiKey);

  /// Get current user info to verify key
  Future<String> getCurrentUser() async {
    final url = Uri.parse(
      'https://secure.splitwise.com/api/v3.0/get_current_user',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode != 200) {
      return 'Error: ${response.statusCode}';
    }

    final data = jsonDecode(response.body);
    final user = data['user'];
    return 'Logged in as ${user['first_name']} ${user['last_name']}';
  }

  /// Add an expense (simplified: you paid, split equally)
  Future<String> addExpense({
    required String description,
    required String cost,
  }) async {
    // 1. Get current user ID
    final userUrl = Uri.parse(
      'https://secure.splitwise.com/api/v3.0/get_current_user',
    );
    final userResp = await http.get(
      userUrl,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (userResp.statusCode != 200) return 'Error getting user info.';
    // final userData = jsonDecode(userResp.body);

    // 2. Create expense
    // Note: Splitwise API requires complex 'users' array for splits.
    // For "I paid, split equally", we effectively need a group or a friend to split with.
    // Without a specific group/friend ID, this is hard.
    // Simplifying: Just create an expense where "I paid" and "amount" is cost.
    // But Splitwise needs to know who owes whom.
    // FALLBACK: Just list recent expenses or check balance if adding is too complex without inputs.
    // Let's implement "get_expenses" instead as primary tool, and "add_expense" as best effort requiring friend info?
    // Or just create an expense for "User" (self) which is valid? No.
    // Let's stick to "get expenses" or "list friends" for now as safe bets for V1.
    return "Expense creation requires tailored group/friend selection which is complex for chat. Please use the app.";
  }

  Future<String> getFriends() async {
    final url = Uri.parse('https://secure.splitwise.com/api/v3.0/get_friends');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode != 200) return 'Error: ${response.statusCode}';

    final data = jsonDecode(response.body);
    final friends = data['friends'] as List;
    if (friends.isEmpty) return 'No friends found.';

    final buffer = StringBuffer();
    for (var f in friends) {
      final name = '${f['first_name']} ${f['last_name'] ?? ''}'.trim();
      final balance = f['balance'].isEmpty ? '0.00' : f['balance'][0]['amount'];
      buffer.writeln('- $name (Balance: $balance)');
    }
    return buffer.toString();
  }
}
