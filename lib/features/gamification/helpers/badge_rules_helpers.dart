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
///
/// IMPORTANT:
/// - No evaluation logic here
/// - No localization resolution here
/// - Uses translation KEYS only
class BadgeRule {
  final String id;
  final BadgeTrigger trigger;

  /// Localization keys (resolved in UI / notifications)
  final String titleKey;
  final String descriptionKey;

  /// Icon asset name or identifier
  final String icon;

  /// Required progress count to unlock
  final int requiredCount;

  /// Must match analytics / XP source keys
  final String sourceKey;

  const BadgeRule({
    required this.id,
    required this.trigger,
    required this.titleKey,
    required this.descriptionKey,
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
    titleKey: 'badges.firstResource.title',
    descriptionKey: 'badges.firstResource.desc',
    icon: 'badge_upload_1',
    requiredCount: 1,
    sourceKey: 'resource.uploaded',
  );

  static const BadgeRule resourceExplorer = BadgeRule(
    id: 'badge.resource_explorer',
    trigger: BadgeTrigger.resource,
    titleKey: 'badges.resourceExplorer.title',
    descriptionKey: 'badges.resourceExplorer.desc',
    icon: 'badge_resource_explorer',
    requiredCount: 20,
    sourceKey: 'resource.viewed',
  );

  // ---------------- Events ----------------

  static const BadgeRule firstEventAttended = BadgeRule(
    id: 'badge.first_event',
    trigger: BadgeTrigger.event,
    titleKey: 'badges.firstEvent.title',
    descriptionKey: 'badges.firstEvent.desc',
    icon: 'badge_event_1',
    requiredCount: 1,
    sourceKey: 'event.attended',
  );

  static const BadgeRule eventExplorer = BadgeRule(
    id: 'badge.event_explorer',
    trigger: BadgeTrigger.event,
    titleKey: 'badges.eventExplorer.title',
    descriptionKey: 'badges.eventExplorer.desc',
    icon: 'badge_event_5',
    requiredCount: 5,
    sourceKey: 'event.attended',
  );

  // ---------------- Mentorship ----------------

  static const BadgeRule mentorBuddy = BadgeRule(
    id: 'badge.mentor_buddy',
    trigger: BadgeTrigger.mentorship,
    titleKey: 'badges.mentorBuddy.title',
    descriptionKey: 'badges.mentorBuddy.desc',
    icon: 'badge_mentor_1',
    requiredCount: 1,
    sourceKey: 'mentorship.session_completed',
  );

  static const BadgeRule mentorshipActive = BadgeRule(
    id: 'badge.mentorship_active',
    trigger: BadgeTrigger.mentorship,
    titleKey: 'badges.mentorshipActive.title',
    descriptionKey: 'badges.mentorshipActive.desc',
    icon: 'badge_mentor_5',
    requiredCount: 5,
    sourceKey: 'mentorship.session_completed',
  );

  // ---------------- Study Groups ----------------

  static const BadgeRule firstStudyGroup = BadgeRule(
    id: 'badge.study_group_join',
    trigger: BadgeTrigger.studyGroup,
    titleKey: 'badges.studyGroup.title',
    descriptionKey: 'badges.studyGroup.desc',
    icon: 'badge_group_1',
    requiredCount: 1,
    sourceKey: 'study_group.joined',
  );

  static const BadgeRule studyGroupContributor = BadgeRule(
    id: 'badge.study_group_chat',
    trigger: BadgeTrigger.studyGroup,
    titleKey: 'badges.studyGroupChat.title',
    descriptionKey: 'badges.studyGroupChat.desc',
    icon: 'badge_group_chat',
    requiredCount: 50,
    sourceKey: 'study_group.chat_message',
  );

  // ---------------- Streaks ----------------

  static const BadgeRule activeStreak7 = BadgeRule(
    id: 'badge.streak_7',
    trigger: BadgeTrigger.streak,
    titleKey: 'badges.streak7.title',
    descriptionKey: 'badges.streak7.desc',
    icon: 'badge_streak_7',
    requiredCount: 7,
    sourceKey: 'system.daily_active',
  );

  static const BadgeRule activeStreak30 = BadgeRule(
    id: 'badge.streak_30',
    trigger: BadgeTrigger.streak,
    titleKey: 'badges.streak30.title',
    descriptionKey: 'badges.streak30.desc',
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