import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_buddy/features/resources/models/resource.dart';
import 'resource_service.dart';

/// Firestore implementation of ResourceService.
/// Handles all read/write operations to the `resources` collection.
class FirestoreResourceService implements ResourceService {
  final FirebaseFirestore _firestore;

  static const String resourcesCollection = 'resources';

  FirestoreResourceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference for `resources`.
  CollectionReference<Map<String, dynamic>> get _resourcesRef =>
      _firestore.collection(resourcesCollection);

  @override
  Future<Resource> createResource({
    required String title,
    required String description,
    required String storagePath,
    required String fileUrl,
    required String uploaderUserId,
    String? uploaderDisplayName,
    String? courseCode,
    String? semester,
    List<String> tags = const [],
    required int sizeInBytes,
    required String mimeType,
    bool isPublic = true,
  }) async {
    // Normalize tags (lowercase, trimmed).
    final normalizedTags = tags
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    // Create document ID in advance.
    final docRef = _resourcesRef.doc();
    final now = DateTime.now();

    final resource = Resource(
      id: docRef.id,
      title: title,
      description: description,
      fileUrl: fileUrl,
      storagePath: storagePath,
      uploaderUserId: uploaderUserId,
      uploaderDisplayName: uploaderDisplayName,
      courseCode: courseCode,
      semester: semester,
      tags: normalizedTags,
      sizeInBytes: sizeInBytes,
      mimeType: mimeType,
      isActive: true,
      isPublic: isPublic,
      downloadCount: 0,
      viewCount: 0,
      createdAt: now,
      updatedAt: now,
      lastAccessedAt: null,
    );

    // Merge with server timestamps for consistency.
    final data = resource.toMap()
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

    await docRef.set(data);

    // Read back to resolve server-side timestamps.
    final savedDoc = await docRef.get();
    return Resource.fromDocument(savedDoc);
  }

  @override
  Future<void> updateResource({
    required String resourceId,
    String? title,
    String? description,
    List<String>? tags,
    String? courseCode,
    String? semester,
    bool? isPublic,
    bool? isActive,
  }) async {
    final updateData = <String, dynamic>{};

    // Update fields only if provided.
    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (courseCode != null) updateData['courseCode'] = courseCode;
    if (semester != null) updateData['semester'] = semester;
    if (isPublic != null) updateData['isPublic'] = isPublic;
    if (isActive != null) updateData['isActive'] = isActive;

    if (tags != null) {
      updateData['tags'] = tags
          .map((t) => t.trim().toLowerCase())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    // Track last update time.
    updateData['updatedAt'] = FieldValue.serverTimestamp();

    if (updateData.isEmpty) return;

    await _resourcesRef.doc(resourceId).update(updateData);
  }

  @override
  Future<void> softDeleteResource(String resourceId) async {
    // Soft delete by disabling visibility.
    await _resourcesRef.doc(resourceId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Resource?> getResourceById(String resourceId) async {
    final doc = await _resourcesRef.doc(resourceId).get();
    if (!doc.exists) return null;

    final resource = Resource.fromDocument(doc);
    return resource.isActive ? resource : null;
  }

  @override
  Stream<Resource?> watchResourceById(String resourceId) {
    return _resourcesRef.doc(resourceId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final r = Resource.fromDocument(doc);
      return r.isActive ? r : null;
    });
  }

  @override
  Stream<List<Resource>> watchRecentResources({int limit = 50}) {
    // List active resources sorted by creation time.
    return _resourcesRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapQueryToResources);
  }

  @override
  Future<List<Resource>> fetchResources({
    String? courseCode,
    String? tag,
    String? uploaderUserId,
    bool onlyActive = true,
    bool onlyPublic = true,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _resourcesRef;

    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (onlyPublic) {
      query = query.where('isPublic', isEqualTo: true);
    }

    if (courseCode != null && courseCode.isNotEmpty) {
      query = query.where('courseCode', isEqualTo: courseCode);
    }

    if (uploaderUserId != null && uploaderUserId.isNotEmpty) {
      query = query.where('uploaderUserId', isEqualTo: uploaderUserId);
    }

    if (tag != null && tag.isNotEmpty) {
      query = query.where('tags', arrayContains: tag.toLowerCase());
    }

    query = query.orderBy('createdAt', descending: true);

    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return _mapQueryToResources(snapshot);
  }

  @override
  Future<void> incrementDownloadCount(String resourceId) async {
    await _resourcesRef.doc(resourceId).update({
      'downloadCount': FieldValue.increment(1),
      'lastAccessedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementViewCount(String resourceId) async {
    await _resourcesRef.doc(resourceId).update({
      'viewCount': FieldValue.increment(1),
      'lastAccessedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Maps a query result into a list of active Resource objects.
  List<Resource> _mapQueryToResources(
      QuerySnapshot<Map<String, dynamic>> snapshot,
      ) {
    return snapshot.docs
        .map((doc) => Resource.fromDocument(doc))
        .where((r) => r.isActive)
        .toList();
  }
}
