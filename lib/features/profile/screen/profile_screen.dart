import 'package:flutter/material.dart';
import 'package:campus_buddy/core/models/auth_user.dart';
import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/controllers/profile_controller.dart';
import 'package:campus_buddy/features/profile/models/app_user.dart';
import 'package:campus_buddy/features/profile/services/profile_storage_service.dart';
import 'package:campus_buddy/features/settings/screens/settings_screen.dart';

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
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    final authUser = await _authService.getCurrentAuthUser();
    final profile = await _controller.getProfile(uid);

    if (!mounted) return;
    setState(() {
      _authUser = authUser;
      _profile = profile;
      _loading = false;
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name =
    _profile?.name?.trim().isNotEmpty == true ? _profile!.name! : 'Your Name';

    final email =
        _profile?.email ?? _authUser?.email ?? 'email@example.com';

    final department =
    _profile?.department?.trim().isNotEmpty == true
        ? _profile!.department!
        : '—';

    final studentId = _profile?.studentId ?? '—';
    final year = _profile?.year ?? '—';
    final phone = _profile?.phone ?? '—';
    final bio = _profile?.bio ?? '—';

    final gpa =
    _profile?.gpa != null ? _profile!.gpa!.toStringAsFixed(2) : '—';

    final credits =
    _profile?.credits != null ? _profile!.credits.toString() : '—';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              _ProfileMainCard(
                imageUrl: _profile?.profileImageUrl,
                name: name,
                email: email,
                roleLabel: 'Student',
                department: department,
                studentId: studentId,
                phone: phone,
                bio: bio,
                year: year,
                onOpenSettings: _openSettings,
              ),
              const SizedBox(height: 16),
              _AcademicSummaryCard(
                currentYear: year,
                gpa: gpa,
                credits: credits,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ======================= MAIN CARD ======================= */

class _ProfileMainCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String email;
  final String roleLabel;
  final String department;
  final String studentId;
  final String phone;
  final String bio;
  final String year;

  final VoidCallback onOpenSettings;

  const _ProfileMainCard({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.department,
    required this.studentId,
    required this.phone,
    required this.bio,
    required this.year,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          const SizedBox(height: 6),
          _Avatar(imageUrl: imageUrl),
          const SizedBox(height: 12),

          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),

          Text(email, style: const TextStyle(color: Colors.black54)),

          const SizedBox(height: 10),
          _RoleChip(label: roleLabel),
          const SizedBox(height: 16),

          _row(
            _InfoTile(
              icon: Icons.school_outlined,
              label: 'Department',
              value: department,
            ),
            _InfoTile(
              icon: Icons.badge_outlined,
              label: 'Student ID',
              value: studentId,
            ),
          ),
          const SizedBox(height: 12),

          _row(
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone,
            ),
            _InfoTile(
              icon: Icons.bar_chart_outlined,
              label: 'Academic Year',
              value: year,
            ),
          ),

          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.info_outline,
            label: 'Bio',
            value: bio,
          ),

          const SizedBox(height: 18),

          _ActionButton(
            icon: Icons.settings_outlined,
            text: 'Settings',
            onTap: onOpenSettings,
            danger: false,
          ),
        ],
      ),
    );
  }

  Widget _row(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  }
}

/* ======================= ACADEMIC SUMMARY ======================= */

class _AcademicSummaryCard extends StatelessWidget {
  final String currentYear;
  final String gpa;
  final String credits;

  const _AcademicSummaryCard({
    required this.currentYear,
    required this.gpa,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2446C8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(label: 'Current Year', value: currentYear),
              ),
              Expanded(
                child: _SummaryItem(label: 'GPA', value: gpa),
              ),
              Expanded(
                child: _SummaryItem(label: 'Credits', value: credits),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ======================= SMALL WIDGETS ======================= */

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;

  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 46,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : const Icon(Icons.person, size: 44, color: Colors.black54),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;

  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2446C8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2446C8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool danger;

  const _ActionButton(
      {required this.icon,
        required this.text,
        required this.onTap,
        required this.danger});

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFDC2626) : Colors.black87;
    final border =
    danger ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB);

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(text,
            style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: border),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}