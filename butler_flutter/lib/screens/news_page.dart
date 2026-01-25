import 'dart:convert';
import 'package:butler_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic>? _articles;
  bool _isLoading = true;
  String? _error;
  String _currentCountry = 'us';

  @override
  void initState() {
    super.initState();
    _initNews();
  }

  Future<void> _initNews() async {
    // 1. Detect Country from user's browser using CORS-friendly API
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final countryCode = data['country_code']?.toString().toLowerCase();
        if (mounted && countryCode != null && countryCode.isNotEmpty) {
          _currentCountry = countryCode;
        }
      }
    } catch (e) {
      debugPrint('Failed to detect country: $e');
    }

    // 2. Load News
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final jsonStr = await client.news.getTopHeadlines(
        country: _currentCountry,
        pageSize: 10,
      );
      final data = jsonDecode(jsonStr);

      // Handle NewsData.io format (uses 'results' and 'status: success')
      // Also handle NewsAPI format (uses 'articles' and 'status: ok')
      final status = data['status'];

      if (status == 'error') {
        setState(() {
          _error =
              data['message'] ??
              data['results']?['message'] ??
              'Failed to load news';
          _isLoading = false;
        });
        return;
      }

      // NewsData.io uses 'results', NewsAPI uses 'articles'
      List<dynamic>? articles = data['results'] ?? data['articles'];

      if (articles != null) {
        // Normalize NewsData.io format to match what UI expects
        if (data['results'] != null) {
          articles = articles
              .map(
                (a) => <String, dynamic>{
                  'title': a['title'],
                  'description': a['description'],
                  'urlToImage': a['image_url'], // NewsData.io uses 'image_url'
                  'url': a['link'], // NewsData.io uses 'link'
                  'source': <String, dynamic>{
                    'name': a['source_name'] ?? a['source_id'] ?? 'Unknown',
                  },
                },
              )
              .toList();
        }

        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No news available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNews,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_articles == null || _articles!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No news available for $_currentCountry'),
            const SizedBox(height: 8),
            const Text('Try refreshing or check server keys.'),
          ],
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: isTablet
            ? GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _articles!.length,
                itemBuilder: (context, index) {
                  return _buildArticleCard(context, _articles![index]);
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _articles!.length,
                itemBuilder: (context, index) {
                  return _buildArticleCard(
                    context,
                    _articles![index],
                    isList: true,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    Map<String, dynamic> article, {
    bool isList = false,
  }) {
    final title = article['title'] ?? 'No Title';
    final description = article['description'];
    final imageUrl = article['urlToImage'];
    final source = article['source']?['name'];
    final url = article['url'];

    return Card(
      margin: isList
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: url != null ? () => _launchUrl(url) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                height: isList ? 200 : 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: isList ? 200 : 140,
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (source != null)
                    Text(
                      source,
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: isList ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
