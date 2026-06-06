import 'package:flutter/foundation.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';

class ScreenshotService {
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _lastScreenshotPath;

  String? get lastScreenshotPath => _lastScreenshotPath;
  ScreenshotController get controller => _screenshotController;

  Future<String?> capture({int? quality}) async {
    try {
      final imagePath = '/sdcard/Pictures/AC_AI_Screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final file = await _screenshotController.capture(
        pixelRatio: 1.5,
        delay: Duration(milliseconds: 100),
      );

      if (file != null) {
        final savedFile = await File(imagePath).writeAsBytes(file);
        _lastScreenshotPath = savedFile.path;
        debugPrint('Screenshot saved: $imagePath');
        return imagePath;
      }
      return null;
    } catch (e) {
      debugPrint('Screenshot error: $e');
      return null;
    }
  }

  Future<bool> deleteLastScreenshot() async {
    if (_lastScreenshotPath == null) return false;

    try {
      final file = File(_lastScreenshotPath!);
      if (await file.exists()) {
        await file.delete();
        _lastScreenshotPath = null;
        debugPrint('Screenshot deleted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete screenshot error: $e');
      return false;
    }
  }

  void dispose() {
    debugPrint('Screenshot Service disposed');
  }
}
