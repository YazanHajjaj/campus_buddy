import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';
import 'report_export_screen.dart';

/// Admin dashboard overview screen.
/// Displays high-level system stats and export access.
/// Charts are planned for a future phase.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('admin.dashboard'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: t.t('admin.exportReport'),
            icon: const Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportExportScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // Fixed export button for quick access
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            icon: const Icon(Icons.download),
            label: Text(t.t('admin.exportReport')),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportExportScreen(),
                ),
              );
            },
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(
            t.t('admin.systemOverview'),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          // Responsive stat grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 600 ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(
                    title: t.t('admin.activeStudents'),
                    value: '128',
                  ),
                  _StatCard(
                    title: t.t('admin.mentors'),
                    value: '14',
                  ),
                  _StatCard(
                    title: t.t('admin.eventsThisMonth'),
                    value: '6',
                  ),
                  _StatCard(
                    title: t.t('admin.topResourceDownloads'),
                    value: '42',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),
          Text(
            t.t('admin.chartsPlaceholder'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          _ChartPlaceholder(
            title: t.t('admin.chartActivityTrend'),
          ),
          const SizedBox(height: 12),
          _ChartPlaceholder(
            title: t.t('admin.chartUserCategories'),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── STAT CARD ───────────────── */

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────────── CHART PLACEHOLDER ─────────────── */

class _ChartPlaceholder extends StatelessWidget {
  final String title;

  const _ChartPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(14),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            const Expanded(
              child: Center(
                child: Text('Chart placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}