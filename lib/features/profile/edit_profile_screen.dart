import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/controllers/profile_controller.dart';
import 'package:campus_buddy/features/profile/models/app_user.dart';
import 'package:campus_buddy/features/profile/services/profile_storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = AuthService();
  late final ProfileController _controller;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  final List<String> _years = const [
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate',
  ];

  String? _selectedYear;

  bool _loading = true;
  AppUser? _profile;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(service: ProfileStorageService());
    _load();
  }

  Future<void> _load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final profile = await _controller.getProfile(uid);
    _profile = profile;

    _nameCtrl.text = profile?.name ?? '';
    _emailCtrl.text = profile?.email ?? '';
    _phoneCtrl.text = profile?.phone ?? '';
    _studentIdCtrl.text = profile?.studentId ?? '';
    _departmentCtrl.text = profile?.department ?? '';
    _bioCtrl.text = profile?.bio ?? '';

    if (_years.contains(profile?.year)) {
      _selectedYear = profile!.year;
    } else {
      _selectedYear = null;
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);

    await _controller.updateProfile(
      uid,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      studentId: _studentIdCtrl.text.trim(),
      department: _departmentCtrl.text.trim(),
      year: _selectedYear,
      bio: _bioCtrl.text.trim(),
    );

    if (mounted) Navigator.pop(context);
  }

  Future<void> _changePhoto() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    await _controller.uploadImage(uid, File(file.path));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _changePhoto,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: _profile?.profileImageUrl != null
                        ? NetworkImage(_profile!.profileImageUrl!)
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: _profile?.profileImageUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Change photo',
                    style: TextStyle(
                      color: Color(0xFF2446C8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _field('Full name', _nameCtrl),
            _field('Email', _emailCtrl),
            _field('Phone number', _phoneCtrl),
            _field('Student ID', _studentIdCtrl),
            _field('Department', _departmentCtrl),

            _yearDropdown(),

            _bioField(),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _yearDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedYear,
        items: _years
            .map(
              (year) => DropdownMenuItem(
            value: year,
            child: Text(year),
          ),
        )
            .toList(),
        onChanged: (value) {
          setState(() => _selectedYear = value);
        },
        decoration: InputDecoration(
          labelText: 'Academic year',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _bioField() {
    return TextField(
      controller: _bioCtrl,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Bio',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}