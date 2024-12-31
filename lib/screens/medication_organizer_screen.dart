import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';

class MedicationOrganizerScreen extends StatefulWidget {
  const MedicationOrganizerScreen({super.key});

  @override
  _MedicationOrganizerScreenState createState() =>
      _MedicationOrganizerScreenState();
}

class _MedicationOrganizerScreenState extends State<MedicationOrganizerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
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

  // Vorschau für Bilder
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Image.network(imageUrl, fit: BoxFit.contain),
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
      ),
    );
  }

  // Hinzufügen oder Aktualisieren von Medikamenten
  Future<void> _addOrUpdateMedication({
    String? docId,
    String? initialName,
    String? initialDose,
    String? initialDuration,
    String? initialImageUrl,
  }) async {
    _nameController.text = initialName ?? '';
    _doseController.text = initialDose ?? '';
    _durationController.text = initialDuration ?? '';
    _selectedImage = null;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(docId == null
              ? 'Medikament hinzufügen'
              : 'Medikament bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Medikamentenname'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _doseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Dosis'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Einnahmedauer'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImageFromGallery();
                        setDialogState(() {});
                      },
                      child: const Text('Galerie'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImageFromCamera();
                        setDialogState(() {});
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
                if (_nameController.text.isNotEmpty &&
                    _doseController.text.isNotEmpty &&
                    _durationController.text.isNotEmpty) {
                  final medicationData = {
                    'name': _nameController.text,
                    'dose': _doseController.text,
                    'duration': _durationController.text,
                    'timestamp': Timestamp.now(),
                  };

                  if (_selectedImage != null) {
                    final imageUrl = await _storageService
                        .uploadImageToStorage(_selectedImage!);
                    medicationData['imageUrl'] = imageUrl;
                  }

                  if (docId == null) {
                    await _firestoreService
                        .addMedicationWithData(medicationData);
                  } else {
                    await _firestoreService.updateMedication(
                        docId, medicationData);
                  }

                  _nameController.clear();
                  _doseController.clear();
                  _durationController.clear();
                  _selectedImage = null;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medikament gespeichert!')),
                  );
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

// Bestätigungsdialog für Löschen
  Future<void> _showDeleteConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: const Text('Möchten Sie diesen Eintrag wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Organizer'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getMedicationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
                    'Zum Hinzufügen eines neuen Medikaments klicke auf das Plus.'));
          }

          final medications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medicationData =
                  medications[index].data() as Map<String, dynamic>;
              final docId = medications[index].id;
              final name = medicationData['name'] ?? '';
              final dose = medicationData['dose'] ?? '';
              final duration = medicationData['duration'] ?? '';
              final imageUrl = medicationData['imageUrl'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: imageUrl != null
                      ? GestureDetector(
                          onTap: () => _showImagePreview(imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(Icons.medication),
                  title: Text(name),
                  subtitle: Text(
                    'Dosis: $dose\nDauer: $duration',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _addOrUpdateMedication(
                          docId: docId,
                          initialName: name,
                          initialDose: dose,
                          initialDuration: duration,
                          initialImageUrl: imageUrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(
                          context: context,
                          onConfirm: () async {
                            await _firestoreService.deleteMedication(docId);
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
        onPressed: () => _addOrUpdateMedication(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
