// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'home_button.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BeneFit',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.person, color: Colors.grey[800]),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // HABIT TRACKER Button
            SizedBox(
              height: 165,
              child: HomeButton(
                label: 'HABIT TRACKER',
                imagePath: 'assets/images/habit_tracker.jpg',
                onPressed: () {
                  Navigator.pushNamed(context, '/habitTracker');
                },
              ),
            ),
            const SizedBox(height: 16),
            // MEDICATION ORGANIZER Button
            SizedBox(
              height: 165,
              child: HomeButton(
                label: 'MEDICATION ORGANIZER',
                imagePath: 'assets/images/medication_organizer.jpg',
                onPressed: () {
                  Navigator.pushNamed(context, '/medicationOrganizer');
                },
              ),
            ),
            const SizedBox(height: 16),
            // ACTIVITY TRACKER Button
            SizedBox(
              height: 165,
              child: HomeButton(
                label: 'ACTIVITY TRACKER',
                imagePath: 'assets/images/activity.jpg',
                onPressed: () {
                  Navigator.pushNamed(context, '/activity');
                },
              ),
            ),
            const SizedBox(height: 16),
            // NOTES & LISTS Button
            SizedBox(
              height: 165,
              child: HomeButton(
                label: 'NOTES & LISTS',
                imagePath: 'assets/images/notes.jpg',
                onPressed: () {
                  Navigator.pushNamed(context, '/notes');
                },
              ),
            ),
            const SizedBox(height: 16),
            // SLEEP TRACKER Button
            SizedBox(
              height: 165,
              child: HomeButton(
                label: 'SLEEP TRACKER',
                imagePath: 'assets/images/sleep.jpg',
                onPressed: () {
                  Navigator.pushNamed(context, '/sleepTracker');
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
