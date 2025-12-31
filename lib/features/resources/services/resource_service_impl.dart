import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_buddy/features/resources/models/resource.dart';
import 'package:campus_buddy/features/analytics/services/analytics_service.dart';

import 'resource_service.dart';

class FirestoreResourceService implements ResourceService {
  final FirebaseFirestore _firestore;
  final AnalyticsService _analytics;

  static const String resourcesCollection = 'resources';

  FirestoreResourceService({
    FirebaseFirestore? firestore,
    AnalyticsService? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? AnalyticsService();

  CollectionReference<Map<String, dynamic>> get _resourcesRef =>
      _firestore.collection(resourcesCollection);

  /* ───────── CREATE ───────── */

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
    final normalizedTags = tags
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    final docRef = _resourcesRef.doc();
    final now = DateTime.now();

    final resource = Resource(
      id: docRef.id,
      title: title,
      description: description,
      fileUrl: fileUrl,
      storagePath: storagePath,
      uploaderUserId: uploaderUserId, // <-- THIS MUST MATCH ANALYTICS QUERY
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

    final data = resource.toMap()
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

    await docRef.set(data);

    //  Analytics trigger for HomePage refresh (NON-BLOCKING)
    try {
      await _analytics.logResourceUploaded(
        uid: uploaderUserId,
        resourceId: docRef.id,
      );
    } catch (_) {}

    final savedDoc = await docRef.get();
    return Resource.fromDocument(savedDoc);
  }

  /* ───────── UPDATE ───────── */

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
    final Map<String, dynamic> updates = {};

    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (courseCode != null) updates['courseCode'] = courseCode;
    if (semester != null) updates['semester'] = semester;
    if (isPublic != null) updates['isPublic'] = isPublic;
    if (isActive != null) updates['isActive'] = isActive;

    if (tags != null) {
      updates['tags'] = tags
          .map((t) => t.trim().toLowerCase())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    if (updates.isEmpty) return;

    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _resourcesRef.doc(resourceId).update(updates);
  }

  /* ───────── DELETE (SOFT) ───────── */

  @override
  Future<void> softDeleteResource(String resourceId) async {
    await _resourcesRef.doc(resourceId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /* ───────── READ ───────── */

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
      final resource = Resource.fromDocument(doc);
      return resource.isActive ? resource : null;
    });
  }

  @override
  Stream<List<Resource>> watchRecentResources({int limit = 50}) {
    return _resourcesRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => Resource.fromDocument(doc))
          .where((r) => r.isActive)
          .toList(),
    );
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

    if (onlyActive) query = query.where('isActive', isEqualTo: true);
    if (onlyPublic) query = query.where('isPublic', isEqualTo: true);

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

    if (limit != null && limit > 0) query = query.limit(limit);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => Resource.fromDocument(doc))
        .where((r) => r.isActive)
        .toList();
  }

  /* ───────── COUNTERS ───────── */

  @override
  Future<void> incrementViewCount(String resourceId) async {
    await _resourcesRef.doc(resourceId).update({
      'viewCount': FieldValue.increment(1),
      'lastAccessedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementDownloadCount(String resourceId) async {
    await _resourcesRef.doc(resourceId).update({
      'downloadCount': FieldValue.increment(1),
      'lastAccessedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}