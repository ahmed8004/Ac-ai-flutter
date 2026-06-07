import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'owner_profile_service.dart';

class AIBrainService {
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';
  
  // Fallback API key (for demo mode if user doesn't set)
  // Note: Replace with your own Groq API key in Settings panel
  // Get free key: https://console.groq.com/keys
  static const String _fallbackApiKey = 'YOUR_GROQ_API_KEY_HERE';

  bool _isProcessing = false;
  final List<Map<String, String>> _conversationHistory = [];
  final int _maxHistoryLength = 10;
  final OwnerProfileService _ownerService = OwnerProfileService();
  
  String? _apiKey;

  bool get isProcessing => _isProcessing;

  Future<String> _getApiKey() async {
    if (_apiKey != null && _apiKey!.isNotEmpty && _apiKey != 'YOUR_FALLBACK_KEY_HERE') {
      debugPrint('✅ Using cached API key');
      return _apiKey!;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString('groq_api_key');
      
      if (savedKey != null && savedKey.isNotEmpty && savedKey != 'YOUR_API_KEY_HERE' && savedKey.startsWith('gsk_')) {
        _apiKey = savedKey;
        debugPrint('✅ Using saved API key from Settings');
        return _apiKey!;
      }
      
      debugPrint('⚠️ No valid API key in Settings, using fallback');
      _apiKey = _fallbackApiKey;
      return _apiKey!;
    } catch (e) {
      debugPrint('❌ Error reading API key: $e');
      return _fallbackApiKey;
    }
  }

  Future<String> processInput(String userMessage) async {
    if (_isProcessing) {
      return 'Please wait, I\'m still processing your previous request.';
    }

    _isProcessing = true;

    try {
      // Check if asking about owner
      if (_ownerService.isOwnerMentioned(userMessage)) {
        _isProcessing = false;
        return _ownerService.getResponse(userMessage);
      }

      // Check if asking about capabilities
      if (_ownerService.isCapabilitiesQuery(userMessage)) {
        _isProcessing = false;
        return _ownerService.getCapabilities();
      }

      // Check if greeting
      if (_ownerService.isWelcomeQuery(userMessage)) {
        _isProcessing = false;
        return _ownerService.getWelcomeMessage();
      }

      _addToHistory('user', userMessage);

      // Get API key
      final apiKey = await _getApiKey();

      // Add system context about owner
      final systemContext = '''
You are AC AI, an intelligent voice assistant created by Ahmed Chaudhari.

Owner Information:
- Name: Ahmed Chaudhari
- Profession: Ethical Hacker, Cyber Security Expert, Network Administrator
- Location: Sangamner, Maharashtra
- Skills: ${_ownerService.ownerSkills.join(', ')}

Rules:
- Always respond in Hindi/Hinglish if user speaks Hindi
- Be helpful, friendly and informative
- If asked about owner, give full details about Ahmed Chaudhari
- Respond to "AC" as your name (not just "AC AI")
- You can be called by: "AC", "Hey AC", "AC AI", "AC bhai"
- Keep responses short (2-3 sentences max for voice)
''';

      final messages = [
        {'role': 'system', 'content': systemContext},
        ..._conversationHistory,
      ];

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        _addToHistory('assistant', aiResponse);
        _isProcessing = false;
        
        debugPrint('✅ AI Response: "${aiResponse.substring(0, aiResponse.length > 50 ? 50 : aiResponse.length)}..."');
        return aiResponse;
      } else {
        _isProcessing = false;
        debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 401) {
          return 'API Key invalid hai! Settings me sahi Groq API key daalo.';
        }
        return 'Error: Failed to get response (${response.statusCode})';
      }
    } catch (e) {
      _isProcessing = false;
      debugPrint('❌ AI Brain Exception: $e');
      debugPrint('AI Brain Error: $e');
      
      if (e.toString().contains('SocketException')) {
        return 'Internet connection nahi hai. WiFi/4G ON karo.';
      }
      
      return 'Sorry, kuch galat ho gaya. Please try again.';
    }
  }

  void _addToHistory(String role, String content) {
    _conversationHistory.add({'role': role, 'content': content});
    
    if (_conversationHistory.length > _maxHistoryLength * 2) {
      _conversationHistory.removeRange(0, 2);
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
    debugPrint('Conversation history cleared');
  }

  void dispose() {
    _conversationHistory.clear();
    _ownerService.dispose();
    debugPrint('AI Brain Service disposed');
  }
}
