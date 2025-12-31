import 'package:flutter/material.dart';
import 'package:campus_buddy/core/models/auth_user.dart';
import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/core/localization/app_localizations.dart';

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
  Stream<AppUser?>? _profileStream;
  AuthUser? _authUser;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(service: ProfileStorageService());
    _init();
  }

  Future<void> _init() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    _authUser = await _authService.getCurrentAuthUser();
    _profileStream = _controller.watchProfile(uid);

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _openSettings() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (updated == true) {
      await _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: Text(t.t('profile.title')),
      ),
      body: StreamBuilder<AppUser?>(
        stream: _profileStream,
        builder: (context, snapshot) {
          final profile = snapshot.data;

          final name = profile?.name?.trim().isNotEmpty == true
              ? profile!.name!
              : t.t('profile.placeholderName');

          final email =
              profile?.email ?? _authUser?.email ?? t.t('profile.placeholderEmail');

          final notSet = t.t('profile.notSet');

          final department =
          profile?.department?.trim().isNotEmpty == true ? profile!.department! : notSet;
          final studentId = profile?.studentId ?? notSet;
          final year = profile?.year ?? notSet;
          final phone = profile?.phone ?? notSet;
          final bio = profile?.bio ?? notSet;

          final gpa =
          profile?.gpa != null ? profile!.gpa!.toStringAsFixed(2) : notSet;
          final credits =
          profile?.credits != null ? profile!.credits.toString() : notSet;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _ProfileMainCard(
                    imageUrl: profile?.profileImageUrl,
                    name: name,
                    email: email,
                    roleLabel: t.t('profile.roleStudent'),
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
          );
        },
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
    final t = AppLocalizations.of(context);

    return _CardShell(
      child: Column(
        children: [
          _Avatar(imageUrl: imageUrl),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(email, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          _RoleChip(label: roleLabel),
          const SizedBox(height: 16),
          _row(
            _InfoTile(icon: Icons.school_outlined, label: t.t('profile.department'), value: department),
            _InfoTile(icon: Icons.badge_outlined, label: t.t('profile.studentId'), value: studentId),
          ),
          const SizedBox(height: 12),
          _row(
            _InfoTile(icon: Icons.phone_outlined, label: t.t('profile.phone'), value: phone),
            _InfoTile(icon: Icons.bar_chart_outlined, label: t.t('profile.year'), value: year),
          ),
          const SizedBox(height: 12),
          _InfoTile(icon: Icons.info_outline, label: t.t('profile.bio'), value: bio),
          const SizedBox(height: 18),
          _ActionButton(
            icon: Icons.settings_outlined,
            text: t.t('common.settings'),
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
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('profile.academicSummary'),
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SummaryItem(label: t.t('profile.year'), value: currentYear)),
              Expanded(child: _SummaryItem(label: t.t('profile.gpa'), value: gpa)),
              Expanded(child: _SummaryItem(label: t.t('profile.credits'), value: credits)),
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
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onPrimary.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: colors.onPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
    final colors = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: 46,
      backgroundColor: colors.surfaceVariant,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage ? null : Icon(Icons.person, size: 44, color: colors.onSurface),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
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

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = danger ? colors.error : colors.onSurface;
    final border = danger ? colors.error.withOpacity(0.4) : colors.outlineVariant;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}