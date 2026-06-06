import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BluetoothService {
  static const MethodChannel _channel = MethodChannel('ac.ai/bluetooth');
  bool _isOn = false;

  bool get isOn => _isOn;

  Future<bool> turnOn() async {
    try {
      await _channel.invokeMethod('turnOn');
      _isOn = true;
      debugPrint('Bluetooth: ON');
      return true;
    } on PlatformException catch (e) {
      debugPrint('Bluetooth ON error: ${e.message}');
      return false;
    }
  }

  Future<bool> turnOff() async {
    try {
      await _channel.invokeMethod('turnOff');
      _isOn = false;
      debugPrint('Bluetooth: OFF');
      return true;
    } on PlatformException catch (e) {
      debugPrint('Bluetooth OFF error: ${e.message}');
      return false;
    }
  }

  Future<bool> toggle() async {
    if (_isOn) {
      return await turnOff();
    } else {
      return await turnOn();
    }
  }

  Future<bool> isConnected() async {
    try {
      final bool? connected = await _channel.invokeMethod('isConnected');
      return connected ?? false;
    } on PlatformException catch (e) {
      debugPrint('Bluetooth connection check error: ${e.message}');
      return false;
    }
  }

  void dispose() {
    debugPrint('Bluetooth Service disposed');
  }
}
