import 'package:dio/dio.dart';
import '../models/todo.dart';
import '../models/base_response.dart';
import '../models/base_error.dart';
import '../utils/constants.dart';
import '../utils/future_handler.dart';
import 'api_interceptor.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      sendTimeout: const Duration(seconds: 3),
    ));

    _dio.interceptors.add(ApiInterceptor());
  }
  Future<BaseResponse<List<Todo>>> getTodos(
      {int limit = 10, int offset = 0}) async {
    return FutureHandler.handle(() async {
      final response = await _dio.get(
        '/todos',
        queryParameters: {'limit': limit, 'skip': offset},
      );

      if (response.statusCode == 200) {
        final List<dynamic> todos = response.data['todos'];
        return BaseResponse.success(
          todos.map((todo) => Todo.fromJson(todo)).toList(),
        );
      }

      throw BaseError(
        message: 'Failed to fetch todos',
        statusCode: response.statusCode,
      );
    });
  }

  Future<BaseResponse<Todo>> getTodo(int id) async {
    return FutureHandler.handle(() async {
      final response = await _dio.get('/todos/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success(Todo.fromJson(response.data));
      }

      throw BaseError(
        message: 'Failed to fetch todo',
        statusCode: response.statusCode,
      );
    });
  }

  Future<BaseResponse<Todo>> updateTodoCompletedStatus(Todo todo) async {
    return FutureHandler.handle(() async {
      final response = await _dio.put(
        '/todos/${todo.id}',
        data: todo.toJson(),
      );

      if (response.statusCode == 200) {
        return BaseResponse.success(Todo.fromJson(response.data));
      }

      throw BaseError(
        message: 'Failed to update todo',
        statusCode: response.statusCode,
      );
    });
  }

  Future<BaseResponse<Todo>> addTodo(Todo todo) async {
    return FutureHandler.handle(() async {
      final response = await _dio.post(
        '/todos/add',
        data: todo.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BaseResponse.success(Todo.fromJson(response.data));
      }

      throw BaseError(
        message: 'Failed to add todo',
        statusCode: response.statusCode,
      );
    });
  }

  Future<BaseResponse<void>> deleteTodo(int id) async {
    return FutureHandler.handle(() async {
      final response = await _dio.delete('/todos/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success(null);
      }

      throw BaseError(
        message: 'Failed to delete todo',
        statusCode: response.statusCode,
      );
    });
  }
}
