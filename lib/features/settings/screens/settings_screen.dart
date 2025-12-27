import 'package:flutter/material.dart';
import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/features/profile/edit_profile_screen.dart';
import 'package:campus_buddy/features/notifications/screens/notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: _CardShell(
            child: Column(
              children: [
                _ActionButton(
                  icon: Icons.person_outline,
                  text: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                  danger: false,
                ),
                const SizedBox(height: 12),

                _ActionButton(
                  icon: Icons.notifications_outlined,
                  text: 'Notification Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const NotificationSettingsScreen(),
                      ),
                    );
                  },
                  danger: false,
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                _ActionButton(
                  icon: Icons.logout_outlined,
                  text: 'Logout',
                  onTap: () => _logout(context),
                  danger: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ======================= SHARED UI ======================= */

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
    final color = danger ? const Color(0xFFDC2626) : Colors.black87;
    final border =
    danger ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}