import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class TrelloService {
  final Session session;
  final String apiKey;
  final String token;

  TrelloService(this.session, this.apiKey, this.token);

  Future<String> createCard(
    String boardName,
    String listName,
    String cardName,
  ) async {
    // 1. Find Board
    final boardsUrl = Uri.parse(
      'https://api.trello.com/1/members/me/boards?key=$apiKey&token=$token',
    );
    final boardsResp = await http.get(boardsUrl);
    if (boardsResp.statusCode != 200) return 'Error fetching boards.';

    final boards = jsonDecode(boardsResp.body) as List;
    final board = boards.firstWhere(
      (b) => (b['name'] as String).toLowerCase() == boardName.toLowerCase(),
      orElse: () => null,
    );
    if (board == null) return 'Board "$boardName" not found.';

    // 2. Find List
    final listsUrl = Uri.parse(
      'https://api.trello.com/1/boards/${board['id']}/lists?key=$apiKey&token=$token',
    );
    final listsResp = await http.get(listsUrl);
    if (listsResp.statusCode != 200) return 'Error fetching lists.';

    final lists = jsonDecode(listsResp.body) as List;
    final list = lists.firstWhere(
      (l) => (l['name'] as String).toLowerCase() == listName.toLowerCase(),
      orElse: () => null,
    );
    if (list == null) {
      return 'List "$listName" not found on board "$boardName".';
    }

    // 3. Create Card
    final cardUrl = Uri.parse(
      'https://api.trello.com/1/cards?idList=${list['id']}&key=$apiKey&token=$token&name=$cardName',
    );
    final cardResp = await http.post(cardUrl);

    if (cardResp.statusCode != 200) return 'Error creating card.';

    final card = jsonDecode(cardResp.body);
    return 'Card created: ${card['shortUrl']}';
  }
}
