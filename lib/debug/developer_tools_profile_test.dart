import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/auth_service.dart';
import '../features/profile/controllers/profile_controller.dart';
import '../features/profile/models/app_user.dart';
import '../features/profile/services/profile_storage_service.dart';

/// Developer-only screen to test the Profile module backend.
/// Used during Phase 3 verification. Not part of production UI.
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

  /// Returns the current authenticated user's UID.
  String? get _authUid {
    final user = _authService.currentUser;
    return user?.uid;
  }

  @override
  void initState() {
    super.initState();
    _uidController.text = _authUid ?? '—';
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
    if (uid == null) {
      _showSnack('error.unauthorized');
      return;
    }

    final user = await controller.getProfile(uid);
    if (!mounted) return;

    setState(() => _currentUser = user);
  }

  void _startListening() {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('error.unauthorized');
      return;
    }

    setState(() => _profileStream = controller.watchProfile(uid));
  }

  Future<void> _updateFields() async {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('error.unauthorized');
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
    _showSnack('profile.updated');
  }

  Future<void> _uploadImage() async {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('error.unauthorized');
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    await controller.uploadImage(uid, File(file.path));

    if (!mounted) return;
    _showSnack('profile.imageUploaded');
  }

  Future<void> _deleteImage() async {
    final uid = _authUid;
    if (uid == null) {
      _showSnack('error.unauthorized');
      return;
    }

    await controller.deleteImage(uid);

    if (!mounted) return;
    _showSnack('profile.imageDeleted');
  }

  void _showSnack(String key) {
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.t(key))),
    );
  }

  Widget _profileText(AppUser user) {
    return Text(
      'Name: ${user.name}\n'
          'Email: ${user.email}\n'
          'Bio: ${user.bio}\n'
          'Department: ${user.department}\n'
          'Image: ${user.profileImageUrl}\n',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('profile.debugTools')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _uidController,
              enabled: false,
              decoration: InputDecoration(
                labelText: t.t('profile.userUid'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _fetchProfile,
                  child: Text(t.t('profile.fetch')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _startListening,
                  child: Text(t.t('profile.listen')),
                ),
              ],
            ),

            const Divider(height: 30),

            if (_currentUser != null) ...[
              Text(
                t.t('profile.fetched'),
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
                    return Text(t.t('common.loading'));
                  }
                  if (snap.hasError) {
                    return Text('${t.t('common.error')}: ${snap.error}');
                  }
                  final user = snap.data;
                  if (user == null) {
                    return Text(t.t('profile.notFound'));
                  }
                  return _profileText(user);
                },
              ),

            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t.t('profile.newName'),
              ),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: t.t('profile.newBio'),
              ),
            ),
            TextField(
              controller: _deptController,
              decoration: InputDecoration(
                labelText: t.t('profile.newDepartment'),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _updateFields,
              child: Text(t.t('profile.update')),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text(t.t('profile.uploadImage')),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _deleteImage,
                  child: Text(t.t('profile.deleteImage')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}