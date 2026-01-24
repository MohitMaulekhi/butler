import 'package:googleapis/tasks/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class GoogleTasksService {
  // Reuses OAuth logic conceptually, similar to Calendar.
  // For simplicity here, we assume we receive an Access Token passed from client (Google Sign In).

  final Session session;

  GoogleTasksService(this.session);

  Future<String> listTaskLists(String accessToken) async {
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().add(Duration(hours: 1)).toUtc(),
        ),
        null, // No refresh token needed for simple one-off call
        [TasksApi.tasksReadonlyScope],
      ),
    );

    final api = TasksApi(client);
    final lists = await api.tasklists.list();

    if (lists.items == null || lists.items!.isEmpty) {
      return 'No task lists found.';
    }

    return lists.items!.map((l) => '- ${l.title} (ID: ${l.id})').join('\n');
  }

  Future<String> addTask(
    String accessToken,
    String title, {
    String? listId,
  }) async {
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().add(Duration(hours: 1)).toUtc(),
        ),
        null,
        [TasksApi.tasksScope],
      ),
    );

    final api = TasksApi(client);
    final targetList = listId ?? '@default';

    final task = Task(title: title);
    final result = await api.tasks.insert(task, targetList);

    return 'Task created: ${result.title}';
  }
}
