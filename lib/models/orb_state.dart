import 'package:flutter/material.dart';
import '../services/app_controller.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../services/ai_brain_service.dart';
import '../services/command_processor.dart';

enum OrbState {
  idle,
  listening,
  processing,
  speaking,
  error,
  paused,
  stopped,
}

class OrbStateConfig {
  final Color color;
  final String label;
  final double glowOpacity;
  final double glowRadius;

  const OrbStateConfig({
    required this.color,
    required this.label,
    required this.glowOpacity,
    required this.glowRadius,
  });

  static const Map<OrbState, OrbStateConfig> configs = {
    OrbState.idle: OrbStateConfig(
      color: Color(0xFF00D4FF),
      label: 'Idle',
      glowOpacity: 0.3,
      glowRadius: 30,
    ),
    OrbState.listening: OrbStateConfig(
      color: Color(0xFF00FF88),
      label: 'Listening',
      glowOpacity: 0.7,
      glowRadius: 50,
    ),
    OrbState.processing: OrbStateConfig(
      color: Color(0xFFFFB800),
      label: 'Processing',
      glowOpacity: 0.5,
      glowRadius: 40,
    ),
    OrbState.speaking: OrbStateConfig(
      color: Color(0xFFFF00FF),
      label: 'Speaking',
      glowOpacity: 0.6,
      glowRadius: 50,
    ),
    OrbState.error: OrbStateConfig(
      color: Color(0xFFFF3B3B),
      label: 'Error',
      glowOpacity: 1.0,
      glowRadius: 45,
    ),
    OrbState.paused: OrbStateConfig(
      color: Color(0xFF666666),
      label: 'Paused',
      glowOpacity: 0.2,
      glowRadius: 20,
    ),
    OrbState.stopped: OrbStateConfig(
      color: Color(0xFF333333),
      label: 'Stopped',
      glowOpacity: 0.1,
      glowRadius: 15,
    ),
  };

  static OrbStateConfig getConfig(OrbState state) {
    return configs[state] ?? configs[OrbState.idle]!;
  }
}

class OrbController extends ChangeNotifier {
  OrbState _state = OrbState.idle;
  double _voiceLevel = 0.0;
  bool _isPaused = false;
  bool _isStopped = false;
  bool _isInitialized = false;

  late AppController _appController;
  String _lastTranscript = '';
  String _lastResponse = '';

  OrbState get state => _state;
  double get voiceLevel => _voiceLevel;
  bool get isPaused => _isPaused;
  bool get isStopped => _isStopped;
  bool get isInitialized => _isInitialized;
  String get lastTranscript => _lastTranscript;
  String get lastResponse => _lastResponse;

  Color get currentColor => OrbStateConfig.getConfig(_state).color;
  String get currentLabel => OrbStateConfig.getConfig(_state).label;

  OrbController() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _appController = AppController(
      sttService: STTService(),
      ttsService: TTSService(),
      aiBrainService: AIBrainService(),
      commandProcessor: CommandProcessor(),
    );

    await _appController.initialize();
    _isInitialized = true;
    notifyListeners();
  }

  void setState(OrbState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void setVoiceLevel(double level) {
    _voiceLevel = level.clamp(0.0, 1.0);
    notifyListeners();
  }

  void pause() {
    _isPaused = true;
    setState(OrbState.paused);
    _appController.stopSpeaking();
    _appController.stopListening();
  }

  void resume() {
    _isPaused = false;
    setState(OrbState.idle);
  }

  void stop() {
    _isStopped = true;
    _isPaused = false;
    setState(OrbState.stopped);
    _appController.stopSpeaking();
    _appController.stopListening();
  }

  void reset() {
    _isStopped = false;
    _isPaused = false;
    _voiceLevel = 0.0;
    setState(OrbState.idle);
  }

  Future<void> startListening() async {
    if (_isPaused || _isStopped || !_isInitialized) return;

    setState(OrbState.listening);

    try {
      await _appController.processVoiceInput();
      _lastResponse = _appController.lastAIResponse;

      if (!_isPaused && !_isStopped) {
        setState(OrbState.speaking);
        await Future.delayed(Duration(milliseconds: _lastResponse.length * 30));
        setState(OrbState.idle);
      }
    } catch (e) {
      if (!_isPaused && !_isStopped) {
        triggerError('Error processing voice input');
      }
    }
  }

  void triggerError(String message) {
    setState(OrbState.error);
    Future.delayed(const Duration(seconds: 2), () {
      if (_state == OrbState.error) {
        setState(OrbState.idle);
      }
    });
  }

  @override
  void dispose() {
    _appController.dispose();
    super.dispose();
  }
}
