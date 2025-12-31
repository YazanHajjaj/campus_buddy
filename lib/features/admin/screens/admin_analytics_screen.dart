import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('admin.analyticsDashboard'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = userSnap.data!.docs;
          final totalUsers = users.length;

          final totalXp = users.fold<int>(
            0,
                (sum, u) => sum + ((u['xp'] ?? 0) as int),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(
                icon: Icons.people,
                label: t.t('admin.totalUsers'),
                value: totalUsers.toString(),
              ),
              const SizedBox(height: 12),

              _StatCard(
                icon: Icons.emoji_events,
                label: t.t('admin.totalXp'),
                value: totalXp.toString(),
              ),
              const SizedBox(height: 12),

              _StatCard(
                icon: Icons.bar_chart,
                label: t.t('admin.avgXp'),
                value: totalUsers == 0
                    ? '0'
                    : (totalXp ~/ totalUsers).toString(),
              ),

              const SizedBox(height: 24),

              Text(
                t.t('admin.analyticsNote'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.disabledColor),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ───────────────── STAT CARD ───────────────── */

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
            theme.colorScheme.primary.withOpacity(0.12),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}