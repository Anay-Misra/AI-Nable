import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // for themeNotifier and textScaleFactorNotifier


class SettingsScreen extends StatefulWidget {
 const SettingsScreen({super.key});


 @override
 State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
 bool isDarkMode = false;


 @override
 void initState() {
   super.initState();
   _loadPreferences();
 }


 Future<void> _loadPreferences() async {
   final prefs = await SharedPreferences.getInstance();
   final dark = prefs.getBool('darkMode') ?? false;
   setState(() => isDarkMode = dark);
 }


 Future<void> _setTheme(bool dark) async {
   final prefs = await SharedPreferences.getInstance();
   setState(() => isDarkMode = dark);
   await prefs.setBool('darkMode', dark);
   themeNotifier.value = dark ? ThemeMode.dark : ThemeMode.light;
 }


 @override
 Widget build(BuildContext context) {
   final isDark = Theme.of(context).brightness == Brightness.dark;
   final textSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 16;


   return Scaffold(
     backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
     body: SafeArea(
       child: SingleChildScrollView(
         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // Top Row
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 IconButton(
                   icon: const Icon(Icons.arrow_back, color: Color(0xFFDE802F)),
                   onPressed: () => Navigator.pop(context),
                 ),
                 Image.asset('assets/logo.png', height: 40),
               ],
             ),


             const SizedBox(height: 12),
             Center(
               child: Column(
                 children: const [
                   Text(
                     'Snap Study',
                     style: TextStyle(
                       fontSize: 32,
                       fontWeight: FontWeight.bold,
                       color: Color(0xFFDE802F),
                     ),
                   ),
                   Text(
                     'Settings',
                     style: TextStyle(
                       fontSize: 20,
                       color: Colors.orange,
                       fontFamily: 'monospace',
                     ),
                   ),
                 ],
               ),
             ),


             const SizedBox(height: 24),


             _sectionTitle("Theme", Icons.settings),
             _themeButton("Dark Mode 🌙", true),
             _themeButton("Light Mode ☀️", false),


             const SizedBox(height: 20),


             _sectionTitle("Accessibility", Icons.settings),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               decoration: _orangeBoxStyle(),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("Text size", style: TextStyle(fontSize: textSize, color: Colors.black)),
                   Row(
                     children: [
                       IconButton(
                         onPressed: () {
                           setState(() {
                             textScaleFactorNotifier.value += 0.1;
                           });
                         },
                         icon: const Icon(Icons.add, color: Colors.black),
                       ),
                       IconButton(
                         onPressed: () {
                           setState(() {
                             textScaleFactorNotifier.value =
                                 textScaleFactorNotifier.value > 1.0
                                     ? textScaleFactorNotifier.value - 0.1
                                     : 1.0;
                           });
                         },
                         icon: const Icon(Icons.remove, color: Colors.black),
                       ),
                     ],
                   )
                 ],
               ),
             ),


             const SizedBox(height: 24),


             Center(
               child: ElevatedButton(
                 onPressed: () async {
                   final prefs = await SharedPreferences.getInstance();
                   await prefs.setBool('loggedIn', false);
                   if (!mounted) return;
                   Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFFF19D47),
                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                 ),
                 child: const Text('LOGOUT', style: TextStyle(color: Colors.black)),
               ),
             ),


             const SizedBox(height: 24),
             Center(child: Image.asset('assets/bear_tools.png', height: 150)),
           ],
         ),
       ),
     ),
   );
 }


 Widget _themeButton(String label, bool value) {
   return GestureDetector(
     onTap: () => _setTheme(value),
     child: Container(
       margin: const EdgeInsets.symmetric(vertical: 6),
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
       decoration: BoxDecoration(
         color: isDarkMode == value ? const Color(0xFFF19D47) : Colors.grey.shade300,
         borderRadius: BorderRadius.circular(30),
       ),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
           Icon(value ? Icons.nightlight : Icons.wb_sunny, color: Colors.black),
         ],
       ),
     ),
   );
 }


 Widget _sectionTitle(String title, IconData icon) {
   return Row(
     children: [
       Icon(icon, color: const Color(0xFFF19D47)),
       const SizedBox(width: 8),
       Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
     ],
   );
 }


 BoxDecoration _orangeBoxStyle() => BoxDecoration(
       color: Colors.orange.shade300,
       borderRadius: BorderRadius.circular(30),
     );
}


