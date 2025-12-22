enum XpSource {
  resources,
  events,
  mentorship,
  studyGroups,
  system,
}

class XpRule {
  final String key;
  final XpSource source;
  final int amount;
  final String label;
  final bool repeatable;
  final int? dailyCap;

  const XpRule({
    required this.key,
    required this.source,
    required this.amount,
    required this.label,
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
    label: 'Viewed a resource',
    repeatable: true,
    dailyCap: 150, // avoid farming
  );

  static const XpRule resourceDownloaded = XpRule(
    key: 'resource.downloaded',
    source: XpSource.resources,
    amount: 12,
    label: 'Downloaded a resource',
    repeatable: true,
    dailyCap: 120, // capped daily
  );

  static const XpRule resourceUploaded = XpRule(
    key: 'resource.uploaded',
    source: XpSource.resources,
    amount: 25,
    label: 'Uploaded a resource',
    repeatable: true,
    dailyCap: 75, // heavier action
  );

  // ---------------- Events ----------------

  static const XpRule eventRsvp = XpRule(
    key: 'event.rsvp',
    source: XpSource.events,
    amount: 8,
    label: 'RSVP’d to an event',
    repeatable: true,
    dailyCap: 40,
  );

  static const XpRule eventAttended = XpRule(
    key: 'event.attended',
    source: XpSource.events,
    amount: 20,
    label: 'Attended an event',
    repeatable: true,
    dailyCap: 60, // attendance > intent
  );

  // ---------------- Mentorship ----------------

  static const XpRule mentorshipRequestSent = XpRule(
    key: 'mentorship.request_sent',
    source: XpSource.mentorship,
    amount: 10,
    label: 'Sent a mentorship request',
    repeatable: false, // repeatable vs not
  );

  static const XpRule mentorshipSessionCompleted = XpRule(
    key: 'mentorship.session_completed',
    source: XpSource.mentorship,
    amount: 30,
    label: 'Completed a mentorship session',
    repeatable: true,
    dailyCap: 60,
  );

  static const XpRule mentorshipChatMessage = XpRule(
    key: 'mentorship.chat_message',
    source: XpSource.mentorship,
    amount: 5,
    label: 'Sent a mentorship message',
    repeatable: true,
    dailyCap: 150, // avoid spam
  );

  // ---------------- Study Groups ----------------

  static const XpRule studyGroupJoined = XpRule(
    key: 'study_group.joined',
    source: XpSource.studyGroups,
    amount: 15,
    label: 'Joined a study group',
    repeatable: false,
  );

  static const XpRule studyGroupChatMessage = XpRule(
    key: 'study_group.chat_message',
    source: XpSource.studyGroups,
    amount: 4,
    label: 'Sent a study group message',
    repeatable: true,
    dailyCap: 120,
  );

  // ---------------- System ----------------
  // depends on analytics (active days, streaks)

  static const XpRule dailyActive = XpRule(
    key: 'system.daily_active',
    source: XpSource.system,
    amount: 10,
    label: 'Active day bonus',
    repeatable: true,
    dailyCap: 10,
  );

  static const XpRule streakBonus7 = XpRule(
    key: 'system.streak_7',
    source: XpSource.system,
    amount: 40,
    label: '7-day streak bonus',
    repeatable: true,
    dailyCap: 40,
  );

  static const XpRule streakBonus30 = XpRule(
    key: 'system.streak_30',
    source: XpSource.system,
    amount: 120,
    label: '30-day streak bonus',
    repeatable: true,
    dailyCap: 120,
  );

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