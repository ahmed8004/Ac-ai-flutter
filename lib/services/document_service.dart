import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentService {
  PDFDoc? _currentPdf;
  String _lastFilePath = '';
  String _lastFileName = '';
  String _extractedText = '';
  bool _isLoading = false;

  String get lastFilePath => _lastFilePath;
  String get lastFileName => _lastFileName;
  String get extractedText => _extractedText;
  bool get isLoading => _isLoading;

  Future<bool> requestPermissions() async {
    try {
      final storage = await Permission.storage.request();
      final manageStorage = await Permission.manageExternalStorage.request();
      return storage.isGranted || manageStorage.isGranted;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  Future<String?> pickDocument() async {
    try {
      _isLoading = true;
      
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        _isLoading = false;
        return 'Storage permission denied';
      }

      debugPrint('📄 Opening document picker...');
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'rtf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _isLoading = false;
        return null;
      }

      final file = result.files.first;
      _lastFilePath = file.path ?? '';
      _lastFileName = file.name;
      
      debugPrint('📄 Selected: $_lastFileName');
      
      // Extract text based on file type
      final extension = file.extension?.toLowerCase() ?? '';
      
      if (extension == 'pdf') {
        await _extractPdfText(_lastFilePath);
      } else if (extension == 'txt' || extension == 'rtf') {
        await _extractTextFile(_lastFilePath);
      } else if (extension == 'doc' || extension == 'docx') {
        await _extractDocText(_lastFilePath);
      }
      
      _isLoading = false;
      return _lastFilePath;
      
    } catch (e) {
      _isLoading = false;
      debugPrint('❌ Document pick error: $e');
      return 'Error: $e';
    }
  }

  Future<void> _extractPdfText(String path) async {
    try {
      debugPrint('📖 Extracting PDF text...');
      _currentPdf = await PDFDoc.fromPath(path);
      _extractedText = await _currentPdf!.text;
      debugPrint('✅ PDF extracted: ${_extractedText.length} chars');
    } catch (e) {
      debugPrint('❌ PDF extraction error: $e');
      _extractedText = 'Error reading PDF: $e';
    }
  }

  Future<void> _extractTextFile(String path) async {
    try {
      debugPrint('📖 Reading text file...');
      final file = File(path);
      _extractedText = await file.readAsString();
      debugPrint('✅ Text file read: ${_extractedText.length} chars');
    } catch (e) {
      debugPrint('❌ Text read error: $e');
      _extractedText = 'Error reading file: $e';
    }
  }

  Future<void> _extractDocText(String path) async {
    // For DOC/DOCX, we'll just read as text (simplified)
    // In production, use docx_to_text package
    try {
      debugPrint('📖 Reading document...');
      final file = File(path);
      final bytes = await file.readAsBytes();
      // Try to extract readable text from binary
      _extractedText = String.fromCharCodes(bytes.where((b) => b > 31 && b < 127).toList());
      if (_extractedText.length > 10000) {
        _extractedText = _extractedText.substring(0, 10000) + '...';
      }
      debugPrint('✅ Document read: ${_extractedText.length} chars');
    } catch (e) {
      debugPrint('❌ Document read error: $e');
      _extractedText = 'Error reading document. Please use PDF or TXT files.';
    }
  }

  Future<String> summarizeDocument(String summaryType) async {
    if (_extractedText.isEmpty) {
      return 'Please select a document first';
    }

    // This will be processed by AI
    return _extractedText;
  }

  Future<List<String>> getRecentDocuments() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await dir.list().toList();
      return files
          .where((f) => f is File && 
              (f.path.endsWith('.pdf') || 
               f.path.endsWith('.txt') || 
               f.path.endsWith('.doc') ||
               f.path.endsWith('.docx')))
          .map((f) => f.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  void clear() {
    _currentPdf = null;
    _lastFilePath = '';
    _lastFileName = '';
    _extractedText = '';
    _isLoading = false;
    debugPrint('🗑️ Document cleared');
  }

  void dispose() {
    clear();
    debugPrint('👋 Document Service disposed');
  }
}
