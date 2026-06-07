import 'package:flutter/foundation.dart';

class BluetoothService {
  bool _isEnabled = false;
  String _status = 'Unknown';

  bool get isEnabled => _isEnabled;
  String get status => _status;

  Future<void> initialize() async {
    try {
      _status = 'Initialized';
      debugPrint('Bluetooth Service initialized');
    } catch (e) {
      debugPrint('Bluetooth init error: $e');
    }
  }

  Future<bool> turnOn() async {
    try {
      _isEnabled = true;
      _status = 'Enabled';
      debugPrint('Bluetooth turned ON');
      return true;
    } catch (e) {
      debugPrint('Bluetooth turn on error: $e');
      return false;
    }
  }

  Future<bool> turnOff() async {
    try {
      _isEnabled = false;
      _status = 'Disabled';
      debugPrint('Bluetooth turned OFF');
      return true;
    } catch (e) {
      debugPrint('Bluetooth turn off error: $e');
      return false;
    }
  }

  Future<bool> toggle() async {
    if (_isEnabled) {
      return await turnOff();
    } else {
      return await turnOn();
    }
  }

  void dispose() {
    debugPrint('Bluetooth Service disposed');
  }
}
