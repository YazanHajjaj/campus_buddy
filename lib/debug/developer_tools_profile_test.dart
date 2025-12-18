import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/controllers/profile_controller.dart';
import 'package:campus_buddy/features/profile/models/app_user.dart';
import 'package:campus_buddy/features/profile/services/profile_storage_service.dart';

/// DEBUG TOOL — PROFILE MODULE
/// Phase 3 verification screen
/// Used to manually test profile backend logic.
/// NOT part of production UI.
class DeveloperToolsProfileTest extends StatefulWidget {
  const DeveloperToolsProfileTest({super.key});

  @override
  State<DeveloperToolsProfileTest> createState() =>
      _DeveloperToolsProfileTestState();
}

class _DeveloperToolsProfileTestState
    extends State<DeveloperToolsProfileTest> {
  final _uidController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _deptController = TextEditingController();

  final AuthService _authService = AuthService();

  late final ProfileController controller =
  ProfileController(service: ProfileStorageService());

  Stream<AppUser?>? _profileStream;
  AppUser? _currentUser;

  /// Returns current auth UID or null if not signed in.
  String? get _authUid {
    final user = _authService.currentUser;
    return user?.uid;
  }

  @override
  void initState() {
    super.initState();

    // Show UID in the disabled field so it’s not dead UI
    _uidController.text = _authUid ?? 'Not logged in';
  }

  @override
  void dispose() {
    _uidController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DEBUG ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> _fetchProfile() async {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('User not authenticated');
      return;
    }

    final user = await controller.getProfile(uid);
    if (!mounted) return;

    setState(() => _currentUser = user);
  }

  void _startListening() {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('User not authenticated');
      return;
    }

    setState(() => _profileStream = controller.watchProfile(uid));
  }

  Future<void> _updateFields() async {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('User not authenticated');
      return;
    }

    await controller.updateProfile(
      uid,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      department: _deptController.text.trim().isEmpty
          ? null
          : _deptController.text.trim(),
    );

    if (!mounted) return;
    _showSnack('Profile updated');
  }

  Future<void> _uploadImage() async {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('User not authenticated');
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    await controller.uploadImage(uid, File(file.path));

    if (!mounted) return;
    _showSnack('Image uploaded');
  }

  Future<void> _deleteImage() async {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('User not authenticated');
      return;
    }

    await controller.deleteImage(uid);

    if (!mounted) return;
    _showSnack('Profile image deleted');
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _profileText(AppUser user) {
    return Text(
      'Name: ${user.name}\n'
          'Email: ${user.email}\n'
          'Bio: ${user.bio}\n'
          'Dept: ${user.department}\n'
          'Image: ${user.profileImageUrl}\n',
      style: const TextStyle(fontSize: 16),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD (FIXED OVERFLOW)
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Debug Tools')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _uidController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'User UID (from auth)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _fetchProfile,
                  child: const Text('Fetch Profile'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _startListening,
                  child: const Text('Live Listen'),
                ),
              ],
            ),

            const Divider(height: 30),

            if (_currentUser != null) ...[
              Text(
                'FETCHED PROFILE:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _profileText(_currentUser!),
              const Divider(height: 30),
            ],

            if (_profileStream != null)
              StreamBuilder<AppUser?>(
                stream: _profileStream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Text('Waiting for profile data...');
                  }
                  if (snap.hasError) {
                    return Text('Error: ${snap.error}');
                  }
                  final user = snap.data;
                  if (user == null) {
                    return const Text('No profile found.');
                  }
                  return _profileText(user);
                },
              ),

            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'New Name'),
            ),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'New Bio'),
            ),
            TextField(
              controller: _deptController,
              decoration:
              const InputDecoration(labelText: 'New Department'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _updateFields,
              child: const Text('Update Fields'),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: const Text('Upload Image'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _deleteImage,
                  child: const Text('Delete Image'),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
