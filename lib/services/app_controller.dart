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
  PermissionService get permissionService => _permissionService;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setStatus('Requesting permissions...');
      
      await _permissionService.initialize();
      
      // Request all permissions
      await requestAllPermissions();

      _setStatus('Initializing voice...');
      
      // Initialize services in parallel
      await Future.wait([
        _sttService.initialize(),
        _ttsService.initialize(),
      ]);

      // Set Hindi locale if available
      try {
        final locales = await _sttService.getAvailableLocales();
        if (locales.contains('hi-IN')) {
          await _sttService.setLocale('hi-IN');
          await _ttsService.setLanguage('hi-IN');
        } else if (locales.contains('en-IN')) {
          await _sttService.setLocale('en-IN');
          await _ttsService.setLanguage('en-IN');
        }
      } catch (e) {
        debugPrint('Locale set error: $e');
      }

      _isInitialized = true;
      _permissionsGranted = _permissionService.essentialGranted;
      _setStatus('Ready! Say "AC" to start');
      
      debugPrint('App Controller initialized');
    } catch (e) {
      _setStatus('Initialization failed: $e');
      debugPrint('App Controller initialization error: $e');
    }
  }

  bool _isWakeWordDetected(String text) {
    final lowerText = text.toLowerCase().trim();
    
    // DEBUG: Always log what we received
    debugPrint('🎤 Checking wake word in: "$lowerText"');
    
    // Wake words list
    final wakeWords = [
      'ac',
      'hey ac',
      'ac ai',
      'ac bhai',
      'ac suno',
      'ac help',
      'hey ac ai',
      'ac ji',
      'ac assistant',
      'namaste ac',
    ];
    
    for (final wakeWord in wakeWords) {
      if (lowerText.startsWith(wakeWord) || lowerText == wakeWord) {
        debugPrint('✅ Wake word detected: "$wakeWord"');
        return true;
      }
    }
    
    // Check if "AC" is mentioned in beginning (first 5 words)
    final words = lowerText.split(' ');
    if (words.length > 0 && words.length <= 5) {
      if (words.contains('ac')) {
        debugPrint('✅ Wake word "ac" found in first 5 words');
        return true;
      }
    }
    
    // DEBUG: For testing, accept any command (remove this in production)
    if (lowerText.isNotEmpty) {
      debugPrint('⚠️ No wake word, but processing anyway: "$lowerText"');
      return true; // TEMP: Accept all commands
    }
    
    return false;
  }

  Future<String> processVoiceInput() async {
    if (!_isInitialized) {
      return 'App initializing... please wait';
    }

    if (!_permissionService.essentialGranted) {
      final granted = await requestAllPermissions();
      final allGranted = granted.values.every((v) => v);
      if (!allGranted) {
        return 'Permissions required. Please grant all permissions.';
      }
    }

    try {
      _setStatus('Listening...');
      _isProcessingCommand = true;
      notifyListeners();

      String? transcript = await _sttService.startListening(
        onSoundLevel: (level) {
          // Sound level callback (for orb animation)
        },
        onPartialResult: (text) {
          // Partial result callback
        },
        onFinalResult: (text) {
          // Final result callback
        },
        onError: (error) {
          debugPrint('STT Error: $error');
        },
      );

      // Wait a bit for final result
      await Future.delayed(const Duration(milliseconds: 500));
      transcript ??= _sttService.getLastResult();

      if (transcript.isEmpty) {
        _setStatus('No input detected');
        _isProcessingCommand = false;
        notifyListeners();
        return 'No input detected';
      }

      _lastUserInput = transcript;
      _setStatus('Processing: "$transcript"');
      debugPrint('📝 Processing transcript: "$transcript"');
      
      // Check wake word (now accepts all commands)
      if (!_isWakeWordDetected(transcript)) {
        debugPrint('⚠️ Wake word not detected, skipping...');
        _lastAIResponse = 'Please start with "AC" or "Hey AC"';
        await _ttsService.speak(_lastAIResponse);
        _setStatus('Ready');
        _isProcessingCommand = false;
        notifyListeners();
        return _lastAIResponse;
      }
      
      // Remove wake word from command
      String command = transcript.toLowerCase().trim();
      final wakeWords = ['ac ai', 'hey ac', 'ac'];
      for (final ww in wakeWords) {
        if (command.startsWith(ww)) {
          command = command.substring(ww.length).trim();
          break;
        }
      }
      
      debugPrint('🎯 Command after wake word removal: "$command"');
      
      // Process the command
      try {
        final commandResult = await _commandProcessor.processCommand(command);
        
        if (commandResult.success && commandResult.type != CommandType.unknown) {
          debugPrint('✅ Command executed: ${commandResult.type}');
          _lastAIResponse = commandResult.message;
          _setStatus('Ready');
        } else {
          debugPrint('🤖 Sending to AI: "$command"');
          final aiResponse = await _aiBrainService.processInput(command);
          _lastAIResponse = aiResponse;
          _setStatus('Ready');
        }
        
        // Speak the response
        debugPrint('🔊 Speaking: "${_lastAIResponse.substring(0, _lastAIResponse.length > 50 ? 50 : _lastAIResponse.length)}..."');
        await _ttsService.speak(_lastAIResponse);
        
      } catch (e, stackTrace) {
        debugPrint('❌ Error processing: $e');
        debugPrint('Stack: $stackTrace');
        _lastAIResponse = 'Sorry, kuch galat ho gaya. Please try again.';
        await _ttsService.speak(_lastAIResponse);
      }

      _isProcessingCommand = false;
      notifyListeners();

      return _lastAIResponse;
    } catch (e) {
      _isProcessingCommand = false;
      _setStatus('Error occurred');
      notifyListeners();
      debugPrint('processVoiceInput error: $e');
      return 'Error: $e';
    }
  }

  Future<String> processTextInput(String input) async {
    if (!_isInitialized) {
      return 'App initializing... please wait';
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
