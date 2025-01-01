import 'package:dio/dio.dart';
import '../models/todo.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Todo>> getTodos({int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get('${Constants.baseUrl}/todos',
          queryParameters: {'limit': limit, 'skip': offset});
      final List<dynamic> todos = response.data['todos'];
      return todos.map((todo) => Todo.fromJson(todo)).toList();
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }

  Future<Todo> getTodo(int id) async {
    try {
      final response = await _dio.get('${Constants.baseUrl}/todos/$id');
      return Todo.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch todo: $e');
    }
  }

  Future<Todo> addTodo(Todo todo) async {
    try {
      final response = await _dio.post(
        '${Constants.baseUrl}/todos/add',
        data: {
          'todo': todo.todo,
          'completed': todo.completed,
          'userId': todo.userId,
        },
      );
      return Todo.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  Future<Response<dynamic>> updateTodoCompletedStatus(Todo todo) async {
    try {
      return await _dio.put(
        '${Constants.baseUrl}/todos/${todo.id}',
        data: {'completed': todo.completed, "todo": todo.todo},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _dio.delete('${Constants.baseUrl}/todos/$id');
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}
