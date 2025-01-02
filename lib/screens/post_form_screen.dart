import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../services/api_service.dart';
import '../widgets/error_dialog.dart';

class TodoFormScreen extends ConsumerStatefulWidget {
  final Todo? todo;
  const TodoFormScreen({super.key, this.todo});

  @override
  ConsumerState<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends ConsumerState<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _todoController = TextEditingController();

  String _title = '';
  String _todo = '';
  bool _completed = false;
  final int _userId = 5; // Default user ID
  bool _isLoading = false;

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  initState() {
    super.initState();
    if (widget.todo != null) {
      _title = widget.todo!.todo!;
      _todo = widget.todo!.todo!;
      _completed = widget.todo!.completed!;
      _todoController.text = widget.todo!.todo!;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        _executeFunction();
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            message: e.toString(),
            onRetry: () {
              _executeFunction();
            },
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  _executeFunction() {
    if (widget.todo != null) {
      ref.read(todoProvider.notifier).updateTodoStatus(Todo(
          id: widget.todo!.id,
          todo: _todoController.text,
          completed: _completed,
          userId: _userId));
    } else {
      ref.read(todoProvider.notifier).addTodo(Todo(
          todo: _todoController.text, completed: _completed, userId: _userId));
    }
    Fluttertoast.showToast(
      msg: widget.todo != null
          ? "Todo updated successfully!"
          : "Todo added successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo != null ? 'Edit Todo' : 'Add Todo'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _todoController,
                decoration: const InputDecoration(
                  labelText: 'Todo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a todo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _completed,
                    onChanged: (value) {
                      setState(() => _completed = value!);
                    },
                  ),
                  const Text('Completed'),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.teal,
                ),
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.todo != null ? 'Update Todo' : 'Add Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
