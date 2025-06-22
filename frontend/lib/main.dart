import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';
import 'dashboard_screen.dart';
import 'second_screen.dart';
import 'simplified_output_screen.dart';
import 'favorites_screen.dart';
import 'chatbot_screen.dart';
import 'settings_screen.dart';
import 'lesson.dart';
import 'previous_uploads_screen.dart';

// ✅ Define global notifiers
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<double> textScaleFactorNotifier = ValueNotifier(1.0);

// ✅ Global lesson lists
List<Lesson> previousUploads = [];
List<Lesson> favoriteLessons = []; // Favorites will remain separate

void main() {
  runApp(const SnapStudyApp());
}

class SnapStudyApp extends StatelessWidget {
  const SnapStudyApp({super.key});

  Future<String> _getStartRoute() async {
    final prefs = await SharedPreferences.getInstance();

    final dark = prefs.getBool('darkMode') ?? false;
    themeNotifier.value = dark ? ThemeMode.dark : ThemeMode.light;

    final isLoggedIn = prefs.getBool('loggedIn') ?? false;
    return isLoggedIn ? '/dashboard' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getStartRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        final startRoute = snapshot.data!;

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return ValueListenableBuilder<double>(
              valueListenable: textScaleFactorNotifier,
              builder: (context, scale, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark().copyWith(
                    scaffoldBackgroundColor: const Color(0xFF121212),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Color(0xFF1F1F1F),
                    ),
                  ),
                  themeMode: mode,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                      child: child!,
                    );
                  },
                  initialRoute: startRoute,
                  onGenerateRoute: _generateRoute,
                );
              },
            );
          },
        );
      },
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/second':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['fileName'] == null || args['filePath'] == null) {
          return _errorRoute("Missing file information for /second");
        }
        return MaterialPageRoute(
          builder: (_) => SecondScreen(
            fileName: args['fileName'],
            filePath: args['filePath'],
          )
        );
      case '/simplified':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['title'] == null || args['extractedText'] == null) {
          return _errorRoute("Missing arguments for /simplified");
        }
        return MaterialPageRoute(
          builder: (_) => SimplifiedOutputScreen(arguments: args)
        );
      case '/previous_uploads':
        return MaterialPageRoute(builder: (_) => PreviousUploadsScreen(uploads: previousUploads));
      case '/summaries':
        // This route is deprecated and will be removed. For now, forward to the new screen.
        return MaterialPageRoute(builder: (_) => PreviousUploadsScreen(uploads: previousUploads));
      case '/audio':
        // This route is deprecated and will be removed. For now, forward to the new screen.
        return MaterialPageRoute(builder: (_) => PreviousUploadsScreen(uploads: previousUploads));
      case '/favorites':
        return MaterialPageRoute(builder: (_) => FavoritesScreen(favorites: favoriteLessons));
      case '/chatbot':
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return _errorRoute("Route not found");
    }
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message, style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
