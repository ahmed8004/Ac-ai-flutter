import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _currentLocale = 'en-US';
  String _lastResult = '';
  String? _currentError;

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String? get lastError => _currentError;

  Future<bool> initialize() async {
    try {
      debugPrint('🔊 STT: Initializing...');
      _currentError = null;
      
      _isAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('❌ STT Error: ${error.errorMsg}');
          _currentError = error.errorMsg;
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('📊 STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          } else if (status == 'listening') {
            _isListening = true;
          }
        },
        debugLogging: kDebugMode,
      );
      
      debugPrint('✅ STT initialized: $_isAvailable');
      
      if (_isAvailable) {
        try {
          final locales = await _speech.locales();
          debugPrint('🌍 Available locales: ${locales.length}');
          
          // Check for preferred locales
          final preferredLocales = ['en-US', 'en-IN', 'hi-IN', 'en-GB'];
          for (final locale in preferredLocales) {
            if (locales.any((l) => l.localeId == locale)) {
              _currentLocale = locale;
              debugPrint('🎯 STT using locale: $_currentLocale');
              break;
            }
          }
        } catch (e) {
          debugPrint('⚠️ Could not get locales: $e');
        }
      } else {
        _currentError = 'Speech recognition not available';
      }
      
      return _isAvailable;
    } catch (e) {
      debugPrint('❌ STT initialization failed: $e');
      _currentError = e.toString();
      _isAvailable = false;
      return false;
    }
  }

  Future<String?> listenFor(Duration duration) async {
    if (_isListening) {
      debugPrint('⚠️ Already listening');
      return null;
    }
    
    if (!_isAvailable) {
      debugPrint('❌ STT not available');
      return null;
    }
    
    _isListening = true;
    _lastResult = '';
    _currentError = null;
    
    final completer = Completer<String?>();
    
    try {
      debugPrint('🎤 Starting to listen for ${duration.inSeconds}s...');
      
      await _speech.listen(
        onResult: (result) {
          _lastResult = result.recognizedWords;
          debugPrint('📝 Heard: "$_lastResult" (final: ${result.finalResult})');
          
          if (result.finalResult && !completer.isCompleted) {
            completer.complete(_lastResult);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        ),
        localeId: _currentLocale,
      );
      
      // Wait for duration or result
      await Future.any([
        completer.future,
        Future.delayed(duration, () => null),
      ]);
      
      if (!completer.isCompleted) {
        completer.complete(_lastResult.isNotEmpty ? _lastResult : null);
      }
      
      await stop();
      
      final finalResult = await completer.future;
      debugPrint('✅ Final result: "$finalResult"');
      return finalResult;
      
    } catch (e) {
      debugPrint('❌ Listen error: $e');
      _currentError = e.toString();
      _isListening = false;
      return null;
    }
  }

  Future<void> stop() async {
    if (!_isListening) return;
    
    try {
      await _speech.stop();
      debugPrint('🛑 STT stopped');
    } catch (e) {
      debugPrint('⚠️ Stop error: $e');
    }
    
    _isListening = false;
  }

  Future<void> cancel() async {
    if (!_isListening) return;
    
    try {
      await _speech.cancel();
      debugPrint('❌ STT cancelled');
    } catch (e) {
      debugPrint('⚠️ Cancel error: $e');
    }
    
    _isListening = false;
  }

  String? getLastResult() {
    return _lastResult.isNotEmpty ? _lastResult : null;
  }

  Future<List<String>> getAvailableLocales() async {
    if (!_isAvailable) return [];
    
    try {
      final locales = await _speech.locales();
      return locales.map((l) => l.localeId).toList();
    } catch (e) {
      debugPrint('⚠️ Get locales error: $e');
      return [];
    }
  }

  void dispose() {
    if (_isListening) {
      try {
        _speech.cancel();
      } catch (e) {
        debugPrint('⚠️ Dispose error: $e');
      }
    }
    _isListening = false;
    debugPrint('👋 STT Service disposed');
  }
}
