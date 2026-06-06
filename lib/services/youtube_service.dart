import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeService {
  Future<bool> openYouTube() async {
    try {
      final Uri url = Uri.parse('https://www.youtube.com');
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('YouTube open error: $e');
      return false;
    }
  }

  Future<bool> searchYouTube(String query) async {
    try {
      final searchQuery = Uri.encodeComponent(query);
      final Uri url = Uri.parse('https://www.youtube.com/results?search_query=$searchQuery');
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('YouTube search error: $e');
      return false;
    }
  }

  Future<bool> playVideo(String videoId) async {
    try {
      final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('YouTube play error: $e');
      return false;
    }
  }

  void dispose() {
    debugPrint('YouTube Service disposed');
  }
}
