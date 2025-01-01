import 'package:todo/models/todo_provider_model.dart';
import 'package:todo/utils/enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../use_cases/fetch_todos_use_case.dart';

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
  final ApiService _apiService;
  final FetchTodosUseCase _fetchTodosUseCase;

  TodoNotifier(Ref ref)
      : _apiService = ref.read(apiServiceProvider),
        _fetchTodosUseCase = ref.read(fetchTodosUseCaseProvider),
        super(TodoProviderModel());

  Future<void> updateTodoStatus(Todo todo) async {
    try {
      Response response = await _apiService.updateTodoCompletedStatus(todo);
      final todos = state.todos!;
      final index = todos.indexWhere((todoVal) => todoVal.id == todo.id);
      final filteredTodos = state.filteredTodos!;
      if (index != -1) {
        filteredTodos[index] = Todo.fromJson(response.data);
        todos[index] = Todo.fromJson(response.data);
      }
      state = state.copyWith(todos: todos, filteredTodos: filteredTodos);
    } catch (e) {
      state = state.copyWith(
        status: Status.failure,
      );
    }
  }

  Future<void> deleteTodoById(int id) async {
    try {
      await _apiService.deleteTodo(id);
      List<Todo>? todos = state.todos?.where((todo) => todo.id != id).toList();
      List<Todo>? filteredTodos =
          state.filteredTodos?.where((todo) => todo.id != id).toList();
      state = state.copyWith(
        todos: todos,
        filteredTodos: filteredTodos,
      );
    } catch (e) {
      state = state.copyWith(
        status: Status.failure,
      );
    }
  }

  Future<void> addTodo(String todo, bool completed, int userId) async {
    try {
      final newTodo = await _apiService.addTodo(Todo(
        todo: todo,
        completed: completed,
        userId: userId,
      ));
      state = state.copyWith(
          todos: [newTodo, ...state.todos!],
          filteredTodos: [newTodo, ...state.filteredTodos!]);
    } catch (e) {
      state = state.copyWith(
        status: Status.failure,
      );
    }
  }

  Future fetchTodos() async {
    state = state.copyWith(status: Status.loading);
    try {
      final todos =
          await _fetchTodosUseCase.execute(offset: state.offset, limit: 20);
      state = state.copyWith(
        status: Status.success,
        todos: [...state.todos ?? [], ...todos],
        filteredTodos: [...state.filteredTodos ?? [], ...todos],
        offset: state.offset + todos.length,
      );
    } catch (e) {
      state = state.copyWith(
        status: Status.failure,
      );
    }
  }

  searchTodos(String query) async {
    state = state.copyWith(status: Status.loading);
    try {
      final todos = state.todos!;
      final filteredTodos = query.length == 0
          ? todos
          : todos.where((todo) => todo.todo!.contains(query)).toList();

      state = state.copyWith(
        status: Status.success,
        filteredTodos: filteredTodos,
      );
    } catch (e) {
      state = state.copyWith(
        status: Status.failure,
      );
    }
  }
}
