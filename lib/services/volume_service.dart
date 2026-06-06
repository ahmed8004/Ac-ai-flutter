import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VolumeService {
  static const MethodChannel _channel = MethodChannel('ac.ai/volume');
  
  Future<void> setVolume(int level) async {
    try {
      await _channel.invokeMethod('setVolume', {'level': level});
      debugPrint('Volume set to $level');
    } on PlatformException catch (e) {
      debugPrint('Volume control error: ${e.message}');
    }
  }

  Future<int> getVolume() async {
    try {
      final int? volume = await _channel.invokeMethod('getVolume');
      return volume ?? 50;
    } on PlatformException catch (e) {
      debugPrint('Get volume error: ${e.message}');
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
