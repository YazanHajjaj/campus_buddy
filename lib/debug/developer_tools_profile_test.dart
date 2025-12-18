import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/controllers/profile_controller.dart';
import 'package:campus_buddy/features/profile/models/app_user.dart';
import 'package:campus_buddy/features/profile/services/profile_storage_service.dart';

/// Simple screen to test profile backend functionality.
/// Only for debugging – not part of the real UI.
class DeveloperToolsProfileTest extends StatefulWidget {
  const DeveloperToolsProfileTest({super.key});

  @override
  State<DeveloperToolsProfileTest> createState() =>
      _DeveloperToolsProfileTestState();
}

class _DeveloperToolsProfileTestState extends State<DeveloperToolsProfileTest> {
  final _uidController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _deptController = TextEditingController();

  final AuthService _authService = AuthService();

  late final ProfileController controller =
      ProfileController(service: ProfileStorageService());

  Stream<AppUser?>? _profileStream;
  AppUser? _currentUser; // now USED in the UI

  String get _authUid {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  @override
  void initState() {
    super.initState();
    // Show uid in the disabled field (so it's not "dead" UI)
    try {
      _uidController.text = _authUid;
    } catch (_) {
      _uidController.text = "Not logged in";
    }
  }

  @override
  void dispose() {
    _uidController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    final uid = _authUid;
    final user = await controller.getProfile(uid);
    setState(() => _currentUser = user);
  }

  void _startListening() {
    final uid = _authUid;
    setState(() => _profileStream = controller.watchProfile(uid));
  }

  Future<void> _updateFields() async {
    final uid = _authUid;

    await controller.updateProfile(
      uid,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      department: _deptController.text.trim().isEmpty ? null : _deptController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  Future<void> _uploadImage() async {
    final uid = _authUid;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final url = await controller.uploadImage(uid, File(file.path));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image uploaded: $url')),
    );
  }

  Future<void> _deleteImage() async {
    final uid = _authUid;

    await controller.deleteImage(uid);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image deleted')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Debug Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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

            // Show fetched profile (fixes unused _currentUser warning)
            if (_currentUser != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "FETCHED PROFILE:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              _profileText(_currentUser!),
              const Divider(height: 30),
            ],

            // Live stream display
            if (_profileStream != null)
              Expanded(
                child: StreamBuilder<AppUser?>(
                  stream: _profileStream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Text('Waiting for profile data...');
                    }
                    if (snap.hasError) {
                      return Text('Error: ${snap.error}');
                    }
                    final user = snap.data;
                    if (user == null) return const Text('No profile found.');
                    return _profileText(user);
                  },
                ),
              )
            else
              const Spacer(),

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
              decoration: const InputDecoration(labelText: 'New Department'),
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
          ],
        ),
      ),
    );
  }
}
