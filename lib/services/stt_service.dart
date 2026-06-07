import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _currentLocale = 'en-US';
  String _lastResult = '';

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String getLastResult() => _lastResult;

  Future<bool> initialize() async {
    try {
      debugPrint('🔊 STT: Initializing...');
      
      _isAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('❌ STT Error: ${error.errorMsg}');
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('📊 STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        debugLogging: true,
      );
      
      debugPrint('✅ STT initialized: $_isAvailable');
      
      if (_isAvailable) {
        // Try to get available locales
        try {
          final locales = await _speech.locales();
          debugPrint('🌍 Available locales: ${locales.length}');
          
          // Prefer English for better accuracy
          if (locales.any((l) => l.localeId == 'en-IN')) {
            _currentLocale = 'en-IN';
          } else if (locales.any((l) => l.localeId == 'en-US')) {
            _currentLocale = 'en-US';
          } else if (locales.any((l) => l.localeId == 'hi-IN')) {
            _currentLocale = 'hi-IN';
          }
          
          debugPrint('🎯 STT using locale: $_currentLocale');
        } catch (e) {
          debugPrint('⚠️ Could not get locales: $e');
        }
      }
      
      return _isAvailable;
    } catch (e) {
      debugPrint('❌ STT initialization failed: $e');
      _isAvailable = false;
      return false;
    }
  }

  Future<String?> listen() async {
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
    
    try {
      debugPrint('🎤 Starting to listen...');
      
      await _speech.listen(
        onResult: (result) {
          _lastResult = result.recognizedWords;
          debugPrint('📝 Heard: "$_lastResult"');
        },
        localeId: _currentLocale,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
        ),
      );
      
      // Wait for speech with timeout
      int timeout = 0;
      while (_isListening && timeout < 100) {
        await Future.delayed(const Duration(milliseconds: 100));
        timeout++;
        
        if (_lastResult.isNotEmpty) {
          // Got some speech, wait a bit more for completion
          await Future.delayed(const Duration(milliseconds: 1000));
          break;
        }
      }
      
      await stop();
      
      debugPrint('✅ Final result: "$_lastResult"');
      return _lastResult.isNotEmpty ? _lastResult : null;
      
    } catch (e) {
      debugPrint('❌ Listen error: $e');
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
