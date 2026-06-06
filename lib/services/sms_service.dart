import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class SMSService {
  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );
      return await launchUrl(smsUri);
    } catch (e) {
      debugPrint('SMS error: $e');
      return false;
    }
  }

  Future<bool> sendEmergencySMS(String phoneNumber) async {
    final message = 'Emergency! I need help. My location is being shared.';
    return await sendSMS(phoneNumber, message);
  }

  void dispose() {
    debugPrint('SMS Service disposed');
  }
}
