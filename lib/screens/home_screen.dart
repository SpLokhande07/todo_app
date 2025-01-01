import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../services/api_service.dart';
import '../utils/enums.dart';
import 'post_form_screen.dart';
import '../widgets/todo_card.dart';
import 'dart:async';
import 'package:logger/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _logger.i('Fetching todos...');
        ref.read(todoProvider.notifier).fetchTodos();
      },
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 400 &&
          !_scrollController.position.outOfRange) {
        _logger.i('Fetching todos...');
        ref.read(todoProvider.notifier).fetchTodos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search todos...',
                  border: InputBorder.none,
                ),
                onChanged: (value) =>
                    ref.read(todoProvider.notifier).searchTodos(value),
              )
            : const Text('Todo List', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                _logger.i('Search toggled: $_isSearchVisible');
                if (!_isSearchVisible) {
                  _searchController.clear();
                  ref.read(todoProvider.notifier).searchTodos('');
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, _) {
            final todosAsyncValue = ref.watch(todoProvider.notifier);
            final todoPro = ref.watch(todoProvider);
            if ((todoPro.status == Status.loading &&
                    todoPro.todos != null &&
                    todoPro.todos!.isEmpty) ||
                todoPro.todos == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (todoPro.status == Status.failure) {
              return const Center(child: Text('Failed to fetch todos'));
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: todoPro.filteredTodos!.length + 1,
              itemBuilder: (context, index) {
                if (index == todoPro.filteredTodos!.length) {
                  if (todoPro.offset < todoPro.todos!.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                }
                final todo = todoPro.filteredTodos![index];
                return TodoCard(
                  todo: todo,
                  onDelete: () => todosAsyncValue.deleteTodoById(todo.id!),
                  onToggleComplete: (value) =>
                      todosAsyncValue.updateTodoStatus(todo),
                  onTap: () {
                    _logger.i('Navigating to TodoFormScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoFormScreen(todo: todo),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          _logger.i('Navigating to TodoFormScreen');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TodoFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
