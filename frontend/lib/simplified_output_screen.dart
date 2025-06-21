import 'package:flutter/material.dart';
import 'lesson.dart';
import 'main.dart'; // for lessonList

class SimplifiedOutputScreen extends StatefulWidget {
  final String title;

  const SimplifiedOutputScreen({super.key, required this.title});

  @override
  State<SimplifiedOutputScreen> createState() => _SimplifiedOutputScreenState();
}

class _SimplifiedOutputScreenState extends State<SimplifiedOutputScreen> {
  late Lesson lesson;

  @override
  void initState() {
    super.initState();
    lesson = lessonList.firstWhere(
      (l) => l.title == widget.title,
      orElse: () {
        final newLesson = Lesson(title: widget.title, dateSaved: DateTime.now());
        lessonList.insert(0, newLesson);
        return newLesson;
      },
    );
  }

  void toggleFavorite() {
    setState(() {
      lesson.isFavorite = !lesson.isFavorite;
    });
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
            const SizedBox(height: 4),
            Image.asset('assets/bear_pdf.png', height: 90),

            const SizedBox(height: 4),
            Text(
              widget.title,
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
              children: const [
                _ModeChip(label: 'Simplified Paragraph', color: Color(0xFF996633)),
                _ModeChip(label: 'Bullet Point Summary', color: Color(0xFF87CEEB)),
                _ModeChip(label: 'Step-by-step Explanation', color: Color(0xFFF3C64E)),
                _ModeChip(label: 'Visual Storytelling', color: Color(0xFF90C9B7)),
              ],
            ),

            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Output:", style: TextStyle(color: Colors.orange)),
            ),

            const SizedBox(height: 6),
            Container(
              width: screenWidth * 0.9,         // Wider
              height: screenHeight * 0.30,      // Taller
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "This is your simplified content...",
                style: TextStyle(fontSize: 16),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text("Listen", style: TextStyle(fontSize: 14)),
                Icon(Icons.volume_up),
                Icon(Icons.skip_previous),
                Icon(Icons.play_arrow),
                Icon(Icons.skip_next),
              ],
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
                const Text("Tobi has simplified!", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton("Simplify even more!", () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Coming soon...")),
                      );
                    }),
                    _actionButton("Return to Dashboard", () {
                      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                    }),
                  ],
                ),
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

  const _ModeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.black)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
