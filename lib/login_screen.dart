import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Beispiel: Zurück zur Startseite navigieren
            Navigator.pushNamed(context, '/home');
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}