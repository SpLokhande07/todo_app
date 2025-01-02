import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int? id;
  final String? todo;
  final bool? completed;
  final int? userId;

  Todo({
    this.id,
    this.todo,
    this.completed = false,
    this.userId,
  });

  Todo copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? 0,
      todo: json['todo'] ?? '',
      completed: json['completed'] ?? false,
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [id, todo, completed, userId];
}
