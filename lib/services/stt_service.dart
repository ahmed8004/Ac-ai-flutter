import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _currentLocale = 'hi-IN';
  String _lastResult = '';

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String getLastResult() => _lastResult;

  Future<void> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: kDebugMode,
      );
      
      debugPrint('STT Service initialized: $_isAvailable');
      
      if (_isAvailable) {
        final locales = await _speech.locales();
        debugPrint('Available locales: ${locales.map((l) => l.localeId).join(', ')}');
        
        if (locales.any((l) => l.localeId == 'hi-IN')) {
          _currentLocale = 'hi-IN';
        } else if (locales.any((l) => l.localeId == 'en-IN')) {
          _currentLocale = 'en-IN';
        } else {
          _currentLocale = 'en-US';
        }
        
        debugPrint('Using locale: $_currentLocale');
      }
    } catch (e) {
      debugPrint('STT initialization error: $e');
      _isAvailable = false;
    }
  }

  Future<String?> startListening({
    required Function(double) onSoundLevel,
    required Function(String) onPartialResult,
    required Function(String) onFinalResult,
    required Function(String) onError,
  }) async {
    if (_isListening || !_isAvailable) {
      debugPrint('STT: Cannot start - already listening or not available');
      return null;
    }

    _isListening = true;
    debugPrint('STT: Started listening in $_currentLocale');

    String? finalTranscript;

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          final transcript = result.recognizedWords;
          _lastResult = transcript;
          
          if (result.finalResult) {
            finalTranscript = transcript;
            onFinalResult(transcript);
            debugPrint('STT Final: $transcript');
          } else {
            onPartialResult(transcript);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: (level) {
          final normalizedLevel = (level + 160) / 160;
          onSoundLevel(normalizedLevel.clamp(0.0, 1.0));
        },
        localeId: _currentLocale,
      );
    } catch (e) {
      debugPrint('STT Listen error: $e');
      onError(e.toString());
      _isListening = false;
      return null;
    }

    return finalTranscript;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speech.stop();
    _isListening = false;
    debugPrint('STT: Stopped listening');
  }

  Future<void> cancel() async {
    if (!_isListening) return;
    
    await _speech.cancel();
    _isListening = false;
    debugPrint('STT: Cancelled');
  }

  Future<void> setLocale(String localeId) async {
    final locales = await _speech.locales();
    if (locales.any((l) => l.localeId == localeId)) {
      _currentLocale = localeId;
      debugPrint('STT: Locale set to $localeId');
    } else {
      debugPrint('STT: Locale $localeId not available');
    }
  }

  Future<List<String>> getAvailableLocales() async {
    if (!_isAvailable) return [];
    
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }

  void _handleError(SpeechRecognitionError error) {
    debugPrint('STT Error: ${error.errorMsg} - ${error.permanent}');
    _isListening = false;
  }

  void _handleStatus(String status) {
    debugPrint('STT Status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  void dispose() {
    if (_isListening) {
      _speech.cancel();
    }
    _isListening = false;
    debugPrint('STT Service disposed');
  }
}
