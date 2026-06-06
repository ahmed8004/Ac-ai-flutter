import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class CallService {
  Future<bool> makeCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      return await launchUrl(phoneUri);
    } catch (e) {
      debugPrint('Call error: $e');
      return false;
    }
  }

  Future<bool> makeEmergencyCall() async {
    return await makeCall('112');
  }

  void dispose() {
    debugPrint('Call Service disposed');
  }
}
