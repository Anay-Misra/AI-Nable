import 'package:flutter/material.dart';
import 'lesson.dart';
import 'package:intl/intl.dart';

class AudioFilesScreen extends StatelessWidget {
  final List<Lesson> audioLessons;

  const AudioFilesScreen({super.key, required this.audioLessons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔙 Back + Logo Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFDE802F)),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset("assets/logo.png", height: 40),
                const SizedBox(width: 40), // for symmetry
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              "Snap Study",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFDE802F)),
            ),
            const Text(
              "My Audio Files",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.orange, fontFamily: 'YourHandwrittenFont'),
            ),
            const SizedBox(height: 12),
            Image.asset("assets/bear_music.png", height: 100),

            const SizedBox(height: 16),
            ...audioLessons.map((lesson) => _buildAudioCard(lesson)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCard(Lesson lesson) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(lesson.dateSaved);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(lesson.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(formattedDate, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton("Listen"),
              _actionButton("Edit"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF19D47),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
