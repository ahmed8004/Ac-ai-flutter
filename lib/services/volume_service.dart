import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VolumeService {
  static const MethodChannel _channel = MethodChannel('ac.ai/volume');
  bool _initialized = false;
  int _currentVolume = 50;

  int get currentVolume => _currentVolume;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _currentVolume = await getVolume();
      _initialized = true;
      debugPrint('Volume Service initialized');
    } catch (e) {
      debugPrint('Volume init error: $e');
    }
  }

  Future<void> setVolume(int level) async {
    try {
      await _channel.invokeMethod('setVolume', {'level': level});
      _currentVolume = level;
      debugPrint('Volume set to $level');
    } catch (e) {
      debugPrint('Volume control error: $e');
    }
  }

  Future<int> getVolume() async {
    try {
      final int? volume = await _channel.invokeMethod('getVolume');
      _currentVolume = volume ?? 50;
      return _currentVolume;
    } catch (e) {
      debugPrint('Get volume error: $e');
      return 50;
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
