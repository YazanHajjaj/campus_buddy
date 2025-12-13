// ---------------------------------------------
// RESOURCE QUERY HELPERS (Mahmoud)
// Phase 2 - Campus Buddy
// ---------------------------------------------

import 'package:campus_buddy/features/resources/models/resource.dart';

class ResourceQueryHelpers {
  /// Get newest resources (sorted by createdAt descending)
  Future<List<Resource>> getRecentResources() async {
    // TODO: will be implemented after Yazan finishes the model
    return [];
  }

  /// Get top downloaded resources
  Future<List<Resource>> getTopResourcesByDownloads(int limit) async {
    // TODO
    return [];
  }

  /// Filter resources by course code
  Future<List<Resource>> getResourcesByCourse(String courseCode) async {
    // TODO
    return [];
  }

  /// Filter resources by tag
  Future<List<Resource>> getResourcesByTag(String tag) async {
    // TODO
    return [];
  }

  /// Search resources by title (client-side or Firestore)
  Future<List<Resource>> searchResourcesByTitle(String query) async {
    // TODO
    return [];
  }

  /// Pagination: get next page of results
  Future<List<Resource>> getNextPage(dynamic lastDocument, int limit) async {
    // TODO
    return [];
  }
}
