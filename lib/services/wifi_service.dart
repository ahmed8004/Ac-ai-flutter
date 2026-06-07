import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WiFiService {
  final Connectivity _connectivity = Connectivity();
  bool _isEnabled = false;
  String _connectionType = 'Unknown';

  bool get isEnabled => _isEnabled;
  String get connectionType => _connectionType;

  Future<void> initialize() async {
    try {
      await _checkConnection();
    } catch (e) {
      debugPrint('WiFi init error: $e');
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('WiFi check error: $e');
      return false;
    }
  }

  Future<String> getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.wifi) {
        _connectionType = 'WiFi Connected';
        return _connectionType;
      } else if (result == ConnectivityResult.mobile) {
        _connectionType = 'Mobile Data';
        return _connectionType;
      } else if (result == ConnectivityResult.ethernet) {
        _connectionType = 'Ethernet';
        return _connectionType;
      } else {
        _connectionType = 'No Connection';
        return _connectionType;
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isEnabled = result == ConnectivityResult.wifi;
  }

  Future<bool> turnOn() async {
    try {
      _isEnabled = true;
      debugPrint('WiFi turn on requested');
      return true;
    } catch (e) {
      debugPrint('WiFi turn on error: $e');
      return false;
    }
  }

  Future<bool> turnOff() async {
    try {
      _isEnabled = false;
      debugPrint('WiFi turn off requested');
      return true;
    } catch (e) {
      debugPrint('WiFi turn off error: $e');
      return false;
    }
  }

  void dispose() {
    debugPrint('WiFi Service disposed');
  }
}
