import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Image.asset('assets/logo.png', height: 50),
                const SizedBox(height: 12),
                const Text(
                  'Snap Study',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDE802F),
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.orange,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'You do not have any files yet.\nLet\'s start by uploading your first lesson!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Image.asset('assets/bear.png', height: 280, fit: BoxFit.contain),
                const SizedBox(height: 4),
                const Text('.pdf, .jpg, .png'),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'png'],
                    );

                    if (result != null && result.files.single.path != null) {
                      final fileName = result.files.single.name;
                      final filePath = result.files.single.path!;
                      Navigator.pushNamed(context, '/second', arguments: {
                        'fileName': fileName,
                        'filePath': filePath,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF19D47),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Teach me Tobi!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LinearProgressIndicator(
                    value: 0.4,
                    backgroundColor: Colors.yellow,
                    color: const Color(0xFF0A4B66),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tobi is getting your lesson ready...',
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
