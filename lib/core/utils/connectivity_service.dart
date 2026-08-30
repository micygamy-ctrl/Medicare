import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance =
      ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  void initialize() {
    _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((result) =>
          result != ConnectivityResult.none);
      if (_isConnected != connected) {
        _isConnected = connected;
        _connectionController.add(connected);
      }
    });

    // تحقق من الحالة الحالية
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected = results.any((result) =>
        result != ConnectivityResult.none);
    _connectionController.add(_isConnected);
  }

  void dispose() {
    _connectionController.close();
  }
}