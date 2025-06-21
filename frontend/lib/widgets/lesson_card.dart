import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../lesson.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final String type;

  const LessonCard({super.key, required this.lesson, required this.type});

  @override
  Widget build(BuildContext context) {
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
          Text(lesson.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(formattedDate, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton(type),
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
