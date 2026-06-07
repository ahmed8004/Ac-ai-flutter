import 'dart:async';
import 'package:flutter/foundation.dart';
import 'stt_service.dart';
import 'tts_service.dart';
import 'ai_brain_service.dart';
import 'command_processor.dart';
import 'permission_service.dart';

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
  String _statusMessage = 'Initializing...';

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

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setStatus('Requesting permissions...');
      await _permissionService.initialize();
      
      final micGranted = await _permissionService.requestMicrophone();
      if (!micGranted) {
        _setStatus('Microphone permission needed!');
        await _ttsService.speak('Microphone permission needed');
        return;
      }

      _setStatus('Initializing voice...');
      
      final sttOk = await _sttService.initialize();
      if (!sttOk) {
        _setStatus('Voice recognition not available');
        await _ttsService.speak('Voice recognition not available');
        return;
      }
      
      await _ttsService.initialize();
      
      _isInitialized = true;
      _permissionsGranted = true;
      _setStatus('Ready! Tap mic and speak');
      
      debugPrint('✅ App Controller initialized');
    } catch (e) {
      _setStatus('Initialization failed: $e');
      debugPrint('❌ Init error: $e');
    }
  }

  Future<void> processVoiceInput() async {
    if (!_isInitialized) {
      await _ttsService.speak('Please wait, initializing...');
      return;
    }

    if (!_permissionService.essentialGranted) {
      await _ttsService.speak('Please grant microphone permission');
      return;
    }

    try {
      _setStatus('Listening...');
      _isProcessingCommand = true;
      notifyListeners();

      debugPrint('🎤 Starting voice input...');
      
      final transcript = await _sttService.listenFor(const Duration(seconds: 5));
      
      if (transcript == null || transcript.isEmpty) {
        _setStatus('No speech detected');
        await _ttsService.speak('Sorry, I could not hear anything');
        _isProcessingCommand = false;
        notifyListeners();
        return;
      }

      _lastUserInput = transcript;
      _setStatus('Processing: "$transcript"');
      debugPrint('📝 Processing: "$transcript"');
      
      await _processCommand(transcript);

    } catch (e) {
      debugPrint('❌ Voice input error: $e');
      _setStatus('Error: $e');
      _isProcessingCommand = false;
      notifyListeners();
    }
  }

  Future<void> _processCommand(String transcript) async {
    try {
      final lower = transcript.toLowerCase().trim();
      
      // Check for wake word
      if (!lower.startsWith('ac') && 
          !lower.startsWith('hey ac') && 
          !lower.startsWith('ac ai') &&
          !lower.startsWith('assistant')) {
        _setStatus('Say "AC" first');
        await _ttsService.speak('Please start with AC');
        _isProcessingCommand = false;
        notifyListeners();
        return;
      }
      
      // Remove wake word
      String command = lower;
      for (final ww in ['ac ai', 'hey ac', 'ac']) {
        if (command.startsWith(ww)) {
          command = command.substring(ww.length).trim();
          break;
        }
      }
      
      if (command.isEmpty) {
        _lastAIResponse = 'Haan bhai, bolo? Kya help chahiye?';
        await _ttsService.speak(_lastAIResponse);
        _setStatus('Ready');
        _isProcessingCommand = false;
        notifyListeners();
        return;
      }
      
      debugPrint('🎯 Command: "$command"');
      _setStatus('Processing command...');
      
      // Process the command
      final result = await _commandProcessor.processCommand(command);
      
      if (result.success && result.type != CommandType.unknown) {
        _lastAIResponse = result.message;
        _setStatus('Done');
      } else {
        _setStatus('Asking AI...');
        _lastAIResponse = await _aiBrainService.processInput(command);
      }
      
      debugPrint('💬 Response: "${_lastAIResponse.substring(0, _lastAIResponse.length > 50 ? 50 : _lastAIResponse.length)}..."');
      
      await _ttsService.speak(_lastAIResponse);
      _setStatus('Ready');
      
    } catch (e) {
      debugPrint('❌ Process error: $e');
      _lastAIResponse = 'Sorry, error ho gaya';
      await _ttsService.speak(_lastAIResponse);
      _setStatus('Error');
    }
    
    _isProcessingCommand = false;
    notifyListeners();
  }

  Future<void> processTextInput(String input) async {
    if (!_isInitialized) {
      await _ttsService.speak('Please wait...');
      return;
    }

    _lastUserInput = input;
    await _processCommand(input);
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
    await _sttService.stop();
    _setStatus('Stopped');
    notifyListeners();
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
