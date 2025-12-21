import 'dart:convert';

import '../models/student_analytics.dart';
import '../models/admin_stats.dart';

class ReportExportService {
  /// Generates a CSV report for a single student.
  /// Used by the student dashboard export action.
  String exportStudentAnalyticsToCsv(StudentAnalytics analytics) {
    final rows = <List<String>>[
      ['Metric', 'Value'],
      ['Resources Uploaded', analytics.resourcesUploadedCount.toString()],
      ['Mentorship Sessions', analytics.mentorshipSessionsCount.toString()],
      ['Mentorship Hours',
        analytics.mentorshipHoursTotal.toStringAsFixed(2)],
      ['Events RSVPed', analytics.eventsRsvpCount.toString()],
      [
        'Last Mentorship Session',
        analytics.mentorshipLastSessionAt?.toIso8601String() ?? 'N/A'
      ],
      [
        'Last Event RSVP',
        analytics.eventsLastRsvpAt?.toIso8601String() ?? 'N/A'
      ],
      [
        'Last Activity',
        analytics.usageMetrics.lastActiveAt?.toIso8601String() ?? 'N/A'
      ],
    ];

    return _toCsv(rows);
  }

  /// Generates a CSV report containing system-wide admin statistics.
  /// Intended for admin dashboard exports.
  String exportAdminStatsToCsv(AdminStats stats) {
    final rows = <List<String>>[
      ['Metric', 'Value'],
      ['Total Users', stats.totalUsers.toString()],
      ['Active Users (7 days)', stats.activeUsersLast7Days.toString()],
      ['Active Users (30 days)', stats.activeUsersLast30Days.toString()],
      [
        'Total Mentorship Sessions',
        stats.totalMentorshipSessions.toString()
      ],
      [
        'Total Mentorship Hours',
        stats.totalMentorshipHours.toStringAsFixed(2)
      ],
      ['Total Events', stats.totalEvents.toString()],
      ['Total Event RSVPs', stats.totalEventRsvps.toString()],
      ['Total Resources', stats.totalResources.toString()],
      [
        'Total Resource Downloads',
        stats.totalResourceDownloads.toString()
      ],
      ['Total Resource Views', stats.totalResourceViews.toString()],
      [
        'Last Updated',
        stats.lastUpdatedAt?.toIso8601String() ?? 'N/A'
      ],
    ];

    return _toCsv(rows);
  }

  /// Generates a JSON report for student analytics.
  /// Useful for PDF generation or future API integrations.
  String exportStudentAnalyticsToJson(StudentAnalytics analytics) {
    return jsonEncode(analytics.toMap());
  }

  /// Generates a JSON report for admin analytics.
  String exportAdminStatsToJson(AdminStats stats) {
    return jsonEncode(stats.toMap());
  }

  String _toCsv(List<List<String>> rows) {
    final buffer = StringBuffer();

    for (final row in rows) {
      buffer.writeln(
        row.map(_escapeCsvValue).join(','),
      );
    }

    return buffer.toString();
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}