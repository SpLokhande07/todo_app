import 'package:todo/models/todo.dart';
import 'package:todo/utils/enums.dart';
import 'package:equatable/equatable.dart';

class TodoProviderModel extends Equatable {
  List<Todo>? todos = [];
  List<Todo>? filteredTodos = [];
  int offset;
  Status? status;

  TodoProviderModel.initial()
      : status = Status.initial,
        offset = 0;

  TodoProviderModel({
    this.todos,
    this.filteredTodos,
    this.status,
    this.offset = 0,
  });

  TodoProviderModel copyWith({
    List<Todo>? todos,
    List<Todo>? filteredTodos,
    Status? status,
    int? offset,
  }) {
    return TodoProviderModel(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      status: status ?? this.status,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
        todos,
        status,
        offset,
      ];
}
