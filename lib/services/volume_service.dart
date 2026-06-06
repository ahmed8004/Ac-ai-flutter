import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class VolumeService {
  static const MethodChannel _channel = MethodChannel('ac.ai/volume');
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await FlutterVolumeController.setVolume(0.5);
      _initialized = true;
      debugPrint('Volume Service initialized');
    } catch (e) {
      debugPrint('Volume init error: $e');
    }
  }
  
  Future<void> setVolume(int level) async {
    try {
      await FlutterVolumeController.setVolume(level.toDouble() / 100.0);
      debugPrint('Volume set to $level');
    } catch (e) {
      debugPrint('Volume control error: $e');
      // Fallback to method channel
      try {
        await _channel.invokeMethod('setVolume', {'level': level});
      } on PlatformException catch (pe) {
        debugPrint('Fallback error: ${pe.message}');
      }
    }
  }

  Future<int> getVolume() async {
    try {
      final volume = await FlutterVolumeController.getVolume();
      return ((volume ?? 0.5) * 100).toInt();
    } catch (e) {
      debugPrint('Get volume error: $e');
      // Fallback to method channel
      try {
        final int? vol = await _channel.invokeMethod('getVolume');
        return vol ?? 50;
      } on PlatformException {
        return 50;
      }
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
