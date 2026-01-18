import 'package:github/github.dart';
import 'package:serverpod/serverpod.dart';

/// GitHub integration service using direct API.
class GitHubService {
  /// Creates a GitHub client with user's token.
  static GitHub _createClient(String token) {
    return GitHub(auth: Authentication.withToken(token));
  }

  /// Lists user's repositories.
  static Future<List<Map<String, dynamic>>> listRepositories(
    Session session,
    String token,
  ) async {
    try {
      final github = _createClient(token);
      final repos = await github.repositories.listRepositories().toList();

      session.log('Found ${repos.length} GitHub repositories');

      return repos
          .map(
            (repo) => {
              'name': repo.name,
              'full_name': repo.fullName,
              'description': repo.description,
              'url': repo.htmlUrl,
              'language': repo.language,
              'stars': repo.stargazersCount,
              'forks': repo.forksCount,
              'private': repo.isPrivate,
            },
          )
          .toList();
    } catch (e, stackTrace) {
      session.log(
        'Error listing GitHub repositories: $e',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Gets repository issues.
  static Future<List<Map<String, dynamic>>> getIssues(
    Session session,
    String token,
    String owner,
    String repo,
  ) async {
    try {
      final github = _createClient(token);
      final issues = await github.issues
          .listByRepo(RepositorySlug(owner, repo))
          .toList();

      session.log('Found ${issues.length} issues in $owner/$repo');

      return issues
          .map(
            (issue) => {
              'number': issue.number,
              'title': issue.title,
              'state': issue.state,
              'body': issue.body,
              'url': issue.htmlUrl,
              'created_at': issue.createdAt?.toIso8601String(),
              'labels': issue.labels.map((l) => l.name).toList(),
            },
          )
          .toList();
    } catch (e) {
      session.log('Error listing issues: $e', level: LogLevel.warning);
      return [];
    }
  }
}
