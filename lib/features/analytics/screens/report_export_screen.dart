import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

/// Admin report export configuration screen.
/// Allows selecting format, scope, and optional date range.
/// Export execution is planned for a later phase.
class ReportExportScreen extends StatefulWidget {
  const ReportExportScreen({super.key});

  @override
  State<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends State<ReportExportScreen> {
  String _format = 'CSV';
  String _scope = 'system';
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('admin.exportReport'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.t('admin.exportSettings'),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // ───────── FORMAT ─────────
          DropdownButtonFormField<String>(
            value: _format,
            decoration: InputDecoration(
              labelText: t.t('admin.exportFormat'),
              border: const OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'CSV', child: Text('CSV')),
              DropdownMenuItem(value: 'PDF', child: Text('PDF')),
            ],
            onChanged: (v) => setState(() => _format = v ?? 'CSV'),
          ),

          const SizedBox(height: 12),

          // ───────── SCOPE ─────────
          DropdownButtonFormField<String>(
            value: _scope,
            decoration: InputDecoration(
              labelText: t.t('admin.exportScope'),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'system',
                child: Text(t.t('admin.scopeSystem')),
              ),
              DropdownMenuItem(
                value: 'events',
                child: Text(t.t('admin.scopeEvents')),
              ),
              DropdownMenuItem(
                value: 'resources',
                child: Text(t.t('admin.scopeResources')),
              ),
              DropdownMenuItem(
                value: 'mentorship',
                child: Text(t.t('admin.scopeMentorship')),
              ),
            ],
            onChanged: (v) => setState(() => _scope = v ?? 'system'),
          ),

          const SizedBox(height: 12),

          // ───────── DATE RANGE ─────────
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              _range == null
                  ? t.t('admin.pickDateRange')
                  : '${_range!.start.toLocal().toString().split(' ').first}'
                  ' → '
                  '${_range!.end.toLocal().toString().split(' ').first}',
            ),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 1),
              );
              if (picked != null) {
                setState(() => _range = picked);
              }
            },
          ),

          const SizedBox(height: 18),

          Text(
            t.t('admin.exportPreview'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          // ───────── PREVIEW (UI ONLY) ─────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t.t('admin.exportFormat')}: $_format'),
                  Text('${t.t('admin.exportScope')}: $_scope'),
                  Text(
                    '${t.t('admin.exportRange')}: '
                        '${_range == null ? t.t('common.notSelected') : t.t('common.selected')}',
                  ),
                  const Divider(height: 22),
                  Text(
                    t.t('admin.exportPreviewNote'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ───────── EXPORT ACTION ─────────
          FilledButton.icon(
            icon: const Icon(Icons.download),
            label: Text(t.t('admin.exportPlaceholder')),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    t.t('admin.exportNotConnected'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}