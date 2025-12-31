import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_buddy/core/services/auth_service.dart';
import 'package:campus_buddy/core/state/accessibility_controller.dart';
import 'package:campus_buddy/core/localization/app_localizations.dart';

import 'package:campus_buddy/features/profile/edit_profile_screen.dart';
import 'package:campus_buddy/features/notifications/screens/notification_settings_screen.dart';
import 'package:campus_buddy/features/admin/screens/admin_dashboard_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = AuthService();
    await auth.signOut();

    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _clearCache(BuildContext context) {
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.t('common.loading'))),
    );
  }

  void _showAbout(BuildContext context) {
    final t = AppLocalizations.of(context);

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
            child: Text(t.t('common.confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessibility = context.watch<AccessibilityController>();
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(t.t('nav.settings')),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /* ───── ACCOUNT ───── */
          _SectionCard(
            children: [
              _SettingsItem(
                icon: Icons.person_outline,
                label: t.t('profile.edit'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: t.t('notifications.settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          /* ───── ACCESSIBILITY ───── */
          _SectionCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.contrast),
                title: Text(
                  t.t('accessibility.highContrast'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(t.t('accessibility.title')),
                value: accessibility.highContrast,
                onChanged: accessibility.toggleHighContrast,
              ),
            ],
          ),

          const SizedBox(height: 16),

          /* ───── LANGUAGE ───── */
          _SectionCard(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        t.t('nav.settings'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: accessibility.languageCode,
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'tr',
                          child: Text('Türkçe'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          accessibility.setLanguage(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /* ───── SYSTEM ───── */
          _SectionCard(
            children: [
              _SettingsItem(
                icon: Icons.admin_panel_settings_outlined,
                label: t.t('admin.dashboard'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.delete_sweep_outlined,
                label: t.t('common.delete'),
                onTap: () => _clearCache(context),
              ),
              _SettingsItem(
                icon: Icons.info_outline,
                label: t.t('common.confirm'),
                onTap: () => _showAbout(context),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),

          /* ───── LOGOUT ───── */
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFDC2626),
              ),
              label: Text(
                t.t('auth.signOut'),
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── UI HELPERS ───────────────── */

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
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

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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