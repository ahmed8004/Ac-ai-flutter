import 'package:flutter/foundation.dart';
import 'package:torch_light/torch_light.dart';

class TorchService {
  bool _isOn = false;

  bool get isOn => _isOn;

  Future<bool> turnOn() async {
    try {
      await TorchLight.enableTorch();
      _isOn = true;
      debugPrint('Torch: ON');
      return true;
    } catch (e) {
      debugPrint('Torch ON error: $e');
      return false;
    }
  }

  Future<bool> turnOff() async {
    try {
      await TorchLight.disableTorch();
      _isOn = false;
      debugPrint('Torch: OFF');
      return true;
    } catch (e) {
      debugPrint('Torch OFF error: $e');
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

  void dispose() {
    debugPrint('Torch Service disposed');
  }
}
