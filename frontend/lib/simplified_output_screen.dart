import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'api_service.dart';
import 'lesson.dart';
import 'main.dart'; // for lessonList
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SimplifiedOutputScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const SimplifiedOutputScreen({super.key, required this.arguments});

  @override
  State<SimplifiedOutputScreen> createState() => _SimplifiedOutputScreenState();
}

class _SimplifiedOutputScreenState extends State<SimplifiedOutputScreen> {
  late Lesson lesson;
  String _extractedText = '';
  String _simplifiedText = '';
  List<Map<String, String>> _keyTerms = [];
  List<String> _stepByStep = [];
  String? _visualImageBase64;
  String _currentMode = 'simplified';
  bool _isProcessing = false;
  String? _errorMessage;

  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  bool _isNarrationLoading = false;

  @override
  void initState() {
    super.initState();
    _extractedText = widget.arguments['extractedText'] ?? '';
    final title = widget.arguments['title'] ?? 'Unknown';
    
    lesson = Lesson(
      title: title,
      dateSaved: DateTime.now(),
      originalContent: _extractedText,
    );

    if (!previousUploads.any((l) => l.title == title)) {
      previousUploads.insert(0, lesson);
    }
    
    _simplifiedText = lesson.simplifiedText;
    _keyTerms = lesson.keyTerms;
    _stepByStep = lesson.stepByStep;
    _visualImageBase64 = lesson.visualImageBase64;

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    if (lesson.simplifiedText.isEmpty) {
      _simplifyText();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _simplifyText() async {
    if (_extractedText.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.simplifyText(_extractedText, lesson.title);
      
      setState(() {
        _simplifiedText = result['simplified_text'] ?? '';
        var terms = result['key_terms'] as List<dynamic>? ?? [];
        _keyTerms = terms.map((term) => Map<String, String>.from(term)).toList();
        _stepByStep = List<String>.from(result['step_by_step'] ?? []);
        _isProcessing = false;
        
        lesson.simplifiedText = _simplifiedText;
        lesson.keyTerms = _keyTerms;
        lesson.stepByStep = _stepByStep;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error simplifying text: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _generateVisual() async {
    if (_simplifiedText.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.generateVisualModel(_simplifiedText);
      
      setState(() {
        _visualImageBase64 = result['image_base64'];
        _isProcessing = false;
        
        lesson.visualImageBase64 = _visualImageBase64;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error generating visual: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _playNarration() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }

    if (_playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }

    setState(() => _isNarrationLoading = true);
    try {
      final textToNarrate = _getCurrentContent();
      final audioBase64 = await ApiService.narrateText(textToNarrate);
      
      if (audioBase64.isEmpty) {
        throw Exception("Received empty audio data");
      }
      
      final audioBytes = base64Decode(audioBase64);
      
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // For iOS, save to a file first
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/narration.mp3');
        await tempFile.writeAsBytes(audioBytes, flush: true);
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
      } else {
        // For other platforms, play from bytes directly
        await _audioPlayer.play(BytesSource(audioBytes));
      }
      
    } catch (e) {
      if (!mounted) return;
      print("Error in _playNarration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating or playing audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if(mounted) setState(() => _isNarrationLoading = false);
    }
  }

  Future<void> _stopNarration() async {
    try {
      await _audioPlayer.stop();
      print("Audio playback stopped");
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  void toggleFavorite() {
    setState(() {
      lesson.isFavorite = !lesson.isFavorite;
      if (lesson.isFavorite) {
        if (!favoriteLessons.any((l) => l.title == lesson.title)) {
          favoriteLessons.insert(0, lesson);
        }
      } else {
        favoriteLessons.removeWhere((l) => l.title == lesson.title);
      }
    });
  }

  String _getCurrentContent() {
    switch (_currentMode) {
      case 'simplified':
        return _simplifiedText;
      case 'key_terms':
        return _keyTerms.map((term) => '${term['term']}: ${term['definition']}').join('\n\n');
      case 'step':
        return _stepByStep.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
      case 'visual':
        return 'Visual representation';
      default:
        return _simplifiedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        title: const Text("Simplified Output", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Color(0xFFDE802F)),
        actions: [
          IconButton(
            icon: Icon(
              lesson.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: lesson.isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: toggleFavorite,
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Image.asset('assets/bear_pdf.png', height: 90),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDE802F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Yay! Tobi has simplified your text!\nHow do you want to view it?",
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _ModeChip(
                          label: 'Simplified Paragraph',
                          color: const Color(0xFF996633),
                          isSelected: _currentMode == 'simplified',
                          onTap: () => setState(() {
                            _currentMode = 'simplified';
                            _errorMessage = null;
                          }),
                        ),
                        _ModeChip(
                          label: 'Key Terms',
                          color: const Color(0xFF87CEEB),
                          isSelected: _currentMode == 'key_terms',
                          onTap: () => setState(() {
                            _currentMode = 'key_terms';
                            _errorMessage = null;
                          }),
                        ),
                        _ModeChip(
                          label: 'Step-by-step Explanation',
                          color: const Color(0xFFF3C64E),
                          isSelected: _currentMode == 'step',
                          onTap: () => setState(() {
                            _currentMode = 'step';
                            _errorMessage = null;
                          }),
                        ),
                        _ModeChip(
                          label: 'Visual Storytelling',
                          color: const Color(0xFF90C9B7),
                          isSelected: _currentMode == 'visual',
                          onTap: () {
                            setState(() => _currentMode = 'visual');
                            if (_visualImageBase64 == null) {
                              _generateVisual();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Output:", style: TextStyle(color: Colors.orange)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: screenWidth * 0.9,
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.25,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isProcessing
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDE802F)),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Processing...'),
                                ],
                              ),
                            )
                          : _errorMessage != null
                              ? Center(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _currentMode == 'visual'
                                  ? _visualImageBase64 != null
                                      ? Image.memory(base64Decode(_visualImageBase64!))
                                      : const Center(child: Text("No visual generated yet."))
                                  : Text(
                                      _getCurrentContent(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            // Audio Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volume_up, color: Color(0xFFDE802F)),
                      const SizedBox(width: 8),
                      const Text("Listen to Tobi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _isNarrationLoading ? null : _playNarration,
                        icon: _isNarrationLoading
                            ? const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDE802F)),
                                ),
                              )
                            : Icon(
                                _playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
                                size: 48,
                              ),
                        color: const Color(0xFFDE802F),
                      ),
                      IconButton(
                        onPressed: _playerState == PlayerState.playing || _playerState == PlayerState.paused ? _stopNarration : null,
                        icon: Icon(
                          Icons.stop,
                          size: 32,
                          color: _playerState == PlayerState.playing || _playerState == PlayerState.paused
                              ? const Color(0xFFDE802F) 
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _playerState == PlayerState.playing 
                        ? "Playing audio..." 
                        : _playerState == PlayerState.paused 
                            ? "Audio paused"
                            : "Tap play to hear Tobi read",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  height: 6,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isProcessing ? "Tobi is working..." : "Tobi has simplified!",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton("Return to Dashboard", () {
                      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                    }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF19D47),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label, 
    required this.color, 
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          label, 
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )
        ),
        backgroundColor: isSelected ? color.withOpacity(0.8) : color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
