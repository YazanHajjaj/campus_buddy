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
      backgroundColor: const Color(0xFFF3F4F6),

      // ───── APP BAR ─────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Upload Resource (DEBUG)'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(
                    controller: _titleController,
                    label: 'Title',
                    required: true,
                  ),
                  const SizedBox(height: 12),

                  _field(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  _field(
                    controller: _courseCodeController,
                    label: 'Course Code',
                  ),
                  const SizedBox(height: 12),

                  _field(
                    controller: _categoryController,
                    label: 'Category',
                  ),
                  const SizedBox(height: 12),

                  _field(
                    controller: _departmentController,
                    label: 'Department',
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2446C8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Upload Resource',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: required
          ? (v) => v == null || v.isEmpty ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}