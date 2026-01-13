import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class TaskEndpoint extends Endpoint {
  Future<Task> addTask(Session session, Task task) async {
    task.createdAt = DateTime.now();
    await Task.db.insertRow(session, task);
    return task;
  }

  Future<List<Task>> listTasks(Session session) async {
    return await Task.db.find(
      session,
      orderBy: (t) => t.createdAt,
    );
  }

  Future<Task> updateTask(Session session, Task task) async {
    await Task.db.updateRow(session, task);
    return task;
  }

  Future<void> deleteTask(Session session, Task task) async {
    await Task.db.deleteRow(session, task);
  }
}
