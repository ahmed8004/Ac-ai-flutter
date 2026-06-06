import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _isAvailable = false;
  bool _isSpeaking = false;
  double _volume = 1.0;
  double _pitch = 1.0;
  double _rate = 0.5;
  String _language = 'hi-IN';

  bool get isAvailable => _isAvailable;
  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get pitch => _pitch;
  double get rate => _rate;

  Future<void> initialize() async {
    try {
      _isAvailable = await _tts.awaitSpeakCompletion(true);
      
      await _tts.setLanguage(_language);
      await _tts.setVolume(_volume);
      await _tts.setPitch(_pitch);
      await _tts.setSpeechRate(_rate);

      _tts.setStartHandler(() {
        _isSpeaking = true;
        debugPrint('TTS: Started speaking');
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        debugPrint('TTS: Completed speaking');
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        debugPrint('TTS: Cancelled speaking');
      });

      _tts.setErrorHandler((message) {
        _isSpeaking = false;
        debugPrint('TTS Error: $message');
      });

      _tts.setProgressHandler((text, start, end, word) {
        debugPrint('TTS Progress: $word');
      });

      final languages = await _tts.getLanguages;
      debugPrint('TTS available languages: $languages');
      
      debugPrint('TTS Service initialized: $_isAvailable');
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      _isAvailable = false;
    }
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await _tts.setLanguage(language);
    debugPrint('TTS: Language set to $language');
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
  }

  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.0, 1.0);
    await _tts.setSpeechRate(_rate);
  }

  Future<void> speak(
    String text, {
    Function()? onStart,
    Function()? onComplete,
    Function()? onCancel,
    Function(String)? onError,
  }) async {
    if (!_isAvailable || text.isEmpty) {
      debugPrint('TTS: Not available or empty text');
      return;
    }

    try {
      onStart?.call();
      _isSpeaking = true;

      await _tts.speak(text);

      onComplete?.call();
      _isSpeaking = false;
    } catch (e) {
      _isSpeaking = false;
      onError?.call(e.toString());
      debugPrint('TTS Speak error: $e');
    }
  }

  Future<void> stop() async {
    if (!_isSpeaking) return;
    
    await _tts.stop();
    _isSpeaking = false;
    debugPrint('TTS: Stopped');
  }

  Future<void> pause() async {
    await _tts.pause();
    debugPrint('TTS: Paused');
  }

  Future<List<String>> getLanguages() async {
    try {
      final languages = await _tts.getLanguages;
      if (languages is List) {
        return languages.map((l) => l.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('TTS getLanguages error: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getVoices() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        return voices.map<Map<String, String>>((v) {
          final map = v as Map;
          return {
            'name': map['name']?.toString() ?? '',
            'locale': map['locale']?.toString() ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('TTS getVoices error: $e');
      return [];
    }
  }

  bool isLanguageAvailable(String language) {
    return ['hi-IN', 'en-US', 'en-IN', 'en-GB'].contains(language);
  }

  void dispose() {
    if (_isSpeaking) {
      _tts.stop();
    }
    _isSpeaking = false;
    debugPrint('TTS Service disposed');
  }
}
