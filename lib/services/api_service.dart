import 'package:dio/dio.dart';
import '../models/todo.dart';
import '../models/base_response.dart';
import '../models/base_error.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<BaseResponse<List<Todo>>> getTodos({int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '${Constants.baseUrl}/todos',
        queryParameters: {'limit': limit, 'skip': offset}
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> todos = response.data['todos'];
        return BaseResponse.success(
          todos.map((todo) => Todo.fromJson(todo)).toList()
        );
      }
      
      throw BaseError(
        message: 'Failed to fetch todos',
        statusCode: response.statusCode
      );
    } on DioException catch (e) {
      throw BaseError(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        originalError: e
      );
    } catch (e) {
      throw BaseError(
        message: 'An unexpected error occurred',
        originalError: e
      );
    }
  }

  Future<BaseResponse<Todo>> getTodo(int id) async {
    try {
      final response = await _dio.get('${Constants.baseUrl}/todos/$id');
      
      if (response.statusCode == 200) {
        return BaseResponse.success(Todo.fromJson(response.data));
      }
      
      throw BaseError(
        message: 'Failed to fetch todo',
        statusCode: response.statusCode
      );
    } on DioException catch (e) {
      throw BaseError(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        originalError: e
      );
    } catch (e) {
      throw BaseError(
        message: 'An unexpected error occurred',
        originalError: e
      );
    }
  }

  Future<BaseResponse<Todo>> addTodo(Todo todo) async {
    try {
      final response = await _dio.post(
        '${Constants.baseUrl}/todos/add',
        data: todo.toJson(),
      );
      
      if (response.statusCode == 200) {
        return BaseResponse.success(Todo.fromJson(response.data));
      }
      
      throw BaseError(
        message: 'Failed to add todo',
        statusCode: response.statusCode
      );
    } on DioException catch (e) {
      throw BaseError(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        originalError: e
      );
    } catch (e) {
      throw BaseError(
        message: 'An unexpected error occurred',
        originalError: e
      );
    }
  }

  Future<BaseResponse<Todo>> updateTodoCompletedStatus(Todo todo) async {
    try {
      final response = await _dio.put(
        '${Constants.baseUrl}/todos/${todo.id}',
        data: todo.toJson(),
      );
      
      if (response.statusCode == 200) {
        return BaseResponse.success(Todo.fromJson(response.data));
      }
      
      throw BaseError(
        message: 'Failed to update todo',
        statusCode: response.statusCode
      );
    } on DioException catch (e) {
      throw BaseError(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        originalError: e
      );
    } catch (e) {
      throw BaseError(
        message: 'An unexpected error occurred',
        originalError: e
      );
    }
  }

  Future<BaseResponse<void>> deleteTodo(int id) async {
    try {
      final response = await _dio.delete('${Constants.baseUrl}/todos/$id');
      
      if (response.statusCode == 200) {
        return BaseResponse.success(null);
      }
      
      throw BaseError(
        message: 'Failed to delete todo',
        statusCode: response.statusCode
      );
    } on DioException catch (e) {
      throw BaseError(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        originalError: e
      );
    } catch (e) {
      throw BaseError(
        message: 'An unexpected error occurred',
        originalError: e
      );
    }
  }
}
