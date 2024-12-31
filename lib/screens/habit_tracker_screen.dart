import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final TextEditingController _nameController = TextEditingController();
  String _frequency = 'Täglich';
  File? _selectedImage;

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addOrUpdateHabit({
    String? docId,
    String? initialName,
    String? initialFrequency,
    String? initialImageUrl,
  }) async {
    _nameController.text = initialName ?? '';
    _frequency = initialFrequency ?? 'Täglich';
    _selectedImage = null;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              docId == null ? 'Neuen Habit hinzufügen' : 'Habit bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Habit-Name'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequenz',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Täglich', child: Text('Täglich')),
                    DropdownMenuItem(
                        value: 'Wöchentlich', child: Text('Wöchentlich')),
                    DropdownMenuItem(
                        value: 'Monatlich', child: Text('Monatlich')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _frequency = value!);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImageFromGallery();
                        setDialogState(() {}); // Aktualisiere den Dialog
                      },
                      child: const Text('Galerie'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImageFromCamera();
                        setDialogState(() {}); // Aktualisiere den Dialog
                      },
                      child: const Text('Kamera'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  final habitData = {
                    'name': _nameController.text,
                    'frequency': _frequency,
                    'timestamp':
                        Timestamp.now(), // Korrekte Speicherung des Timestamps
                    'isCompleted': false,
                  };

                  if (_selectedImage != null) {
                    final imageUrl = await _storageService
                        .uploadImageToStorage(_selectedImage!);
                    habitData['imageUrl'] = imageUrl;
                  }

                  if (docId == null) {
                    await _firestoreService.addHabitWithData(habitData);
                  } else {
                    await _firestoreService.updateHabit(docId, habitData);
                  }

                  _nameController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Bitte einen Habit-Namen eingeben')),
                  );
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Löschen bestätigen'),
          content: const Text('Möchten Sie diesen Eintrag wirklich löschen?'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), // Abbrechen
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog schließen
                onConfirm(); // Löschfunktion ausführen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getHabitsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Keine Habits gefunden. Fügen Sie einen hinzu.'));
          }

          final habits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habitData = habits[index].data() as Map<String, dynamic>;
              final docId = habits[index].id;
              final habitName = habitData['name'] ?? '';
              final frequency = habitData['frequency'] ?? '';
              final imageUrl = habitData['imageUrl'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  title: Text(habitName),
                  subtitle: Text('Frequenz: $frequency'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _addOrUpdateHabit(
                          docId: docId,
                          initialName: habitName,
                          initialFrequency: frequency,
                          initialImageUrl: imageUrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(
                          context: context,
                          onConfirm: () async {
                            await _firestoreService.deleteHabit(docId);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateHabit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
