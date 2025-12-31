import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  /* ───────────────── PICK PDF ───────────────── */

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

  /* ───────────────── UPLOAD ───────────────── */
  Future<void> _upload() async {
    final t = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null ||
        _pickedFile == null ||
        _titleController.text.trim().isEmpty) {
      return;
    }

    setState(() => _uploading = true);

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storagePath = 'resources/$fileName.pdf';

      // ───── Storage upload ─────
      final ref = FirebaseStorage.instance.ref(storagePath);
      await ref.putFile(_pickedFile!);
      final downloadUrl = await ref.getDownloadURL();

      // ───── Firestore resource document ─────
      final resourceRef =
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

        // User
        'uploaderUserId': user.uid,
        'uploaderDisplayName':
        user.displayName ??
            user.email?.split('@').first ??
            t.t('common.student'),

        // Meta
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastAccessedAt': null,
      });

      //  ANALYTICS TRIGGER (THIS WAS MISSING)
      await FirebaseFirestore.instance.collection('usage_logs').add({
        'uid': user.uid,
        'type': 'resource_upload',
        'resourceId': resourceRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /* ───────────────── UI ───────────────── */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('resources.upload'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(t.t('common.title'), _titleController),
              const SizedBox(height: 12),

              _multilineField(t.t('common.description'), _descController),
              const SizedBox(height: 12),

              _field(t.t('resources.courseCode'), _courseController),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _category,
                items: [
                  DropdownMenuItem(value: 'Math', child: Text(t.t('categories.math'))),
                  DropdownMenuItem(value: 'Physics', child: Text(t.t('categories.physics'))),
                  DropdownMenuItem(value: 'Programming', child: Text(t.t('categories.programming'))),
                ],
                onChanged: (v) => setState(() => _category = v!),
                decoration: _inputDecoration(t.t('common.category'), theme),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: _uploading ? null : _pickPdf,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _pickedFile == null
                      ? t.t('resources.pickPdf')
                      : t.t('resources.pdfSelected'),
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
                  label: Text(
                    _uploading
                        ? t.t('common.uploading')
                        : t.t('common.upload'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
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

  /* ───────────────── FIELDS ───────────────── */

  Widget _field(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label, Theme.of(context)),
    );
  }

  Widget _multilineField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: _inputDecoration(label, Theme.of(context)),
    );
  }

  InputDecoration _inputDecoration(String label, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

/* ───────────────── CARD SHELL ───────────────── */

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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