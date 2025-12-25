class MentorQueryHelpers {
  /// Filter mentors by department
  static List<T> filterByDepartment<T>(
    List<T> mentors,
    String department,
  ) {
    // TODO: implement once mentor model fields are finalized
    return mentors;
  }

  /// Sort mentors by rating
  static List<T> sortByRating<T>(
    List<T> mentors, {
    bool descending = true,
  }) {
    // TODO: implement sorting logic
    return mentors;
  }

  /// Sort mentors by years of experience
  static List<T> sortByExperience<T>(
    List<T> mentors, {
    bool descending = true,
  }) {
    // TODO: implement sorting logic
    return mentors;
  }

  /// Filter mentors by availability
  static List<T> filterByAvailability<T>(
    List<T> mentors,
    dynamic availability,
  ) {
    // TODO: depends on availability model
    return mentors;
  }
}
