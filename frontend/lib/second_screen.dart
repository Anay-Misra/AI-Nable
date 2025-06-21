import 'package:flutter/material.dart';
import 'lesson.dart';
import 'main.dart';

class SecondScreen extends StatelessWidget {
  final String fileName;

  const SecondScreen({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final lessonTitle = fileName.split('.').first;
    final alreadyExists = lessonList.any((l) => l.title == lessonTitle);

    if (!alreadyExists) {
      lessonList.insert(
        0,
        Lesson(title: lessonTitle, dateSaved: DateTime.now()),
      );
    }

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

                const Text(
                  'Taking look at the text....',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
                        'Uploaded: $fileName',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/simplified', arguments: lessonTitle);
                  },
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
                      flex: 4,
                      child: Container(
                        height: 12,
                        color: Colors.amber,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 12,
                        color: const Color(0xFF0A4B66),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  'Tobi is simplifying....',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
