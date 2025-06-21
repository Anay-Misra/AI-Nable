import 'package:flutter/material.dart';
import 'lesson.dart';
import 'widgets/lesson_card.dart'; // ✅ Correct widget import

class FavoritesScreen extends StatelessWidget {
  final List<Lesson> favorites;

  const FavoritesScreen({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    final onlyFavorites = favorites.where((lesson) => lesson.isFavorite).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔙 Back button and logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFDE802F)),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset("assets/logo.png", height: 40),
                const SizedBox(width: 40), // spacing placeholder
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Snap Study",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFDE802F)),
            ),
            const Text(
              "Favorites",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.orange, fontFamily: 'YourHandwrittenFont'),
            ),

            const SizedBox(height: 12),
            Image.asset("assets/bear_favorite.png", height: 100),
            const SizedBox(height: 16),

            // Favorite cards
            if (onlyFavorites.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    "No favorites yet!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              )
            else
              ...onlyFavorites.map((lesson) => LessonCard(lesson: lesson, type: "View")),
          ],
        ),
      ),
    );
  }
}
