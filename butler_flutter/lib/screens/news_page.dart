import 'dart:convert';
import 'package:butler_flutter/main.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final jsonStr = await client.news.getTopHeadlines(country: 'us', pageSize: 50);
      final data = jsonDecode(jsonStr);
      
      if (data['status'] == 'ok') {
        setState(() {
          _articles = data['articles'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load news';
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
      return const Center(child: Text('No news available'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: ListView.builder(
          itemCount: _articles!.length,
          itemBuilder: (context, index) {
            final article = _articles![index];
            final title = article['title'] ?? 'No Title';
            final description = article['description'];
            final imageUrl = article['urlToImage'];
            final source = article['source']?['name'];
            final url = article['url'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: url != null ? () => _launchUrl(url) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (source != null)
                            Text(
                              source,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
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
          },
        ),
      ),
    );
  }
}
