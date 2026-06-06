import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'owner_profile_service.dart';

class AIBrainService {
  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: 'YOUR_API_KEY_HERE');
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  bool _isProcessing = false;
  final List<Map<String, String>> _conversationHistory = [];
  final int _maxHistoryLength = 10;
  final OwnerProfileService _ownerService = OwnerProfileService();

  bool get isProcessing => _isProcessing;

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

      _addToHistory('user', userMessage);

      // Add system context about owner
      final systemContext = '''
You are AC AI, an intelligent voice assistant created by Ahmed Chaudhari.
Owner Information:
- Name: Ahmed Chaudhari
- Profession: Ethical Hacker, Cyber Security Expert, Network Administrator
- Location: Sangamner, Maharashtra
- Skills: Cybersecurity, Ethical Hacking, Network Administration, Penetration Testing

Rules:
- Always respond in Hindi/Hinglish if user speaks Hindi
- Be helpful, friendly and informative
- If asked about owner, give full details about Ahmed Chaudhari
- Respond to "AC" as your name (not just "AC AI")
- You can be called by: "AC", "Hey AC", "AC AI", "AC bhai"
''';

      final messages = [
        {'role': 'system', 'content': systemContext},
        ..._conversationHistory,
      ];

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
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
        
        return aiResponse;
      } else {
        _isProcessing = false;
        return 'Error: Failed to get response (${response.statusCode})';
      }
    } catch (e) {
      _isProcessing = false;
      debugPrint('AI Brain Error: $e');
      return 'Error: $e';
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
