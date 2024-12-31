import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  _SleepTrackerScreenState createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

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

  Future<void> _addOrUpdateSleepData({
    String? docId,
    String? initialHours,
    String? initialNote,
    DateTime? initialDate,
    String? initialImageUrl,
  }) async {
    _hoursController.text = initialHours ?? '';
    _noteController.text = initialNote ?? '';
    _selectedDate = initialDate ?? DateTime.now();
    _selectedImage = null;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(docId == null
              ? 'Schlafdaten hinzufügen'
              : 'Schlafdaten bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                          : 'Kein Datum ausgewählt',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        await _pickDate(context);
                        setDialogState(() {});
                      },
                      child: const Text('Datum auswählen'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Schlafstunden'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Notiz (optional)'),
                ),
                const SizedBox(height: 16),
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
                if (_hoursController.text.isNotEmpty && _selectedDate != null) {
                  final sleepData = {
                    'date': _selectedDate,
                    'hours': _hoursController.text,
                    'note': _noteController.text,
                  };

                  if (_selectedImage != null) {
                    final imageUrl = await _storageService
                        .uploadImageToStorage(_selectedImage!);
                    sleepData['imageUrl'] = imageUrl;
                  }

                  if (docId == null) {
                    await _firestoreService.addSleepDataWithData(sleepData);
                  } else {
                    await _firestoreService.updateSleepData(docId, sleepData);
                  }

                  _hoursController.clear();
                  _noteController.clear();
                  _selectedDate = null;
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Bitte alle Felder ausfüllen')),
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
        title: const Text('Sleep Tracker'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getSleepDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sleepData = snapshot.data?.docs ?? [];
          if (sleepData.isEmpty) {
            return const Center(
                child: Text(
                    'Zum Hinzufügen von neuen Schlafdaten klicke auf das Plus.'));
          }

          return ListView.builder(
            itemCount: sleepData.length,
            itemBuilder: (context, index) {
              final data = sleepData[index].data() as Map<String, dynamic>;
              final docId = sleepData[index].id;
              final date = (data['date'] as Timestamp?)?.toDate();
              final hours = data['hours'] ?? '';
              final note = data['note'] ?? '';
              final imageUrl = data['imageUrl'];

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
                      : const Icon(Icons.nights_stay),
                  title: Text(
                    date != null
                        ? '${date.day}.${date.month}.${date.year}: $hours Stunden'
                        : '$hours Stunden',
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: note.isNotEmpty ? Text(note) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _addOrUpdateSleepData(
                          docId: docId,
                          initialHours: hours,
                          initialNote: note,
                          initialDate: date,
                          initialImageUrl: imageUrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(
                          context: context,
                          onConfirm: () async {
                            await _firestoreService.deleteSleepData(docId);
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
        onPressed: () => _addOrUpdateSleepData(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
