import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  Future<String?> downloadFile(String url, String fileName) async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return null;

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      debugPrint('Download started: $taskId');
      return taskId;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  Future<List<DownloadTask>?> getDownloads() async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      return tasks;
    } catch (e) {
      debugPrint('Get downloads error: $e');
      return null;
    }
  }

  Future<bool> cancelDownload(String taskId) async {
    try {
      await FlutterDownloader.cancel(taskId: taskId);
      debugPrint('Download cancelled: $taskId');
      return true;
    } catch (e) {
      debugPrint('Cancel download error: $e');
      return false;
    }
  }

  Future<bool> pauseDownload(String taskId) async {
    try {
      await FlutterDownloader.pause(taskId: taskId);
      debugPrint('Download paused: $taskId');
      return true;
    } catch (e) {
      debugPrint('Pause download error: $e');
      return false;
    }
  }

  Future<bool> resumeDownload(String taskId) async {
    try {
      await FlutterDownloader.resume(taskId: taskId);
      debugPrint('Download resumed: $taskId');
      return true;
    } catch (e) {
      debugPrint('Resume download error: $e');
      return false;
    }
  }

  Future<bool> retryDownload(String taskId) async {
    try {
      await FlutterDownloader.retry(taskId: taskId);
      debugPrint('Download retried: $taskId');
      return true;
    } catch (e) {
      debugPrint('Retry download error: $e');
      return false;
    }
  }

  void dispose() {
    debugPrint('Download Service disposed');
  }
}
