import '../../analytics/models/student_analytics.dart';
import '../models/achievement.dart';

class AchievementService {
  List<Achievement> buildAchievements({
    required StudentAnalytics analytics,
    required int xp,
  }) {
    final now = DateTime.now();

    Achievement _build({
      required String id,
      required String title,
      required String description,
      required int current,
      required int required,
    }) {
      final completed = current >= required;
      return Achievement(
        id: id,
        title: title,
        description: description,
        requiredCount: required,
        currentCount: current,
        completed: completed,
        completedAt: completed ? now : null,
      );
    }

    return [
      _build(
        id: 'ach_upload_1',
        title: 'First Resource',
        description: 'Upload your first study resource',
        current: analytics.resourcesUploadedCount,
        required: 1,
      ),
      _build(
        id: 'ach_upload_5',
        title: 'Contributor',
        description: 'Upload 5 study resources',
        current: analytics.resourcesUploadedCount,
        required: 5,
      ),
      _build(
        id: 'ach_events_3',
        title: 'Active Student',
        description: 'Join 3 campus events',
        current: analytics.eventsRsvpCount,
        required: 3,
      ),
      _build(
        id: 'ach_mentor_1',
        title: 'Mentee',
        description: 'Complete a mentorship session',
        current: analytics.mentorshipSessionsCount,
        required: 1,
      ),
      _build(
        id: 'ach_xp_100',
        title: 'XP Beginner',
        description: 'Earn 100 XP',
        current: xp,
        required: 100,
      ),
    ];
  }
}