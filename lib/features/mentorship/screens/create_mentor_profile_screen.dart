import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

class CreateMentorProfileScreen extends StatefulWidget {
  const CreateMentorProfileScreen({super.key});

  @override
  State<CreateMentorProfileScreen> createState() =>
      _CreateMentorProfileScreenState();
}

class _CreateMentorProfileScreenState
    extends State<CreateMentorProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _bioController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _capacityController = TextEditingController(text: '3');

  final List<String> _expertise = [];
  File? _profileImage;

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
      _profileImage = File(image.path);
    });
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_profileImage == null) return null;

    final ref =
    _storage.ref().child('mentor_profiles/$uid/profile.jpg');

    await ref.putFile(_profileImage!);
    return await ref.getDownloadURL();
  }

  /* ───────────────── HELPERS ───────────────── */

  void _addExpertise(AppLocalizations t) {
    final text = _expertiseController.text.trim();
    if (text.isEmpty) return;

    if (_expertise.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('mentorship.expertiseExists'))),
      );
      return;
    }

    setState(() {
      _expertise.add(text);
      _expertiseController.clear();
    });
  }

  int _parseCapacity(String raw) {
    final v = int.tryParse(raw.trim()) ?? 1;
    return v.clamp(1, 50);
  }

  /* ───────────────── CREATE PROFILE ───────────────── */

  Future<void> _createMentorProfile(AppLocalizations t) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!_formKey.currentState!.validate()) return;

    if (_expertise.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('mentorship.expertiseRequired'))),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final now = Timestamp.now();
      final capacity = _parseCapacity(_capacityController.text);
      final photoUrl = await _uploadProfileImage(user.uid);

      final mentorRef =
      _db.collection('mentor_profiles').doc(user.uid);

      await mentorRef.set({
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'department': _departmentController.text.trim(),
        'bio': _bioController.text.trim(),
        'expertise': _expertise,
        'photoUrl': photoUrl,

        'isActive': true,
        'maxActiveMentees': capacity,

        'activeMenteesCount': 0,
        'ratingAvg': 0.0,
        'ratingCount': 0,

        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));

      await _db.collection('users').doc(user.uid).set({
        'isMentor': true,
        'isStudent': true,
        'updatedAt': now,
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
          t.t('mentorship.createProfile'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            /* ───────── PROFILE PHOTO ───────── */
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor:
                  colors.primary.withValues(alpha: 0.12),
                  backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(
                    Icons.camera_alt,
                    color: colors.primary,
                  )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              child: Column(
                children: [
                  _InputField(
                    controller: _nameController,
                    label: t.t('profile.fullName'),
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
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('mentorship.expertise'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expertiseController,
                          decoration: InputDecoration(
                            hintText: t.t('mentorship.expertiseHint'),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.add, color: colors.primary),
                        onPressed: () => _addExpertise(t),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _expertise.map((e) {
                      return Chip(
                        label: Text(e),
                        onDeleted: () =>
                            setState(() => _expertise.remove(e)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () => _createMentorProfile(t),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  t.t('common.confirm'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

/* ───────────────── UI HELPERS ───────────────── */

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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