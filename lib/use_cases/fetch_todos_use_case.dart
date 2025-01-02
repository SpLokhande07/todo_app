import 'package:todo/models/base_response.dart';

import '../models/todo.dart';
import '../services/api_service.dart';

class FetchTodosUseCase {
  final ApiService _apiService;

  FetchTodosUseCase(this._apiService);

  Future<BaseResponse<List<Todo>>> execute(
      {int limit = 10, int offset = 0}) async {
    try {
      return await _apiService.getTodos(limit: limit, offset: offset);
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }
}
