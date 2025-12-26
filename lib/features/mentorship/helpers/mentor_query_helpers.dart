import '../models/mentor_profile.dart';

/// Query helper contracts for mentor filtering and sorting.
///
/// NOTE:
/// - Logic is intentionally not implemented yet
/// - Mentor fields are not finalized
/// - Methods currently return input unchanged by design

class MentorQueryHelpers {
  static List<MentorProfile> filterByDepartment(
      List<MentorProfile> mentors,
      String department,
      ) {
    return mentors;
  }

  static List<MentorProfile> sortByRating(
      List<MentorProfile> mentors, {
        bool descending = true,
      }) {
    return mentors;
  }

  static List<MentorProfile> sortByExperience(
      List<MentorProfile> mentors, {
        bool descending = true,
      }) {
    return mentors;
  }
}