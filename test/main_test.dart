import 'package:flutter_test/flutter_test.dart';
import 'package:ac_ai/services/ai_brain_service.dart';
import 'package:ac_ai/services/command_processor.dart';

void main() {
  group('AIBrainService Tests', () {
    test('Process simple input', () async {
      final aiBrain = AIBrainService();
      final response = await aiBrain.processInput('Hello');
      expect(response, isNotEmpty);
      print('AI Response: $response');
    });
  });

  group('CommandProcessor Tests', () {
    test('Recognize time command', () async {
      final processor = CommandProcessor();
      final result = await processor.processCommand('What is the time?');
      expect(result.success, true);
      expect(result.type, CommandType.time);
      print('Time Result: ${result.message}');
    });

    test('Recognize date command', () async {
      final processor = CommandProcessor();
      final result = await processor.processCommand('What is today\'s date?');
      expect(result.success, true);
      expect(result.type, CommandType.date);
      print('Date Result: ${result.message}');
    });

    test('Recognize call command', () async {
      final processor = CommandProcessor();
      final result = await processor.processCommand('Call mamma');
      expect(result.success, true);
      expect(result.type, CommandType.call);
      print('Call Result: ${result.message}');
    });
  });
}
