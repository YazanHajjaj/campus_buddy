import 'package:flutter/material.dart';
import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/edit_profile_screen.dart';
import 'package:campus_buddy/features/notifications/screens/notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = AuthService();
    await auth.signOut();

    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _clearCache(BuildContext context) {
    // Placeholder for future cache / downloads clearing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Campus Buddy'),
        content: const Text(
          'Version 1.0.0\n\nCampus Buddy helps students connect, learn, and navigate campus life.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            children: [
              _SettingsItem(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ).then((_) => Navigator.pop(context, true));
                },
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: 'Notification Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _SectionCard(
            children: [
              _SettingsItem(
                icon: Icons.delete_sweep_outlined,
                label: 'Clear cache / downloads',
                onTap: () => _clearCache(context),
              ),
              _SettingsItem(
                icon: Icons.info_outline,
                label: 'About / Version',
                onTap: () => _showAbout(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _SectionCard(
            children: [
              _SettingsItem(
                icon: Icons.delete_forever_outlined,
                label: 'Delete account',
                enabled: false,
                danger: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Divider(color: Colors.grey.shade300),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ======================= UI COMPONENTS ======================= */

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool danger;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? const Color(0xFFDC2626)
        : enabled
        ? Colors.black87
        : Colors.black38;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // 👇 only shown for disabled items
                  if (!enabled)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'Coming soon',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (enabled)
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}