import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _isConnected = true;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    checkConnectivity();
  }

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool get isConnected => _isConnected;

  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
    _controller.add(_isConnected);
  }

  void dispose() {
    _controller.close();
  }
}
