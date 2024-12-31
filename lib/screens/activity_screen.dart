import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _localImage;

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _localImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _localImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndSaveActivity({
    required Map<String, dynamic> activityData,
    String? docId,
  }) async {
    try {
      if (_localImage != null) {
        // Hochladen des Bildes zu Firebase Storage
        final String imageUrl =
            await _storageService.uploadImageToStorage(_localImage!);
        activityData['imageUrl'] = imageUrl; // Speichern der URL
      }

      if (docId == null) {
        await _firestoreService.addActivityWithData(activityData);
      } else {
        await _firestoreService.updateActivity(docId, activityData);
      }

      _nameController.clear();
      _durationController.clear();
      _distanceController.clear();
      _localImage = null;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    }
  }

  Future<void> _addOrUpdateActivity({
    String? docId,
    String? initialName,
    String? initialDuration,
    String? initialDistance,
    String? initialImageUrl,
  }) async {
    _nameController.text = initialName ?? '';
    _durationController.text = initialDuration ?? '';
    _distanceController.text = initialDistance ?? '';
    _localImage = null;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(docId == null
              ? 'Neue Aktivität hinzufügen'
              : 'Aktivität bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Aktivitätsname'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Dauer (in Minuten)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Distanz (in Kilometern, optional)'),
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
                if (_localImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _localImage!,
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
                              _localImage = null;
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
                    _durationController.text.isNotEmpty) {
                  final activityData = {
                    'name': _nameController.text,
                    'duration': _durationController.text,
                    'distance': _distanceController.text,
                    'timestamp': DateTime.now(),
                  };
                  await _uploadImageAndSaveActivity(
                    activityData: activityData,
                    docId: docId,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Bitte alle erforderlichen Felder ausfüllen')),
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
        title: const Text('Activity Tracker'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getActivitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Text(
                    'Zum Hinzufügen einer neuen Aktivität klicke auf das Plus.'));
          }

          final activities = snapshot.data?.docs ?? [];
          if (activities.isEmpty) {
            return const Center(
                child: Text(
                    'Zum Hinzufügen einer neuen Aktivität klicke auf das Plus.'));
          }

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activityData =
                  activities[index].data() as Map<String, dynamic>;
              final docId = activities[index].id;
              final name = activityData['name'] ?? '';
              final duration = activityData['duration'] ?? '';
              final distance = activityData['distance'] ?? '';
              final imageUrl = activityData['imageUrl'];

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
                      : const Icon(Icons.directions_run),
                  title: Text(name),
                  subtitle: Text(
                      'Dauer: $duration Minuten${distance.isNotEmpty ? '\nDistanz: $distance km' : ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _addOrUpdateActivity(
                          docId: docId,
                          initialName: name,
                          initialDuration: duration,
                          initialDistance: distance,
                          initialImageUrl: imageUrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(
                          context: context,
                          onConfirm: () async {
                            await _firestoreService.deleteActivity(docId);
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
        onPressed: () => _addOrUpdateActivity(),
        child: const Icon(Icons.add),
      ),
    );
  }

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
}
