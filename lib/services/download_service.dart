import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  double _progress = 0.0;
  bool _isDownloading = false;
  String _lastFilePath = '';
  String _status = 'Idle';

  double get progress => _progress;
  bool get isDownloading => _isDownloading;
  String get lastFilePath => _lastFilePath;
  String get status => _status;

  Future<bool> requestPermissions() async {
    try {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    } catch (e) {
      debugPrint('Storage permission error: $e');
      return false;
    }
  }

  Future<String?> downloadFile(String url, {String? fileName}) async {
    if (_isDownloading) {
      debugPrint('Download already in progress');
      return null;
    }

    try {
      _isDownloading = true;
      _status = 'Downloading...';
      _progress = 0.0;

      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        _status = 'Storage permission denied';
        _isDownloading = false;
        return null;
      }

      final uri = Uri.parse(url);
      final name = fileName ?? url.split('/').last;

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$name';

      final response = await http.Client().send(http.Request('GET', uri));

      if (response.statusCode != 200) {
        _status = 'Download failed: ${response.statusCode}';
        _isDownloading = false;
        return null;
      }

      final contentLength = response.contentLength ?? 0;
      var receivedBytes = 0;

      final file = File(filePath);
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          _progress = receivedBytes / contentLength;
        }
      }

      await sink.close();

      _lastFilePath = filePath;
      _status = 'Download complete: $name';
      _isDownloading = false;
      _progress = 1.0;

      debugPrint('File downloaded: $filePath');
      return filePath;
    } catch (e) {
      _status = 'Download error: $e';
      _isDownloading = false;
      debugPrint('Download error: $e');
      return null;
    }
  }

  Future<List<String>> getDownloadedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await dir.list().toList();
      return files
          .where((entity) => entity is File)
          .map((entity) => entity.path)
          .toList();
    } catch (e) {
      debugPrint('List downloads error: $e');
      return [];
    }
  }

  void dispose() {
    debugPrint('Download Service disposed');
  }
}
