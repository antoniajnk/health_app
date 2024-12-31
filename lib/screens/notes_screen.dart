import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
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

  Future<void> _addOrUpdateNote({
    String? docId,
    String? initialTitle,
    String? initialContent,
    String? initialImageUrl,
  }) async {
    _titleController.text = initialTitle ?? '';
    _contentController.text = initialContent ?? '';
    _selectedImage = null;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              docId == null ? 'Neue Notiz hinzufügen' : 'Notiz bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Überschrift'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Fließtext'),
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
                if (_titleController.text.isNotEmpty &&
                    _contentController.text.isNotEmpty) {
                  final noteData = {
                    'title': _titleController.text,
                    'content': _contentController.text,
                    'timestamp':
                        Timestamp.now(), // Nutze den aktuellen Timestamp
                  };

                  if (_selectedImage != null) {
                    final imageUrl = await _storageService
                        .uploadImageToStorage(_selectedImage!);
                    noteData['imageUrl'] = imageUrl;
                  }

                  if (docId == null) {
                    await _firestoreService.addNoteWithData(noteData);
                  } else {
                    await _firestoreService.updateNote(docId, noteData);
                  }

                  _titleController.clear();
                  _contentController.clear();
                  _selectedImage = null; // Bild zurücksetzen
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notiz gespeichert!')),
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
        title: const Text('Notizen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Warte auf Daten...');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Fehler im Stream: ${snapshot.error}');
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('Zum Hinzufügen einer neuen Notiz klicke auf das Plus.');
            return const Center(
                child: Text(
                    'Zum Hinzufügen einer neuen Notiz klicke auf das Plus.'));
          }

          print('Notizen gefunden: ${snapshot.data!.docs.length}');

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteData = notes[index].data() as Map<String, dynamic>;
              final docId = notes[index].id;
              final title = noteData['title'] ?? '';
              final content = noteData['content'] ?? '';
              final imageUrl = noteData['imageUrl'];

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
                      : const Icon(Icons.note),
                  title: Text(title),
                  subtitle: Text(content,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _addOrUpdateNote(
                          docId: docId,
                          initialTitle: title,
                          initialContent: content,
                          initialImageUrl: imageUrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(
                          context: context,
                          onConfirm: () async {
                            await _firestoreService.deleteNote(docId);
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
        onPressed: () => _addOrUpdateNote(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
