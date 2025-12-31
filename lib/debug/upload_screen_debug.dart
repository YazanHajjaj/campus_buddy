import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import 'package:campus_buddy/features/resources/services/resource_service_impl.dart';

/// DEBUG upload screen for validating resource creation.
/// Uses fake file data. Not part of production flow.
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
        tags: [_categoryController.text.trim().toLowerCase()],
        sizeInBytes: 12345,
        mimeType: 'application/pdf',
        isPublic: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).t('resources.debugSuccess'))),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).t('resources.debugFailed'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(t.t('resources.debugUploadTitle')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      controller: _titleController,
                      label: t.t('common.title'),
                      required: true,
                    ),
                    const SizedBox(height: 12),

                    _field(
                      controller: _descriptionController,
                      label: t.t('common.description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    _field(
                      controller: _courseCodeController,
                      label: t.t('resources.courseCode'),
                    ),
                    const SizedBox(height: 12),

                    _field(
                      controller: _categoryController,
                      label: t.t('common.category'),
                    ),
                    const SizedBox(height: 12),

                    _field(
                      controller: _departmentController,
                      label: t.t('profile.department'),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(
                          t.t('resources.upload'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
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
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,

      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}