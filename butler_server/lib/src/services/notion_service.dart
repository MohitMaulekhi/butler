import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class NotionService {
  final Session session;
  final String integrationToken;

  NotionService(this.session, this.integrationToken);

  /// Create a new page in Notion
  Future<String> createPage({
    required String title,
    required String content,
  }) async {
    // 1. Search for a parent page or database to add to (Defaults to workspace root page search)
    // For simplicity, we search for a page named "Butler Notes" or similar, or just fail if no suitable parent.
    // However, to keep it actionable without complex user config, we can ask user for "parent_id" or
    // we can search for *any* page user has access to and append there? No, that's messy.
    // Better: Search for a database or page matching the user's intent?
    // Or: Just create a page at the top level? Notion API requires a parent.
    // Strategy: Search for a page named "Butler" to use as parent. If not found, fail or use the first available page.

    // Let's implement a 'search' helper first.

    // For now, let's try to find a parent page.
    final parentId = await _findParentId();
    if (parentId == null) {
      return "Error: Could not find a page to add to. Please give the integration access to at least one page.";
    }

    final url = Uri.parse('https://api.notion.com/v1/pages');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $integrationToken',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'parent': {'page_id': parentId},
        'properties': {
          'title': [
            {
              'text': {
                'content': title,
              },
            },
          ],
        },
        'children': [
          {
            'object': 'block',
            'type': 'paragraph',
            'paragraph': {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {
                    'content': content,
                  },
                },
              ],
            },
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      session.log('Notion create error: ${response.body}');
      return 'Error creating page: ${response.statusCode} - ${response.body}';
    }

    final data = jsonDecode(response.body);
    return 'Successfully created Notion page: ${data['url']}';
  }

  /// Search for a parent page (just grabs the first search result for now)
  Future<String?> _findParentId() async {
    final url = Uri.parse('https://api.notion.com/v1/search');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $integrationToken',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': '', // Empty query to list recent/all
        'filter': {
          'value': 'page',
          'property': 'object',
        },
        'page_size': 1,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      if (results.isNotEmpty) {
        return results[0]['id'];
      }
    }
    return null;
  }

  Future<String> search(String query) async {
    final url = Uri.parse('https://api.notion.com/v1/search');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $integrationToken',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'page_size': 5,
      }),
    );

    if (response.statusCode != 200) {
      return 'Error searching Notion: ${response.statusCode}';
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List;

    if (results.isEmpty) return 'No results found.';

    final buffer = StringBuffer();
    for (var r in results) {
      final type = r['object']; // page or database
      if (type == 'page') {
        // Extract title (tricky object structure in Notion)
        // Usually properties -> title -> title[0] -> plain_text
        // But keys vary based on database schema.
        // fallback to url or id
        final url = r['url'];
        buffer.writeln('- Page: $url');
      } else {
        buffer.writeln('- ${r['url']}');
      }
    }
    return buffer.toString();
  }
}
