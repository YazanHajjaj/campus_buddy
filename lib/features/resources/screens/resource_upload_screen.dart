import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ResourceUploadScreen extends StatefulWidget {
  const ResourceUploadScreen({super.key});

  @override
  State<ResourceUploadScreen> createState() => _ResourceUploadScreenState();
}

class _ResourceUploadScreenState extends State<ResourceUploadScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _courseController = TextEditingController();

  String _category = 'Math';
  File? _pickedFile;
  bool _uploading = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    setState(() {
      _pickedFile = File(result.files.single.path!);
    });
  }

  Future<void> _upload() async {
    if (_pickedFile == null || _titleController.text.isEmpty) return;

    setState(() => _uploading = true);

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storagePath = 'resources/$fileName.pdf';

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref(storagePath);
      await ref.putFile(_pickedFile!);
      final downloadUrl = await ref.getDownloadURL();

      // Save Firestore document
      await FirebaseFirestore.instance.collection('resources').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _category,
        'courseCode': _courseController.text.trim(),
        'fileUrl': downloadUrl,
        'storagePath': storagePath,
        'mimeType': 'application/pdf',
        'sizeInBytes': await _pickedFile!.length(),
        'tags': [],
        'department': 'COE',

        // Counters
        'viewCount': 0,
        'downloadCount': 0,

        // Visibility
        'isActive': true,
        'isPublic': true,

        // Meta
        'uploaderUserId': 'testUser123',
        'uploaderDisplayName': 'Test User',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastAccessedAt': null,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resource')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course Code'),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'Math', child: Text('Math')),
                DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                DropdownMenuItem(value: 'Programming', child: Text('Programming')),
              ],
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.attach_file),
              label: Text(_pickedFile == null ? 'Pick PDF' : 'PDF Selected'),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: const Icon(Icons.cloud_upload),
              label: Text(_uploading ? 'Uploading...' : 'Upload'),
            ),
          ],
        ),
      ),
    );
  }
}