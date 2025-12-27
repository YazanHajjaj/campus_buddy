import 'package:flutter/material.dart';
import 'package:campus_buddy/features/resources/services/resource_service_impl.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isSubmitting = false;

  final FirestoreResourceService _resourceService =
  FirestoreResourceService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseCodeController.dispose();
    _categoryController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _resourceService.createResource(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        courseCode: _courseCodeController.text.trim(),
        storagePath: 'resources/debug/example.pdf',
        fileUrl: 'https://example.com/fake.pdf',
        uploaderUserId: 'debug_user',
        uploaderDisplayName: 'Debug User',
        tags: [
          _categoryController.text.trim().toLowerCase(),
        ],
        sizeInBytes: 12345,
        mimeType: 'application/pdf',
        isPublic: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource uploaded (DEBUG)')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resource (DEBUG)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}