import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/retry_queue_provider.dart';
import '../services/connectivity_service.dart';

class ConnectivityWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<ConnectivityWrapper> createState() =>
      _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends ConsumerState<ConnectivityWrapper> {
  @override
  void initState() {
    super.initState();
    final connectivityService = ref.read(connectivityServiceProvider);
    connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        ref.read(retryQueueProvider.notifier).retryFailedRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
