import 'package:flutter_riverpod/flutter_riverpod.dart';

final retryQueueProvider =
    StateNotifierProvider<RetryQueueNotifier, List<RetryRequest>>((ref) {
  return RetryQueueNotifier();
});

class RetryRequest {
  final Future<void> Function() request;
  final DateTime timestamp;

  RetryRequest({
    required this.request,
    required this.timestamp,
  });
}

class RetryQueueNotifier extends StateNotifier<List<RetryRequest>> {
  RetryQueueNotifier() : super([]);

  void addFailedRequest(Future<void> Function() request) {
    state = [
      ...state,
      RetryRequest(
        request: request,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> retryFailedRequests() async {
    if (state.isEmpty) return;

    final requests = [...state];
    state = [];

    for (final request in requests) {
      try {
        await request.request();
      } catch (e) {
        state = [...state, request];
      }
    }
  }
}
