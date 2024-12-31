import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  User? currentUser = FirebaseAuth.instance.currentUser;
  File? _profileImage;
  String? _email;
  DateTime? _birthDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileData = await _firestoreService.getUserProfile();

      setState(() {
        _email = profileData['email'] ?? currentUser?.email;
        _birthDate = profileData['birthDate'] != null
            ? (profileData['birthDate'] as Timestamp).toDate()
            : null;

        if (profileData['profileImagePath'] != null) {
          _profileImage = File(profileData['profileImagePath']);
        }
      });
    } catch (e) {
      print('Fehler beim Laden der Profildaten: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await _firestoreService.updateUserProfile({
        'profileImagePath': pickedFile.path,
      });
    }
  }

  Future<void> _pickBirthDate() async {
    DateTime initialDate = _birthDate ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
      });

      await _firestoreService.updateUserProfile({
        'birthDate': Timestamp.fromDate(pickedDate),
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abmeldung erfolgreich')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickProfileImage,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Profilbild bearbeiten'),
            ),
            const SizedBox(height: 16),
            Text(
              _email ?? 'Keine E-Mail verfügbar',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Geburtsdatum: ',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'
                      : 'Nicht festgelegt',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _pickBirthDate,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Abmelden'),
            ),
          ],
        ),
      ),
    );
  }
}
