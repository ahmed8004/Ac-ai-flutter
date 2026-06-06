import 'package:flutter/foundation.dart';
import 'stt_service.dart';
import 'tts_service.dart';
import 'ai_brain_service.dart';
import 'command_processor.dart';
import 'permission_service.dart';
import 'call_service.dart';
import 'sms_service.dart';
import 'youtube_service.dart';
import 'volume_service.dart';
import 'camera_service.dart';

class AppController extends ChangeNotifier {
  final STTService _sttService;
  final TTSService _ttsService;
  final AIBrainService _aiBrainService;
  final CommandProcessor _commandProcessor;
  final PermissionService _permissionService;

  bool _isInitialized = false;
  bool _isProcessingCommand = false;
  bool _permissionsGranted = false;
  String _lastUserInput = '';
  String _lastAIResponse = '';
  String _statusMessage = 'Ready';

  AppController({
    STTService? sttService,
    TTSService? ttsService,
    AIBrainService? aiBrainService,
    CommandProcessor? commandProcessor,
    PermissionService? permissionService,
  })  : _sttService = sttService ?? STTService(),
        _ttsService = ttsService ?? TTSService(),
        _aiBrainService = aiBrainService ?? AIBrainService(),
        _commandProcessor = commandProcessor ?? CommandProcessor(),
        _permissionService = permissionService ?? PermissionService();

  bool get isInitialized => _isInitialized;
  bool get isProcessingCommand => _isProcessingCommand;
  bool get permissionsGranted => _permissionsGranted;
  String get lastUserInput => _lastUserInput;
  String get lastAIResponse => _lastAIResponse;
  String get statusMessage => _statusMessage;
  PermissionService get permissionService => _permissionService;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setStatus('Initializing permissions...');
      
      await _permissionService.initialize();
      
      if (!_permissionService.essentialGranted) {
        _setStatus('Requesting permissions...');
        final micGranted = await _permissionService.requestMicrophone();
        
        if (!micGranted) {
          _setStatus('Microphone permission required');
          return;
        }
      }

      _setStatus('Initializing services...');
      
      await _sttService.initialize();
      await _ttsService.initialize();

      final locales = await _sttService.getAvailableLocales();
      if (locales.contains('hi-IN')) {
        await _sttService.setLocale('hi-IN');
        await _ttsService.setLanguage('hi-IN');
      } else if (locales.contains('en-IN')) {
        await _sttService.setLocale('en-IN');
        await _ttsService.setLanguage('en-IN');
      }

      _isInitialized = true;
      _permissionsGranted = true;
      _setStatus('Ready');
      
      debugPrint('App Controller initialized');
    } catch (e) {
      _setStatus('Initialization failed');
      debugPrint('App Controller initialization error: $e');
    }
  }

  Future<String> processVoiceInput() async {
    if (!_isInitialized) {
      return 'App not initialized';
    }

    if (!_permissionService.essentialGranted) {
      return 'Permissions not granted';
    }

    try {
      _setStatus('Listening...');
      _isProcessingCommand = true;
      notifyListeners();

      final transcript = await _sttService.startListening(
        onSoundLevel: (level) {
          debugPrint('Sound level: $level');
        },
        onPartialResult: (text) {
          debugPrint('Partial: $text');
        },
        onFinalResult: (text) {
          debugPrint('Final: $text');
        },
        onError: (error) {
          debugPrint('STT Error: $error');
        },
      );

      if (transcript == null || transcript.isEmpty) {
        _setStatus('No input detected');
        _isProcessingCommand = false;
        notifyListeners();
        return 'No input detected';
      }

      _lastUserInput = transcript;
      _setStatus('Processing...');
      
      final commandResult = await _commandProcessor.processCommand(transcript);
      
      if (commandResult.success && commandResult.type != CommandType.unknown) {
        _lastAIResponse = commandResult.message;
        await _ttsService.speak(commandResult.message);
        _setStatus('Ready');
      } else {
        final aiResponse = await _aiBrainService.processInput(transcript);
        _lastAIResponse = aiResponse;
        await _ttsService.speak(aiResponse);
        _setStatus('Ready');
      }

      _isProcessingCommand = false;
      notifyListeners();

      return _lastAIResponse;
    } catch (e) {
      _isProcessingCommand = false;
      _setStatus('Error occurred');
      notifyListeners();
      return 'Error: $e';
    }
  }

  Future<String> processTextInput(String input) async {
    if (!_isInitialized) {
      return 'App not initialized';
    }

    try {
      _setStatus('Processing...');
      _lastUserInput = input;

      final commandResult = await _commandProcessor.processCommand(input);
      
      if (commandResult.success && commandResult.type != CommandType.unknown) {
        _lastAIResponse = commandResult.message;
        await _ttsService.speak(commandResult.message);
      } else {
        final aiResponse = await _aiBrainService.processInput(input);
        _lastAIResponse = aiResponse;
        await _ttsService.speak(aiResponse);
      }

      _setStatus('Ready');
      notifyListeners();
      return _lastAIResponse;
    } catch (e) {
      _setStatus('Error occurred');
      return 'Error: $e';
    }
  }

  void _setStatus(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  void clearHistory() {
    _aiBrainService.clearHistory();
    _lastUserInput = '';
    _lastAIResponse = '';
    notifyListeners();
  }

  Future<void> speak(String text) async {
    await _ttsService.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
    _setStatus('Ready');
    notifyListeners();
  }

  Future<Map<String, bool>> requestAllPermissions() async {
    final results = await _permissionService.requestAll();
    _permissionsGranted = _permissionService.essentialGranted;
    notifyListeners();
    return results;
  }

  @override
  void dispose() {
    _sttService.dispose();
    _ttsService.dispose();
    _aiBrainService.dispose();
    _commandProcessor.dispose();
    _permissionService.dispose();
    super.dispose();
  }
}
