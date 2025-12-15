import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/auth_service.dart';

import '../features/profile/controllers/profile_controller.dart';
import '../features/profile/models/app_user.dart';
import '../features/profile/services/profile_storage_service.dart';

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

  final ProfileController controller =
  ProfileController(service: ProfileStorageService());

  AppUser? _currentUser;
  Stream<AppUser?>? _profileStream;

  // get authenticated user uid (debug helper)
  String get _authUid {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // load profile once
  Future<void> _fetchProfile() async {
    final uid = _authUid;

    final user = await controller.getProfile(uid);
    setState(() {
      _currentUser = user;
    });
  }

  // listen to changes
  void _startListening() {
    final uid = _authUid;

    final stream = controller.watchProfile(uid);
    setState(() {
      _profileStream = stream;
    });
  }

  // update name/bio/department
  Future<void> _updateFields() async {
    final uid = _authUid;

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  // upload image
  Future<void> _uploadImage() async {
    final uid = _authUid;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final imageFile = File(file.path);

    final url = await controller.uploadImage(uid, imageFile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image uploaded: $url')),
    );
  }

  // delete image
  Future<void> _deleteImage() async {
    final uid = _authUid;

    await controller.deleteImage(uid);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image deleted')),
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
            // uid (kept for debug visibility – not used)
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

            // live stream display
            if (_profileStream != null)
              Expanded(
                child: StreamBuilder<AppUser?>(
                  stream: _profileStream,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Text('Waiting for profile data...');
                    }

                    final user = snap.data!;
                    return Text(
                      'LIVE PROFILE:\n'
                          'Name: ${user.name}\n'
                          'Email: ${user.email}\n'
                          'Bio: ${user.bio}\n'
                          'Dept: ${user.department}\n'
                          'Image: ${user.profileImageUrl}\n',
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // manual update fields
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

            // image actions
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
