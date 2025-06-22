import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'main.dart'; // for lessonList

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/logo.png', height: 70),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFFDE802F)),
                      iconSize: 32.0,
                      padding: const EdgeInsets.all(8),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Text(
                  'Snap Study',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDE802F),
                  ),
                ),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.orange,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Dashboard Buttons
                DashboardButton(
                  icon: Icons.history,
                  label: 'Previous Uploads',
                  onTap: () {
                    Navigator.pushNamed(context, '/previous_uploads');
                  },
                ),
                DashboardButton(
                  icon: Icons.favorite,
                  label: 'Favorites',
                  onTap: () {
                    Navigator.pushNamed(context, '/favorites');
                  },
                ),
                DashboardButton(
                  icon: Icons.question_answer,
                  label: 'Ask Tobi Chatbot',
                  onTap: () {
                    Navigator.pushNamed(context, '/chatbot');
                  },
                ),

                const SizedBox(height: 14),

                // 🔹 Upload Icon & Bear Image Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset('assets/upload_icon.png', height: 240, width: screenWidth * 0.35),
                    Image.asset('assets/bear_learning.png', height: 240, width: screenWidth * 0.35),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Upload Button
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                    );

                    if (result != null && result.files.single.path != null) {
                      String fileName = result.files.single.name;
                      String filePath = result.files.single.path!;
                      
                      Navigator.pushNamed(
                        context,
                        '/second',
                        arguments: {
                          'fileName': fileName,
                          'filePath': filePath,
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF19D47),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Teach me Tobi!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20), // Add bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF19D47)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
