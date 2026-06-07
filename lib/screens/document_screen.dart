import 'package:flutter/material.dart';
import '../services/document_service.dart';
import '../services/ai_document_service.dart';
import '../theme/app_theme.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final DocumentService _documentService = DocumentService();
  final AIDocumentService _aiService = AIDocumentService();
  
  String _summary = '';
  String _selectedType = 'short';
  bool _isLoading = false;

  final List<Map<String, String>> _summaryTypes = [
    {'value': 'short', 'label': 'Short Summary'},
    {'value': 'detailed', 'label': 'Detailed'},
    {'value': 'bullets', 'label': 'Bullet Points'},
    {'value': 'explain', 'label': 'Simple Explain'},
  ];

  Future<void> _pickAndSummarize() async {
    setState(() {
      _isLoading = true;
      _summary = '';
    });

    final result = await _documentService.pickDocument();
    
    if (result == null || result.startsWith('Error')) {
      setState(() {
        _isLoading = false;
        _summary = result ?? 'No document selected';
      });
      return;
    }

    // Get summary from AI
    final summary = await _aiService.summarize(
      _documentService.extractedText,
      _selectedType,
    );

    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        title: const Text('Document Reader'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Type Selector
            Card(
              color: AppTheme.bgSecondary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary Type:',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _summaryTypes.map((type) {
                        final isSelected = _selectedType == type['value'];
                        return ChoiceChip(
                          label: Text(type['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type['value']!;
                              });
                            }
                          },
                          backgroundColor: AppTheme.bgPrimary,
                          selectedColor: AppTheme.primaryCyan,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pick Document Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndSummarize,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_isLoading ? 'Processing...' : 'Pick Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Document Info
            if (_documentService.lastFileName.isNotEmpty)
              Card(
                color: AppTheme.bgSecondary,
                child: ListTile(
                  leading: const Icon(Icons.description, color: AppTheme.primaryCyan),
                  title: Text(
                    _documentService.lastFileName,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    '${_documentService.extractedText.length} characters',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Summary Result
            if (_summary.isNotEmpty)
              Expanded(
                child: Card(
                  color: AppTheme.bgSecondary,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AI Summary:',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: AppTheme.primaryCyan),
                              onPressed: () {
                                // Copy to clipboard
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied to clipboard')),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(color: AppTheme.textSecondary),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _summary,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
