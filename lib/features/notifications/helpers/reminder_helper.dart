import '../../study_groups/models/study_group_session.dart';

class ReminderHelper {
  /// Generate a stable reminder ID from a session
  /// (important so we can cancel/update later)
  static int sessionReminderId(
      String groupId,
      String sessionId,
      ) {
    return (groupId + sessionId).hashCode;
  }

  /// Build reminder title
  static String sessionReminderTitle({
    required String groupTitle,
  }) {
    return groupTitle;
  }

  /// Build reminder body
  static String sessionReminderBody({
    required StudyGroupSession session,
  }) {
    return '${session.title} • ${session.startTime}–${session.endTime}';
  }

  /// Default reminder time
  /// (30 minutes before session)
  static DateTime sessionReminderTime(
      StudyGroupSession session,
      ) {
    final sessionDate = session.date.toDate();

    final startParts = session.startTime.split(':');
    final hour = int.parse(startParts[0]);
    final minute = int.parse(startParts[1]);

    final startDateTime = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      hour,
      minute,
    );

    return startDateTime.subtract(const Duration(minutes: 30));
  }

  /// Payload contract for routing
  static Map<String, dynamic> sessionPayload({
    required String groupId,
    required String sessionId,
  }) {
    return {
      'type': 'study_group_session',
      'groupId': groupId,
      'sessionId': sessionId,
    };
  }
}