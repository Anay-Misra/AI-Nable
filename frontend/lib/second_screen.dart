import 'package:flutter/material.dart';
import 'dart:io';
import 'api_service.dart';
import 'lesson.dart';
import 'main.dart';

class SecondScreen extends StatefulWidget {
  final String fileName;
  final String? filePath;

  const SecondScreen({super.key, required this.fileName, this.filePath});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  bool _isProcessing = false;
  String _extractedText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processFile();
  }

  Future<void> _processFile() async {
    if (widget.filePath == null) {
      setState(() {
        _errorMessage = 'No file path provided';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final file = File(widget.filePath!);
      final result = await ApiService.uploadFile(file);
      final extractedText = result['extracted_text'] ?? '';
      
      setState(() {
        _extractedText = extractedText;
        _isProcessing = false;
      });
    } catch (e) {
      // Extract a cleaner error message
      final errorMessage = e.toString().replaceFirst("Exception: Upload failed: ", "");
      setState(() {
        _errorMessage = errorMessage;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back Button + Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.orange),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Image.asset('assets/logo.png', height: 40),
                    const SizedBox(width: 40), // placeholder for symmetry
                  ],
                ),
                const SizedBox(height: 12),

                const Text(
                  'Snap Study',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDE802F),
                    fontFamily: 'YourFigmaFont',
                  ),
                ),
                const Text(
                  'Text Extraction',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.orange,
                    fontFamily: 'YourFigmaFont2',
                  ),
                ),
                const SizedBox(height: 16),

                if (_isProcessing) ...[
                  const Text(
                    'Tobi is analyzing your document...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDE802F)),
                  ),
                ] else if (_errorMessage != null) ...[
                  Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _processFile,
                    child: const Text('Retry'),
                  ),
                ] else ...[
                  const Text(
                    'Text extracted successfully!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                Image.asset(
                  'assets/bear_pdf.png',
                  height: 180,
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Is this what you want to simplify?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uploaded: ${widget.fileName}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                      if (_extractedText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Extracted text preview:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _extractedText.length > 100 
                              ? '${_extractedText.substring(0, 100)}...'
                              : _extractedText,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _extractedText.isNotEmpty && !_isProcessing
                      ? () {
                          Navigator.pushNamed(
                            context, 
                            '/simplified', 
                            arguments: {
                              'title': widget.fileName.split('.').first,
                              'extractedText': _extractedText,
                            }
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF19D47),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Yes! Simplify!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                const SizedBox(height: 24),

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      flex: _isProcessing ? 4 : 7,
                      child: Container(
                        height: 12,
                        color: Colors.amber,
                      ),
                    ),
                    Expanded(
                      flex: _isProcessing ? 3 : 0,
                      child: Container(
                        height: 12,
                        color: const Color(0xFF0A4B66),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  _isProcessing ? 'Tobi is extracting text....' : 'Ready to simplify!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
