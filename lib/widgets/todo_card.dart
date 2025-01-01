import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleComplete;
  final VoidCallback onTap;

  const TodoCard({
    Key? key,
    required this.todo,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          onTap: onTap,
          title: Text(todo.todo!, style: const TextStyle(fontSize: 18)),
          trailing: Checkbox(
            value: todo.completed,
            onChanged: onToggleComplete,
          ),
        ),
      ),
    );
  }
}
