import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BrightnessService {
  static const MethodChannel _channel = MethodChannel('ac.ai/brightness');
  double _currentBrightness = 0.5;
  bool _isAvailable = true;

  double get currentBrightness => _currentBrightness;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    try {
      final brightness = await _channel.invokeMethod('getBrightness');
      _currentBrightness = (brightness ?? 50) / 100.0;
      debugPrint('Brightness Service initialized: $_currentBrightness');
    } catch (e) {
      debugPrint('Brightness init error (using default): $e');
      _isAvailable = false;
    }
  }

  Future<void> setBrightness(double value) async {
    try {
      final brightness = value.clamp(0.0, 1.0);
      await _channel.invokeMethod('setBrightness', {'level': (brightness * 100).toInt()});
      _currentBrightness = brightness;
      debugPrint('Brightness set to: $brightness');
    } catch (e) {
      debugPrint('Brightness set error: $e');
    }
  }

  Future<void> setLevel(int level) async {
    await setBrightness(level / 100.0);
  }

  Future<void> bright() async {
    await setBrightness(1.0);
  }

  Future<void> dim() async {
    await setBrightness(0.2);
  }

  Future<void> medium() async {
    await setBrightness(0.5);
  }

  Future<void> auto() async {
    try {
      await _channel.invokeMethod('autoBrightness');
      debugPrint('Auto brightness enabled');
    } catch (e) {
      debugPrint('Auto brightness error: $e');
    }
  }

  void dispose() {
    debugPrint('Brightness Service disposed');
  }
}
