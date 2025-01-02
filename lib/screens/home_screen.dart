import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../models/todo_provider_model.dart';
import '../utils/enums.dart';
import '../widgets/todo_card.dart';
import '../widgets/error_dialog.dart';
import 'post_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _logger = Logger();
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _logger.i('Fetching todos...');
        _fetchTodos();
      },
    );
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchTodos() async {
    try {
      await ref.read(todoProvider.notifier).fetchTodos();
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          message: e.toString(),
          onRetry: _fetchTodos,
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchTodos();
    }
  }

  Future<void> _refreshTodos() async {
    ref.read(todoProvider.notifier).resetPagination();
    await _fetchTodos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search todos...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(todoProvider.notifier).searchTodos(value);
                },
              )
            : const Text('Todos'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  ref.read(todoProvider.notifier).searchTodos('');
                }
              });
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final todoState = ref.watch(todoProvider);

          if (todoState.status == Status.loading && todoState.todos == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (todoState.status == Status.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(todoState.error ?? 'An error occurred'),
                  ElevatedButton(
                    onPressed: _fetchTodos,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final todos = todoState.filteredTodos ?? [];

          return RefreshIndicator(
            onRefresh: _refreshTodos,
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  todos.length + (todoState.status == Status.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == todos.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todo = todos[index];
                return TodoCard(
                  todo: todo,
                  onToggleComplete: (value) async {
                    try {
                      final updatedTodo = Todo(
                        id: todo.id,
                        todo: todo.todo,
                        completed: value,
                        userId: todo.userId,
                      );
                      await ref
                          .read(todoProvider.notifier)
                          .updateTodoStatus(updatedTodo);
                    } catch (e) {
                      if (mounted) {
                        ErrorDialog.show(
                          context,
                          message: e.toString(),
                          onRetry: () => ref
                              .read(todoProvider.notifier)
                              .updateTodoStatus(todo),
                        );
                      }
                    }
                  },
                  onDelete: () async {
                    try {
                      await ref
                          .read(todoProvider.notifier)
                          .deleteTodo(todo.id!);
                    } catch (e) {
                      if (mounted) {
                        ErrorDialog.show(
                          context,
                          message: e.toString(),
                          onRetry: () => ref
                              .read(todoProvider.notifier)
                              .deleteTodo(todo.id!),
                        );
                      }
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoFormScreen(todo: todo),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TodoFormScreen(),
            ),
          );

          if (result != null && result is Todo) {
            try {
              await ref.read(todoProvider.notifier).addTodo(result);
            } catch (e) {
              if (mounted) {
                ErrorDialog.show(
                  context,
                  message: e.toString(),
                  onRetry: () =>
                      ref.read(todoProvider.notifier).addTodo(result),
                );
              }
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
