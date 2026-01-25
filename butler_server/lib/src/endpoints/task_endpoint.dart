import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class TaskEndpoint extends Endpoint {
  Future<Task> addTask(Session session, Task task) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) throw Exception('User not authenticated');

    task.createdAt = DateTime.now();
    task.userId = userId;
    await Task.db.insertRow(session, task);
    return task;
  }

  Future<List<Task>> addTasks(Session session, List<Task> tasks) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) throw Exception('User not authenticated');

    for (var task in tasks) {
      task.createdAt = DateTime.now();
      task.userId = userId;
    }
    await Task.db.insert(session, tasks);
    return tasks;
  }

  Future<List<Task>> listTasks(Session session) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) return [];

    return await Task.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
    );
  }

  Future<Task> updateTask(Session session, Task task) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) throw Exception('User not authenticated');
    if (task.userId != userId) throw Exception('Unauthorized');

    await Task.db.updateRow(session, task);
    return task;
  }

  Future<void> deleteTask(Session session, Task task) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) throw Exception('User not authenticated');
    if (task.userId != userId) throw Exception('Unauthorized');

    await Task.db.deleteRow(session, task);
  }
}
