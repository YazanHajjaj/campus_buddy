import 'package:campus_buddy/features/resources/models/resource.dart';

/// Contract for the Resource Library backend layer.
/// UI and other modules should depend on this interface.
abstract class ResourceService {
  /// Creates a new resource entry.
  /// The file must already be uploaded to storage.
  Future<Resource> createResource({
    required String title,
    required String description,
    required String storagePath,
    required String fileUrl,
    required String uploaderUserId,
    String? uploaderDisplayName,
    String? courseCode,
    String? semester,
    List<String> tags,
    required int sizeInBytes,
    required String mimeType,
    bool isPublic,
  });

  /// Updates editable fields of an existing resource.
  /// Does not modify storagePath, fileUrl, or uploaderUserId.
  Future<void> updateResource({
    required String resourceId,
    String? title,
    String? description,
    List<String>? tags,
    String? courseCode,
    String? semester,
    bool? isPublic,
    bool? isActive,
  });

  /// Marks a resource as inactive (soft delete).
  Future<void> softDeleteResource(String resourceId);

  /// Fetches a single active resource by ID.
  Future<Resource?> getResourceById(String resourceId);

  /// Stream of updates for a specific resource document.
  Stream<Resource?> watchResourceById(String resourceId);

  /// Stream of recent active resources, ordered by creation time.
  Stream<List<Resource>> watchRecentResources({int limit = 50});

  /// Fetches resources with optional filters.
  Future<List<Resource>> fetchResources({
    String? courseCode,
    String? tag,
    String? uploaderUserId,
    bool onlyActive,
    bool onlyPublic,
    int? limit,
  });

  /// Increments download count.
  Future<void> incrementDownloadCount(String resourceId);

  /// Increments view count and updates lastAccessedAt.
  Future<void> incrementViewCount(String resourceId);
}
