// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_app/firebase_options.dart';

// Importieren Sie die ausgelagerten Bildschirme
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/habit_tracker_screen.dart';
import 'screens/sleep_tracker_screen.dart';
import 'screens/medication_organizer_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/notes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeneFit',
      theme: ThemeData(
        // Aktualisiertes Farbschema mit Pastellfarben
        primaryColor: Colors.pink.shade200,
        scaffoldBackgroundColor: Colors.pink.shade50,
        fontFamily: 'Roboto',
        // Aktualisierte TextTheme-Eigenschaften
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800]),
          titleMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[800]),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.grey[800]),
          titleTextStyle: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange.shade200,
          elevation: 5,
          foregroundColor: Colors.white,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(Colors.orange.shade200),
        ),
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthStateHandler(),
        '/home': (context) => const MyHomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/habitTracker': (context) => const HabitTrackerScreen(),
        '/medicationOrganizer': (context) => const MedicationOrganizerScreen(),
        '/activity': (context) => const ActivityScreen(),
        '/notes': (context) => const NotesScreen(),
        '/sleepTracker': (context) => const SleepTrackerScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firebase.initializeApp().asStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const LoginScreen();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
