/// Centralized localization keys for the entire app.
///
/// Rules:
/// - Keys are defined once here
/// - UI must NOT hardcode text
/// - Keys use dot-notation by feature
/// - Do not remove keys once published
///
/// This file intentionally contains NO logic.

class L10nKeys {
  // -------- Auth --------
  static const authSignIn = 'auth.signIn';
  static const authSignUp = 'auth.signUp';
  static const authSignOut = 'auth.signOut';
  static const authEmail = 'auth.email';
  static const authPassword = 'auth.password';
  static const authForgotPassword = 'auth.forgotPassword';

  // -------- Common / Global --------
  static const commonSave = 'common.save';
  static const commonCancel = 'common.cancel';
  static const commonDelete = 'common.delete';
  static const commonConfirm = 'common.confirm';
  static const commonLoading = 'common.loading';
  static const commonError = 'common.error';

  // -------- Navigation --------
  static const navHome = 'nav.home';
  static const navResources = 'nav.resources';
  static const navEvents = 'nav.events';
  static const navMentorship = 'nav.mentorship';
  static const navProfile = 'nav.profile';
  static const navSettings = 'nav.settings';

  // -------- Resources --------
  static const resourcesTitle = 'resources.title';
  static const resourcesUpload = 'resources.upload';
  static const resourcesUploadFile = 'resources.uploadFile';
  static const resourcesDescription = 'resources.description';
  static const resourcesNoItems = 'resources.noItems';

  // -------- Events --------
  static const eventsTitle = 'events.title';
  static const eventsUpcoming = 'events.upcoming';
  static const eventsCreate = 'events.create';
  static const eventsRSVP = 'events.rsvp';
  static const eventsCapacityFull = 'events.capacityFull';

  // -------- Mentorship --------
  static const mentorshipTitle = 'mentorship.title';
  static const mentorshipRequest = 'mentorship.request';
  static const mentorshipAccept = 'mentorship.accept';
  static const mentorshipDecline = 'mentorship.decline';
  static const mentorshipChat = 'mentorship.chat';

  // -------- Study Groups --------
  static const studyGroupsTitle = 'studyGroups.title';
  static const studyGroupsCreate = 'studyGroups.create';
  static const studyGroupsJoin = 'studyGroups.join';
  static const studyGroupsLeave = 'studyGroups.leave';

  // -------- Profile --------
  static const profileTitle = 'profile.title';
  static const profileEdit = 'profile.edit';
  static const profileEmail = 'profile.email';
  static const profileRole = 'profile.role';
  static const profileSaveChanges = 'profile.saveChanges';

  // -------- Notifications --------
  static const notificationsTitle = 'notifications.title';
  static const notificationsSettings = 'notifications.settings';
  static const notificationsEnableEvents = 'notifications.enableEvents';
  static const notificationsEnableMentorship = 'notifications.enableMentorship';
  static const notificationsEnableStudyGroups =
      'notifications.enableStudyGroups';
  static const notificationsEnableGamification =
      'notifications.enableGamification';

  // -------- Gamification --------
  static const gamificationTitle = 'gamification.title';
  static const gamificationLevelUp = 'gamification.levelUp';
  static const gamificationBadgeUnlocked =
      'gamification.badgeUnlocked';

  // -------- Accessibility --------
  static const accessibilityTitle = 'accessibility.title';
  static const accessibilityTextSize = 'accessibility.textSize';
  static const accessibilityHighContrast =
      'accessibility.highContrast';

  // -------- Errors --------
  static const errorGeneric = 'error.generic';
  static const errorNetwork = 'error.network';
  static const errorUnauthorized = 'error.unauthorized';
}