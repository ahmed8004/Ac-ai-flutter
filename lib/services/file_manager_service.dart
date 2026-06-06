import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class FileManagerService {
  Future<String?> pickFile() async {
    try {
      final result = await FilePicker.instance.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      debugPrint('File pick error: $e');
      return null;
    }
  }

  Future<String?> pickPDF() async {
    try {
      final result = await FilePicker.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      debugPrint('PDF pick error: $e');
      return null;
    }
  }

  Future<String?> pickDocument() async {
    try {
      final result = await FilePicker.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'rtf'],
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      debugPrint('Document pick error: $e');
      return null;
    }
  }

  Future<String?> pickImage() async {
    try {
      final result = await FilePicker.instance.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      debugPrint('Image pick error: $e');
      return null;
    }
  }

  Future<bool> openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
      debugPrint('File opened: $filePath');
      return true;
    } catch (e) {
      debugPrint('File open error: $e');
      return false;
    }
  }

  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('File delete error: $e');
      return false;
    }
  }

  Future<String?> saveFile(String fileName, String content) async {
    try {
      final result = await FilePicker.instance.saveFile(
        dialogTitle: 'Save file',
        fileName: fileName,
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsString(content);
        debugPrint('File saved: $result');
        return result;
      }
      return null;
    } catch (e) {
      debugPrint('File save error: $e');
      return null;
    }
  }

  void dispose() {
    debugPrint('File Manager Service disposed');
  }
}
