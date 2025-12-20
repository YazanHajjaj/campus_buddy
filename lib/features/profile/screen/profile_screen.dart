import 'package:flutter/material.dart';
import 'package:campus_buddy/core/models/auth_user.dart';
import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/controllers/profile_controller.dart';
import 'package:campus_buddy/features/profile/models/app_user.dart';
import 'package:campus_buddy/features/profile/services/profile_storage_service.dart';
import 'package:campus_buddy/features/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

    final authUser = await _authService.getCurrentAuthUser();
    // Use the same method name as in EditProfileScreen
    final profile = await _controller.getProfile(uid);

    if (!mounted) return;
    setState(() {
      _authUser = authUser;
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(),
      ),
    );
    // refresh profile data after returning
    _loadData();
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

    final name = _profile?.name ?? 'Your name';
    final email = _profile?.email ?? _authUser?.email ?? 'Email';

    // Your AppUser currently does NOT have phone/section/year.
    // For Phase 3 we keep the same UI but use placeholders only.
    const phone = 'Add phone number';
    final department = _profile?.department ?? 'Add department';
    const section = 'Add section';
    const year = 'Add year';
    final bio = _profile?.bio ?? 'Tell something about yourself';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openEditProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // avatar + name/email
              Row(
                children: [
                  _ProfileAvatar(imageUrl: _profile?.profileImageUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
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
                  _InfoRow(label: 'phone number', value: phone),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'departement', value: department),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'section', value: section),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'which year', value: year),
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
                  Text(
                    bio,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openEditProfile,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Helper widgets – visually consistent with EditProfileScreen */

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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black54),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
