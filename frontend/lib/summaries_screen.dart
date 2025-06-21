import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'lesson.dart';
import 'widgets/lesson_card.dart'; // ✅ Import reusable LessonCard

class SummariesScreen extends StatelessWidget {
  final List<Lesson> summaries;

  const SummariesScreen({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔙 Back Button + Logo Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFDE802F)),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset("assets/logo.png", height: 40),
                const SizedBox(width: 40), // Spacer
              ],
            ),
            const SizedBox(height: 8),

            // 🔸 Title
            const Text(
              "Snap Study",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDE802F),
              ),
            ),
            const Text(
              "My Summaries",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),

            // 🔸 Content
            if (summaries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    "No summaries yet!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...summaries.map(
                (lesson) => LessonCard(lesson: lesson, type: "Read"), // ✅ Use reusable LessonCard
              ),
          ],
        ),
      ),
    );
  }
}
