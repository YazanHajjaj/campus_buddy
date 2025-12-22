/// What kind of progress a badge depends on.
/// Used later by analytics / evaluation logic.
enum BadgeTrigger {
  resource,
  event,
  mentorship,
  studyGroup,
  streak,
  system,
}

/// Declarative badge definition.
/// No evaluation logic here.
class BadgeRule {
  final String id;
  final BadgeTrigger trigger;
  final String title;
  final String description;
  final String icon; // icon asset or name
  final int requiredCount;
  final String sourceKey; // must match xp / analytics keys

  const BadgeRule({
    required this.id,
    required this.trigger,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.sourceKey,
  });
}

class BadgeRules {
  BadgeRules._();

  // ---------------- Resources ----------------

  static const BadgeRule firstResourceUpload = BadgeRule(
    id: 'badge.first_resource_upload',
    trigger: BadgeTrigger.resource,
    title: 'First Contribution',
    description: 'Uploaded your first resource',
    icon: 'badge_upload_1',
    requiredCount: 1,
    sourceKey: 'resource.uploaded',
  );

  static const BadgeRule resourceExplorer = BadgeRule(
    id: 'badge.resource_explorer',
    trigger: BadgeTrigger.resource,
    title: 'Resource Explorer',
    description: 'Viewed 20 resources',
    icon: 'badge_resource_explorer',
    requiredCount: 20,
    sourceKey: 'resource.viewed',
  );

  // ---------------- Events ----------------

  static const BadgeRule firstEventAttended = BadgeRule(
    id: 'badge.first_event',
    trigger: BadgeTrigger.event,
    title: 'First Event',
    description: 'Attended your first event',
    icon: 'badge_event_1',
    requiredCount: 1,
    sourceKey: 'event.attended',
  );

  static const BadgeRule eventExplorer = BadgeRule(
    id: 'badge.event_explorer',
    trigger: BadgeTrigger.event,
    title: 'Event Explorer',
    description: 'Attended 5 events',
    icon: 'badge_event_5',
    requiredCount: 5,
    sourceKey: 'event.attended',
  );

  // ---------------- Mentorship ----------------

  static const BadgeRule mentorBuddy = BadgeRule(
    id: 'badge.mentor_buddy',
    trigger: BadgeTrigger.mentorship,
    title: 'Mentor Buddy',
    description: 'Completed your first mentorship session',
    icon: 'badge_mentor_1',
    requiredCount: 1,
    sourceKey: 'mentorship.session_completed',
  );

  static const BadgeRule mentorshipActive = BadgeRule(
    id: 'badge.mentorship_active',
    trigger: BadgeTrigger.mentorship,
    title: 'Mentorship Active',
    description: 'Completed 5 mentorship sessions',
    icon: 'badge_mentor_5',
    requiredCount: 5,
    sourceKey: 'mentorship.session_completed',
  );

  // ---------------- Study Groups ----------------

  static const BadgeRule firstStudyGroup = BadgeRule(
    id: 'badge.study_group_join',
    trigger: BadgeTrigger.studyGroup,
    title: 'Study Group Member',
    description: 'Joined your first study group',
    icon: 'badge_group_1',
    requiredCount: 1,
    sourceKey: 'study_group.joined',
  );

  static const BadgeRule studyGroupContributor = BadgeRule(
    id: 'badge.study_group_chat',
    trigger: BadgeTrigger.studyGroup,
    title: 'Group Contributor',
    description: 'Sent 50 study group messages',
    icon: 'badge_group_chat',
    requiredCount: 50,
    sourceKey: 'study_group.chat_message',
  );

  // ---------------- Streaks ----------------
  // depends on analytics active-day tracking

  static const BadgeRule activeStreak7 = BadgeRule(
    id: 'badge.streak_7',
    trigger: BadgeTrigger.streak,
    title: 'Consistent Learner',
    description: 'Active for 7 consecutive days',
    icon: 'badge_streak_7',
    requiredCount: 7,
    sourceKey: 'system.daily_active',
  );

  static const BadgeRule activeStreak30 = BadgeRule(
    id: 'badge.streak_30',
    trigger: BadgeTrigger.streak,
    title: 'Dedicated Scholar',
    description: 'Active for 30 consecutive days',
    icon: 'badge_streak_30',
    requiredCount: 30,
    sourceKey: 'system.daily_active',
  );

  // ---------------- Registry ----------------

  static const List<BadgeRule> all = [
    firstResourceUpload,
    resourceExplorer,
    firstEventAttended,
    eventExplorer,
    mentorBuddy,
    mentorshipActive,
    firstStudyGroup,
    studyGroupContributor,
    activeStreak7,
    activeStreak30,
  ];

  static const Map<String, BadgeRule> byId = {
    'badge.first_resource_upload': firstResourceUpload,
    'badge.resource_explorer': resourceExplorer,
    'badge.first_event': firstEventAttended,
    'badge.event_explorer': eventExplorer,
    'badge.mentor_buddy': mentorBuddy,
    'badge.mentorship_active': mentorshipActive,
    'badge.study_group_join': firstStudyGroup,
    'badge.study_group_chat': studyGroupContributor,
    'badge.streak_7': activeStreak7,
    'badge.streak_30': activeStreak30,
  };
}