import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_app/home_screen.dart';



// Füge hier deine Bildschirm-Imports hinzu (z.B. HomeScreen, LoginScreen, RegisterScreen, usw.)
// import 'screens/...';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase initialisieren
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeneFit',
      theme: ThemeData(
        fontFamily: 'Helvetica',
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      // Routen werden hier definiert
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthStateHandler(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/habitTracker': (context) => const HabitTrackerScreen(),
        '/medicationOrganizer': (context) => const MedicationOrganizerScreen(),
        '/activity': (context) => const ActivityScreen(),
        '/addHabit': (context) => const AddHabitScreen(),
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const LoginScreen() : const HomeScreen();
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        print("Login fehlgeschlagen: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmelden'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bitte anmelden',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passwort',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text('Anmelden'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: const Text('Noch kein Konto? Registrieren'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        print("Registrierung fehlgeschlagen: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrieren'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bitte registrieren',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passwort',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text('Registrieren'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text('Abmelden'),
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BeneFit',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
            SizedBox(
              height: 165,
              child: HomeButton(
                label: 'MEDICATION TRACKER',
                imagePath: 'assets/images/medication_organizer.jpg',
                onPressed: () {
                  Navigator.pushNamed(context, '/medicationOrganizer');
                },
              ),
            ),
            const SizedBox(height: 16),
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
      backgroundColor: Colors.green.shade50,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      await prefs.setBool('isLoggedIn', true);

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bitte einloggen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nutzername',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passwort',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text('Anmelden'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class HomeButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onPressed;

  const HomeButton({
    required this.label,
    required this.imagePath,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


// Sleep Tracker Screen
class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  _SleepTrackerScreenState createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  List<Map<String, dynamic>> sleepData = [];
  final TextEditingController _controller = TextEditingController();

  void _addSleepData() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        sleepData.add({
          'hours': _controller.text,
          'date': DateTime.now(),
        });
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schlafstunden hinzufügen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Anzahl der Stunden'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addSleepData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text('Speichern'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sleepData.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${sleepData[index]['hours']} Stunden'),
                      subtitle: Text(
                        'Datum: ${sleepData[index]['date'].toString().split(' ')[0]}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

// Andere Screens bleiben unverändert
class MedicationOrganizerScreen extends StatefulWidget {
  const MedicationOrganizerScreen({super.key});

  @override
  _MedicationOrganizerScreenState createState() =>
      _MedicationOrganizerScreenState();
}

class _MedicationOrganizerScreenState extends State<MedicationOrganizerScreen> {
  List<Map<String, dynamic>> medications = [];
  final TextEditingController _controller = TextEditingController();
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addMedication() {
    setState(() {
      medications.add({
        'name': _controller.text,
        'image': _image,
      });
      _controller.clear();
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Organizer'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medikament hinzufügen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Medikament eingeben'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                  child: const Text('Foto aufnehmen'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                  child: const Text('Foto aus Galerie'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMedication,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text('Medikament hinzufügen'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(medications[index]['name']),
                    leading: medications[index]['image'] != null
                        ? Image.file(medications[index]['image']!)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class HabitTrackerScreen extends StatelessWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        backgroundColor: Colors.green.shade700,
      ),
      body: const Center(child: Text('Habit Tracker Content')),
      backgroundColor: Colors.green.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addHabit');
        },
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<String> activities = [];
  final TextEditingController _controller = TextEditingController();

  void _addActivity() {
    setState(() {
      activities.add(_controller.text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivität hinzufügen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Aktivität eingeben'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addActivity,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text('Aktivität hinzufügen'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(activities[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class AddHabitScreen extends StatelessWidget {
  const AddHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        backgroundColor: Colors.green.shade700,
      ),
      body: const Center(child: Text('Add Habit Content')),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<String> notes = [];
  final TextEditingController _noteController = TextEditingController();

  void _addNote() {
    setState(() {
      if (_noteController.text.isNotEmpty) {
        notes.add(_noteController.text);
        _noteController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Neue Notiz hinzufügen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(hintText: 'Notiz eingeben'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addNote,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              child: const Text('Notiz hinzufügen'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(notes[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}
