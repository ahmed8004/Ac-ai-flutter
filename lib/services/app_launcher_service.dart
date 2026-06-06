import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLauncherService {
  static const Map<String, String> _appPackages = {
    'whatsapp': 'com.whatsapp',
    'youtube': 'com.google.android.youtube',
    'youtube music': 'com.google.android.apps.youtube.music',
    'spotify': 'com.spotify.music',
    'instagram': 'com.instagram.android',
    'facebook': 'com.facebook.katana',
    'twitter': 'com.twitter.android',
    'gmail': 'com.google.android.gm',
    'chrome': 'com.android.chrome',
    'maps': 'com.google.android.apps.maps',
    'calculator': 'com.android.calculator2',
    'camera': 'com.android.camera',
    'gallery': 'com.android.gallery3d',
    'settings': 'com.android.settings',
    'play store': 'com.android.vending',
    'photos': 'com.google.android.apps.photos',
    'drive': 'com.google.android.apps.docs',
    'calendar': 'com.android.calendar',
    'clock': 'com.android.clock',
    'notes': 'com.google.android.keep',
  };

  Future<bool> openApp(String appName) async {
    try {
      final lowerAppName = appName.toLowerCase().trim();
      
      for (var entry in _appPackages.entries) {
        if (lowerAppName.contains(entry.key)) {
          return await launchUrl(
            Uri.parse('android-app://${entry.value}'),
            mode: LaunchMode.externalApplication,
          );
        }
      }

      debugPrint('App not found: $appName');
      return false;
    } catch (e) {
      debugPrint('App launch error: $e');
      return false;
    }
  }

  Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('URL open error: $e');
      return false;
    }
  }

  Future<bool> openMaps(String query) async {
    try {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/${Uri.encodeComponent(query)}',
      );
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Maps error: $e');
      return false;
    }
  }

  Future<bool> openPlayStore(String packageName) async {
    try {
      final uri = Uri.parse('market://details?id=$packageName');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Play Store error: $e');
      return false;
    }
  }

  List<String> getAvailableApps() {
    return _appPackages.keys.toList();
  }

  void dispose() {
    debugPrint('App Launcher Service disposed');
  }
}
