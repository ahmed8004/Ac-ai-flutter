import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class WebScraperService {
  Future<String?> fetchWebPage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      debugPrint('Web fetch error: $e');
      return null;
    }
  }

  Future<String?> extractText(String url) async {
    try {
      final html = await fetchWebPage(url);
      if (html == null) return null;

      final document = parser.parse(html);
      final bodyText = document.body?.text ?? '';
      
      final cleanText = bodyText
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      debugPrint('Extracted text (${cleanText.length} chars)');
      return cleanText.length > 500 ? cleanText.substring(0, 500) + '...' : cleanText;
    } catch (e) {
      debugPrint('Text extraction error: $e');
      return null;
    }
  }

  Future<List<String>> extractLinks(String url) async {
    try {
      final html = await fetchWebPage(url);
      if (html == null) return [];

      final document = parser.parse(html);
      final links = <String>[];

      document.querySelectorAll('a').forEach((element) {
        final href = element.attributes['href'];
        if (href != null && href.startsWith('http')) {
          links.add(href);
        }
      });

      debugPrint('Extracted ${links.length} links');
      return links;
    } catch (e) {
      debugPrint('Link extraction error: $e');
      return [];
    }
  }

  Future<Map<String, String>?> extractMeta(String url) async {
    try {
      final html = await fetchWebPage(url);
      if (html == null) return null;

      final document = parser.parse(html);
      final meta = <String, String>{};

      document.querySelectorAll('meta').forEach((element) {
        final name = element.attributes['name'] ?? element.attributes['property'];
        final content = element.attributes['content'];
        if (name != null && content != null) {
          meta[name] = content;
        }
      });

      return meta;
    } catch (e) {
      debugPrint('Meta extraction error: $e');
      return null;
    }
  }

  Future<String?> searchWeb(String query) async {
    try {
      final searchUrl = 'https://duckduckgo.com/html/?q=${Uri.encodeComponent(query)}';
      final html = await fetchWebPage(searchUrl);
      
      if (html == null) return null;

      final document = parser.parse(html);
      final results = document.querySelectorAll('.result__snippet');
      
      if (results.isNotEmpty) {
        return results.first.text.trim();
      }
      
      return null;
    } catch (e) {
      debugPrint('Web search error: $e');
      return null;
    }
  }

  void dispose() {
    debugPrint('Web Scraper Service disposed');
  }
}
