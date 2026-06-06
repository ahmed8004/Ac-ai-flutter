import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightnessService {
  final ScreenBrightness _brightness = ScreenBrightness();
  double _currentBrightness = 0.5;

  double get currentBrightness => _currentBrightness;

  Future<void> initialize() async {
    try {
      _currentBrightness = await _brightness.application;
      debugPrint('Brightness initialized: $_currentBrightness');
    } catch (e) {
      debugPrint('Brightness init error: $e');
    }
  }

  Future<void> setBrightness(double value) async {
    try {
      final brightness = value.clamp(0.0, 1.0);
      await _brightness.setApplicationScreenBrightness(brightness);
      _currentBrightness = brightness;
      debugPrint('Brightness set to: $brightness');
    } catch (e) {
      debugPrint('Brightness set error: $e');
    }
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
      await _brightness.resetApplicationScreenBrightness();
      debugPrint('Auto brightness enabled');
    } catch (e) {
      debugPrint('Auto brightness error: $e');
    }
  }

  void dispose() {
    debugPrint('Brightness Service disposed');
  }
}
