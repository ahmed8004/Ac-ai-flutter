import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VolumeService {
  static const MethodChannel _channel = MethodChannel('ac.ai/volume');
  int _currentVolume = 50;
  bool _isAvailable = true;

  int get currentVolume => _currentVolume;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    try {
      final vol = await _channel.invokeMethod('getVolume');
      _currentVolume = vol ?? 50;
      debugPrint('Volume Service initialized: $_currentVolume');
    } catch (e) {
      debugPrint('Volume init error (using default 50): $e');
      _isAvailable = false;
    }
  }

  Future<void> setVolume(int level) async {
    try {
      await _channel.invokeMethod('setVolume', {'level': level});
      _currentVolume = level;
      debugPrint('Volume set to: $level');
    } catch (e) {
      debugPrint('Volume set error: $e');
    }
  }

  Future<int> getVolume() async {
    try {
      final vol = await _channel.invokeMethod('getVolume');
      _currentVolume = vol ?? 50;
      return _currentVolume;
    } catch (e) {
      return _currentVolume;
    }
  }

  Future<void> volumeUp() async {
    final current = await getVolume();
    final newVolume = (current + 10).clamp(0, 100);
    await setVolume(newVolume);
  }

  Future<void> volumeDown() async {
    final current = await getVolume();
    final newVolume = (current - 10).clamp(0, 100);
    await setVolume(newVolume);
  }

  Future<void> mute() async {
    await setVolume(0);
  }

  Future<void> maxVolume() async {
    await setVolume(100);
  }

  void dispose() {
    debugPrint('Volume Service disposed');
  }
}
