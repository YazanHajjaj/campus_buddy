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
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // ───── APP BAR ─────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Upload Resource'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Title', _titleController),
              const SizedBox(height: 12),

              _multilineField('Description', _descController),
              const SizedBox(height: 12),

              _field('Course Code', _courseController),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'Math', child: Text('Math')),
                  DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                  DropdownMenuItem(value: 'Programming', child: Text('Programming')),
                ],
                onChanged: (v) => setState(() => _category = v!),
                decoration: _inputDecoration('Category'),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _pickedFile == null ? 'Pick PDF' : 'PDF selected',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _uploading ? null : _upload,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(_uploading ? 'Uploading...' : 'Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2446C8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label),
    );
  }

  Widget _multilineField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

/* ───────── CARD SHELL ───────── */

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}