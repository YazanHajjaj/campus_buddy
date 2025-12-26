import 'package:flutter/material.dart';
import 'package:campus_buddy/core/models/auth_user.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  final _authService = AuthService();
  late final ProfileController _controller;

  bool _loading = true;
  AppUser? _profile;
  AuthUser? _authUser;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(service: ProfileStorageService());
    _loadData();
  }

  Future<void> _loadData() async {
    final firebaseUser = _authService.currentUser;
    final uid = firebaseUser?.uid;

    if (uid == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    _authUser = await _authService.getCurrentAuthUser();
    _profile = await _controller.getProfile(uid);

    final profile = _profile;
    final authUser = _authUser;

    _nameCtrl.text = profile?.name ?? '';
    _emailCtrl.text = profile?.email ?? authUser?.email ?? '';
    _bioCtrl.text = profile?.bio ?? '';
    _departmentCtrl.text = profile?.department ?? '';

    // AppUser currently has no phone/section/year fields.
    _phoneCtrl.text = '';
    _sectionCtrl.text = '';
    _yearCtrl.text = '';

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final firebaseUser = _authService.currentUser;
    final uid = firebaseUser?.uid;
    if (uid == null) return;

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      await _controller.updateProfile(
        uid,
        name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        department: _departmentCtrl.text.trim().isEmpty
            ? null
            : _departmentCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        section:
            _sectionCtrl.text.trim().isEmpty ? null : _sectionCtrl.text.trim(),
        year: _yearCtrl.text.trim().isEmpty ? null : _yearCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;

    // Go back to the root; AuthGate will show the correct screen based on auth state.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _departmentCtrl.dispose();
    _sectionCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_authService.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('edit profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + upload photo
                Row(
                  children: [
                    _ProfileAvatar(
                      imageUrl: _profile?.profileImageUrl,
                    ),
                    const SizedBox(width: 16),
                    _PillButton(
                      label: 'upload photo',
                      onPressed: () {
                        // TODO: image picker + upload
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                _InfoCard(
                  children: [
                    _EditableRow(
                      label: 'your Name',
                      controller: _nameCtrl,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 8),
                    _EditableRow(
                      label: 'Email',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    _EditableRow(
                      label: 'phone number',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'bio',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                _InfoCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'About you',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _InfoCard(
                  children: [
                    _EditableRow(
                      label: 'departement',
                      controller: _departmentCtrl,
                    ),
                    const SizedBox(height: 8),
                    _EditableRow(
                      label: 'section',
                      controller: _sectionCtrl,
                    ),
                    const SizedBox(height: 8),
                    _EditableRow(
                      label: 'which year',
                      controller: _yearCtrl,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save changes'),
                  ),
                ),

                const SizedBox(height: 16),

                // ---------- SIGN OUT BUTTON ----------
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar widget
class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Icon(
              Icons.person,
              size: 30,
              color: Colors.grey.shade700,
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const _InfoCard({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: const StadiumBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Row: label + "edit" pill that opens a dialog.
class _EditableRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _EditableRow({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        _PillButton(
          label: 'edit',
          onPressed: () async {
            final tmp = TextEditingController(text: controller.text);
            await showDialog<void>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Edit $label'),
                  content: TextField(
                    controller: tmp,
                    keyboardType: keyboardType,
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.text = tmp.text;
                        Navigator.pop(context);q
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
