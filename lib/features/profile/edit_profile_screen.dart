import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/controllers/profile_controller.dart';
import 'package:campus_buddy/features/profile/services/profile_storage_service.dart';

/// PHASE 3 — PROFILE MODULE (UI + BASIC INTEGRATION)
/// This screen allows the user to edit their profile information.
/// Backend persistence is handled via ProfileController.
///
/// Notes:
/// - Profile image is selected from device (gallery or camera)
/// - Bio has NO artificial character limit
/// - Year of study represents academic year (1st, 2nd, 3rd, etc.)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _departmentController = TextEditingController();

  int? _yearOfStudy;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  final AuthService _authService = AuthService();
  late final ProfileController _controller =
  ProfileController(service: ProfileStorageService());

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // IMAGE PICKING
  // ---------------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SAVE ACTION (REAL BACKEND WRITE)
  // ---------------------------------------------------------------------------

  Future<void> _onSavePressed() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    await _controller.updateProfile(
      uid,
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      department: _departmentController.text.trim(),
    );

    if (_selectedImage != null) {
      await _controller.uploadImage(uid, _selectedImage!);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );

    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage:
                        _selectedImage != null ? FileImage(_selectedImage!) : null,
                        child: _selectedImage == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showImageSourceSheet,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Change profile photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bio is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Department is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: _yearOfStudy,
                  decoration: const InputDecoration(
                    labelText: 'Year of study',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1st Year')),
                    DropdownMenuItem(value: 2, child: Text('2nd Year')),
                    DropdownMenuItem(value: 3, child: Text('3rd Year')),
                    DropdownMenuItem(value: 4, child: Text('4th Year')),
                    DropdownMenuItem(value: 5, child: Text('5th Year or above')),
                  ],
                  onChanged: (v) => setState(() => _yearOfStudy = v),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your year of study';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _onSavePressed,
                  child: const Text('Save profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
