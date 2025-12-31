import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

class EditMentorProfileScreen extends StatefulWidget {
  const EditMentorProfileScreen({super.key});

  @override
  State<EditMentorProfileScreen> createState() =>
      _EditMentorProfileScreenState();
}

class _EditMentorProfileScreenState extends State<EditMentorProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _bioController = TextEditingController();

  File? _newImage;
  String? _currentPhotoUrl;

  bool _loading = true;
  bool _saving = false;

  /* ───────────────── IMAGE PICKER ───────────────── */

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _newImage = File(image.path);
    });
  }

  Future<String?> _uploadImage(String uid) async {
    if (_newImage == null) return _currentPhotoUrl;

    final ref =
    _storage.ref().child('mentor_profiles/$uid/profile.jpg');

    await ref.putFile(_newImage!);
    return await ref.getDownloadURL();
  }

  /* ───────────────── LOAD DATA ───────────────── */

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc =
    await _db.collection('mentor_profiles').doc(uid).get();

    final data = doc.data();
    if (data == null) return;

    _nameController.text = data['name'] ?? '';
    _departmentController.text = data['department'] ?? '';
    _bioController.text = data['bio'] ?? '';
    _currentPhotoUrl = data['photoUrl'];

    setState(() => _loading = false);
  }

  /* ───────────────── SAVE ───────────────── */

  Future<void> _save(AppLocalizations t) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final uid = _auth.currentUser!.uid;
      final photoUrl = await _uploadImage(uid);

      await _db.collection('mentor_profiles').doc(uid).update({
        'name': _nameController.text.trim(),
        'department': _departmentController.text.trim(),
        'bio': _bioController.text.trim(),
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /* ───────────────── UI ───────────────── */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('profile.edit'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ───────── PROFILE PHOTO ─────────
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor:
                  colors.primary.withValues(alpha: 0.12),
                  backgroundImage: _newImage != null
                      ? FileImage(_newImage!)
                      : (_currentPhotoUrl != null
                      ? NetworkImage(_currentPhotoUrl!)
                      : null) as ImageProvider?,
                  child: (_newImage == null && _currentPhotoUrl == null)
                      ? Icon(
                    Icons.camera_alt,
                    color: colors.primary,
                    size: 28,
                  )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _InputField(
              controller: _nameController,
              label: t.t('profile.name'),
              validator: (v) =>
              v == null || v.trim().isEmpty
                  ? t.t('common.required')
                  : null,
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: _departmentController,
              label: t.t('profile.department'),
              validator: (v) =>
              v == null || v.trim().isEmpty
                  ? t.t('common.required')
                  : null,
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: _bioController,
              label: t.t('profile.bio'),
              maxLines: 3,
              validator: (v) =>
              v == null || v.trim().isEmpty
                  ? t.t('common.required')
                  : null,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : () => _save(t),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  t.t('common.save'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── INPUT ───────────────── */

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}