import 'package:todo/models/todo_provider_model.dart';
import 'package:todo/utils/enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../use_cases/fetch_todos_use_case.dart';
import '../models/base_error.dart';
import 'retry_queue_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final fetchTodosUseCaseProvider = Provider<FetchTodosUseCase>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return FetchTodosUseCase(apiService);
});
final todoProvider =
    StateNotifierProvider<TodoNotifier, TodoProviderModel>((ref) {
  return TodoNotifier(ref);
});

class TodoNotifier extends StateNotifier<TodoProviderModel> {
  final Ref _ref;
  final ApiService _apiService;
  bool _hasReachedEnd = false;
  bool _isFetching = false;

  TodoNotifier(this._ref)
      : _apiService = _ref.read(apiServiceProvider),
        super(TodoProviderModel());

  Future<void> updateTodoStatus(Todo todo) async {
    try {
      final response = await _apiService.updateTodoCompletedStatus(todo);
      if (response.success) {
        state = state.copyWith(
          todos: state.todos
              ?.map((t) => t.id == todo.id ? response.data! : t)
              .toList(),
          filteredTodos: state.filteredTodos
              ?.map((t) => t.id == todo.id ? response.data! : t)
              .toList(),
        );
      }
    } on BaseError catch (e) {
      _ref.read(retryQueueProvider.notifier).addFailedRequest(
            () => updateTodoStatus(todo),
          );
      rethrow;
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final response = await _apiService.addTodo(todo);
      if (response.success) {
        state = state.copyWith(
          todos: [response.data!, ...?state.todos],
          filteredTodos: [response.data!, ...?state.filteredTodos],
        );
      }
    } on BaseError catch (e) {
      _ref.read(retryQueueProvider.notifier).addFailedRequest(
            () => addTodo(todo),
          );
      rethrow;
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await _apiService.deleteTodo(id);
      if (response.success) {
        state = state.copyWith(
          todos: state.todos?.where((todo) => todo.id != id).toList(),
          filteredTodos:
              state.filteredTodos?.where((todo) => todo.id != id).toList(),
        );
      }
    } on BaseError catch (e) {
      _ref.read(retryQueueProvider.notifier).addFailedRequest(
            () => deleteTodo(id),
          );
      rethrow;
    }
  }

  Future<void> fetchTodos() async {
    if (_isFetching || _hasReachedEnd) return;

    _isFetching = true;
    state = state.copyWith(status: Status.loading);

    try {
      final response =
          await _apiService.getTodos(offset: state.offset, limit: 20);

      if (response.success) {
        final newTodos = response.data ?? [];

        if (newTodos.isEmpty) {
          _hasReachedEnd = true;
          return;
        }

        // Check for duplicates
        final existingIds = state.todos?.map((t) => t.id).toSet() ?? {};
        final uniqueNewTodos =
            newTodos.where((todo) => !existingIds.contains(todo.id)).toList();

        if (uniqueNewTodos.isEmpty) {
          _hasReachedEnd = true;
          return;
        }

        state = state.copyWith(
          status: Status.success,
          todos: [...?state.todos, ...uniqueNewTodos],
          filteredTodos: [...?state.filteredTodos, ...uniqueNewTodos],
          offset: state.offset + uniqueNewTodos.length,
        );
      }
    } on BaseError catch (e) {
      state = state.copyWith(status: Status.failure, error: e.message);
      _ref.read(retryQueueProvider.notifier).addFailedRequest(
            () => fetchTodos(),
          );
    } finally {
      _isFetching = false;
    }
  }

  void resetPagination() {
    _hasReachedEnd = false;
    state = state.copyWith(
      todos: [],
      filteredTodos: [],
      offset: 0,
      status: Status.initial,
    );
  }

  void searchTodos(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredTodos: state.todos);
      return;
    }

    final filteredTodos = state.todos?.where((todo) {
      return todo.todo?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    state = state.copyWith(filteredTodos: filteredTodos);
  }
}
