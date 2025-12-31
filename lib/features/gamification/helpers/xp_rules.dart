/// Defines where XP originates from.
/// Used for grouping, analytics, and UI sections.
enum XpSource {
  resources,
  events,
  mentorship,
  studyGroups,
  system,
}

/// Declarative XP rule.
/// IMPORTANT:
/// - No logic here
/// - No localization resolution here
/// - Uses translation KEYS only
class XpRule {
  final String key;
  final XpSource source;

  /// XP amount granted per action
  final int amount;

  /// Localization key for UI & notifications
  final String labelKey;

  /// Whether the action can be repeated
  final bool repeatable;

  /// Optional daily XP cap (anti-farming)
  final int? dailyCap;

  const XpRule({
    required this.key,
    required this.source,
    required this.amount,
    required this.labelKey,
    required this.repeatable,
    this.dailyCap,
  });
}

class XpRules {
  XpRules._();

  // ---------------- Resources ----------------

  static const XpRule resourceViewed = XpRule(
    key: 'resource.viewed',
    source: XpSource.resources,
    amount: 10,
    labelKey: 'xp.resourceViewed',
    repeatable: true,
    dailyCap: 150,
  );

  static const XpRule resourceDownloaded = XpRule(
    key: 'resource.downloaded',
    source: XpSource.resources,
    amount: 12,
    labelKey: 'xp.resourceDownloaded',
    repeatable: true,
    dailyCap: 120,
  );

  static const XpRule resourceUploaded = XpRule(
    key: 'resource.uploaded',
    source: XpSource.resources,
    amount: 25,
    labelKey: 'xp.resourceUploaded',
    repeatable: true,
    dailyCap: 75,
  );

  // ---------------- Events ----------------

  static const XpRule eventRsvp = XpRule(
    key: 'event.rsvp',
    source: XpSource.events,
    amount: 8,
    labelKey: 'xp.eventRsvp',
    repeatable: true,
    dailyCap: 40,
  );

  static const XpRule eventAttended = XpRule(
    key: 'event.attended',
    source: XpSource.events,
    amount: 20,
    labelKey: 'xp.eventAttended',
    repeatable: true,
    dailyCap: 60,
  );

  // ---------------- Mentorship ----------------

  static const XpRule mentorshipRequestSent = XpRule(
    key: 'mentorship.request_sent',
    source: XpSource.mentorship,
    amount: 10,
    labelKey: 'xp.mentorshipRequestSent',
    repeatable: false,
  );

  static const XpRule mentorshipSessionCompleted = XpRule(
    key: 'mentorship.session_completed',
    source: XpSource.mentorship,
    amount: 30,
    labelKey: 'xp.mentorshipSessionCompleted',
    repeatable: true,
    dailyCap: 60,
  );

  static const XpRule mentorshipChatMessage = XpRule(
    key: 'mentorship.chat_message',
    source: XpSource.mentorship,
    amount: 5,
    labelKey: 'xp.mentorshipChatMessage',
    repeatable: true,
    dailyCap: 150,
  );

  // ---------------- Study Groups ----------------

  static const XpRule studyGroupJoined = XpRule(
    key: 'study_group.joined',
    source: XpSource.studyGroups,
    amount: 15,
    labelKey: 'xp.studyGroupJoined',
    repeatable: false,
  );

  static const XpRule studyGroupChatMessage = XpRule(
    key: 'study_group.chat_message',
    source: XpSource.studyGroups,
    amount: 4,
    labelKey: 'xp.studyGroupChatMessage',
    repeatable: true,
    dailyCap: 120,
  );

  // ---------------- System ----------------

  static const XpRule dailyActive = XpRule(
    key: 'system.daily_active',
    source: XpSource.system,
    amount: 10,
    labelKey: 'xp.dailyActive',
    repeatable: true,
    dailyCap: 10,
  );

  static const XpRule streakBonus7 = XpRule(
    key: 'system.streak_7',
    source: XpSource.system,
    amount: 40,
    labelKey: 'xp.streak7',
    repeatable: true,
    dailyCap: 40,
  );

  static const XpRule streakBonus30 = XpRule(
    key: 'system.streak_30',
    source: XpSource.system,
    amount: 120,
    labelKey: 'xp.streak30',
    repeatable: true,
    dailyCap: 120,
  );

  // ---------------- Registry ----------------

  static const List<XpRule> all = [
    resourceViewed,
    resourceDownloaded,
    resourceUploaded,
    eventRsvp,
    eventAttended,
    mentorshipRequestSent,
    mentorshipSessionCompleted,
    mentorshipChatMessage,
    studyGroupJoined,
    studyGroupChatMessage,
    dailyActive,
    streakBonus7,
    streakBonus30,
  ];

  static const Map<String, XpRule> byKey = {
    'resource.viewed': resourceViewed,
    'resource.downloaded': resourceDownloaded,
    'resource.uploaded': resourceUploaded,
    'event.rsvp': eventRsvp,
    'event.attended': eventAttended,
    'mentorship.request_sent': mentorshipRequestSent,
    'mentorship.session_completed': mentorshipSessionCompleted,
    'mentorship.chat_message': mentorshipChatMessage,
    'study_group.joined': studyGroupJoined,
    'study_group.chat_message': studyGroupChatMessage,
    'system.daily_active': dailyActive,
    'system.streak_7': streakBonus7,
    'system.streak_30': streakBonus30,
  };

  /// Converts total XP into a level.
  ///
  /// Rules:
  /// - Level 1 starts at 0 XP
  /// - Each level requires +50 XP more than the previous
  /// - Hard cap at level 50
  static int levelForTotalXp(int totalXp) {
    if (totalXp < 0) return 1;

    int level = 1;
    int threshold = 0;
    int step = 100;

    while (totalXp >= threshold + step) {
      threshold += step;
      level += 1;
      step += 50;

      if (level > 50) break;
    }

    return level;
  }
}