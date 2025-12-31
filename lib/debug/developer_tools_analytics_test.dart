import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../features/analytics/services/analytics_service.dart';
import '../features/analytics/services/report_export_service.dart';
import '../features/analytics/models/student_analytics.dart';
import '../features/analytics/models/admin_stats.dart';

class DeveloperToolsAnalyticsTest extends StatefulWidget {
  const DeveloperToolsAnalyticsTest({super.key});

  @override
  State<DeveloperToolsAnalyticsTest> createState() =>
      _DeveloperToolsAnalyticsTestState();
}

class _DeveloperToolsAnalyticsTestState
    extends State<DeveloperToolsAnalyticsTest> {
  final _uidController = TextEditingController();

  final _analyticsService = AnalyticsService();
  final _exportService = ReportExportService();

  StudentAnalytics? _studentAnalytics;
  AdminStats? _adminStats;

  bool _loadingStudent = false;
  bool _loadingAdmin = false;

  Future<void> _loadStudentAnalytics() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;

    setState(() => _loadingStudent = true);

    try {
      final result = await _analyticsService.getStudentAnalytics(uid);
      setState(() => _studentAnalytics = result);
    } finally {
      setState(() => _loadingStudent = false);
    }
  }

  Future<void> _loadAdminStats() async {
    setState(() => _loadingAdmin = true);

    try {
      final result = await _analyticsService.getAdminStats();
      setState(() => _adminStats = result);
    } finally {
      setState(() => _loadingAdmin = false);
    }
  }

  void _showExport(String content) {
    final t = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.t('common.export')),
        content: SingleChildScrollView(
          child: SelectableText(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('common.close')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('admin.analyticsDebug')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.t('analytics.student'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _uidController,
            decoration: InputDecoration(
              labelText: t.t('analytics.studentUid'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadingStudent ? null : _loadStudentAnalytics,
            child: _loadingStudent
                ? const CircularProgressIndicator()
                : Text(t.t('analytics.loadStudent')),
          ),
          if (_studentAnalytics != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final csv = _exportService
                    .exportStudentAnalyticsToCsv(_studentAnalytics!);
                _showExport(csv);
              },
              child: Text(t.t('analytics.exportStudent')),
            ),
            const SizedBox(height: 8),
            SelectableText(_studentAnalytics!.toMap().toString()),
          ],
          const Divider(height: 32),
          Text(
            t.t('analytics.admin'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadingAdmin ? null : _loadAdminStats,
            child: _loadingAdmin
                ? const CircularProgressIndicator()
                : Text(t.t('analytics.loadAdmin')),
          ),
          if (_adminStats != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final csv =
                _exportService.exportAdminStatsToCsv(_adminStats!);
                _showExport(csv);
              },
              child: Text(t.t('analytics.exportAdmin')),
            ),
            const SizedBox(height: 8),
            SelectableText(_adminStats!.toMap().toString()),
          ],
        ],
      ),
    );
  }
}