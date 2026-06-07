import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIDocumentService {
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';
  
  String? _apiKey;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  Future<String> _getApiKey() async {
    if (_apiKey != null && _apiKey!.isNotEmpty) return _apiKey!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString('groq_api_key');
      
      if (_apiKey == null || _apiKey!.isEmpty) {
        // User should set their own API key in Settings
        return '';
      }
      
      return _apiKey!;
    } catch (e) {
      return '';
    }
  }

  Future<String> summarize(String text, String summaryType) async {
    if (_isProcessing) {
      return 'Already processing...';
    }

    if (text.isEmpty) {
      return 'No text to summarize';
    }

    _isProcessing = true;

    try {
      debugPrint('🤖 AI summarizing document...');
      
      final apiKey = await _getApiKey();
      
      String systemPrompt;
      switch (summaryType) {
        case 'short':
          systemPrompt = '''Summarize this document in 2-3 sentences maximum. Be concise and capture the main points only. Respond in Hindi if the document is in Hindi, otherwise in English.'''
          break;
        case 'detailed':
          systemPrompt = '''Provide a detailed summary of this document. Include main points, key arguments, and important details. Use paragraphs. Respond in the same language as the document.'''
          break;
        case 'bullets':
          systemPrompt = '''Summarize this document as bullet points. List the main points with bullet markers (•). Include 5-10 key points. Respond in the same language as the document.'''
          break;
        case 'explain':
          systemPrompt = '''Explain this document in simple terms as if explaining to a beginner. Break down complex concepts. Respond in the same language as the document.'''
          break;
        default:
          systemPrompt = '''Summarize this document. Provide key points and main ideas. Respond in the same language as the document.'''
      }

      // Limit text length for API
      final limitedText = text.length > 8000 
          ? text.substring(0, 8000) + '...' 
          : text;

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt
            },
            {
              'role': 'user',
              'content': 'Please summarize this document:\n\n$limitedText'
            }
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data['choices'][0]['message']['content'];
        _isProcessing = false;
        debugPrint('✅ Summary generated');
        return summary;
      } else {
        _isProcessing = false;
        if (response.statusCode == 401) {
          return 'Error: Invalid API key';
        }
        return 'Error: Failed to summarize (${response.statusCode})';
      }
    } catch (e) {
      _isProcessing = false;
      debugPrint('❌ Summary error: $e');
      return 'Error: $e';
    }
  }

  Future<String> explainDocument(String text) async {
    return await summarize(text, 'explain');
  }

  Future<String> getKeyPoints(String text) async {
    return await summarize(text, 'bullets');
  }

  void dispose() {
    _isProcessing = false;
    debugPrint('👋 AI Document Service disposed');
  }
}
