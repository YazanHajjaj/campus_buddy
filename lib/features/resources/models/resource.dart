import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for a resource stored in Firestore.
class Resource {
  final String id;                // Firestore doc ID
  final String title;             // Resource title
  final String description;       // Short description
  final String fileUrl;           // Public storage URL
  final String storagePath;       // Firebase Storage path
  final String uploaderUserId;    // UID of uploader
  final String? uploaderDisplayName;
  final String? courseCode;       // Optional course code
  final String? semester;         // Optional semester
  final List<String> tags;        // Lowercase tags used for filtering
  final int sizeInBytes;          // File size
  final String mimeType;          // MIME type
  final bool isActive;            // Soft delete flag
  final bool isPublic;            // Visibility flag
  final int downloadCount;        // Analytics
  final int viewCount;            // Analytics
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;

  const Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.storagePath,
    required this.uploaderUserId,
    this.uploaderDisplayName,
    this.courseCode,
    this.semester,
    required this.tags,
    required this.sizeInBytes,
    required this.mimeType,
    required this.isActive,
    required this.isPublic,
    required this.downloadCount,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
  });

  /// Creates a new instance with modified fields.
  Resource copyWith({
    String? id,
    String? title,
    String? description,
    String? fileUrl,
    String? storagePath,
    String? uploaderUserId,
    String? uploaderDisplayName,
    String? courseCode,
    String? semester,
    List<String>? tags,
    int? sizeInBytes,
    String? mimeType,
    bool? isActive,
    bool? isPublic,
    int? downloadCount,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
      uploaderUserId: uploaderUserId ?? this.uploaderUserId,
      uploaderDisplayName: uploaderDisplayName ?? this.uploaderDisplayName,
      courseCode: courseCode ?? this.courseCode,
      semester: semester ?? this.semester,
      tags: tags ?? this.tags,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      mimeType: mimeType ?? this.mimeType,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      downloadCount: downloadCount ?? this.downloadCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  /// Converts the object into a Firestore map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'storagePath': storagePath,
      'uploaderUserId': uploaderUserId,
      'uploaderDisplayName': uploaderDisplayName,
      'courseCode': courseCode,
      'semester': semester,
      'tags': tags,
      'sizeInBytes': sizeInBytes,
      'mimeType': mimeType,
      'isActive': isActive,
      'isPublic': isPublic,
      'downloadCount': downloadCount,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastAccessedAt': lastAccessedAt != null
          ? Timestamp.fromDate(lastAccessedAt!)
          : null,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  /// Constructs a Resource object from a Firestore map.
  factory Resource.fromMap(Map<String, dynamic> data, {String? documentId}) {
    DateTime toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    DateTime? toDateNullable(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    final rawTags = (data['tags'] as List?) ?? [];

    return Resource(
      id: documentId ?? (data['id'] as String? ?? ''),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      fileUrl: data['fileUrl'] as String? ?? '',
      storagePath: data['storagePath'] as String? ?? '',
      uploaderUserId: data['uploaderUserId'] as String? ?? '',
      uploaderDisplayName: data['uploaderDisplayName'] as String?,
      courseCode: data['courseCode'] as String?,
      semester: data['semester'] as String?,
      tags: rawTags.map((e) => e.toString()).toList(),
      sizeInBytes: (data['sizeInBytes'] as num?)?.toInt() ?? 0,
      mimeType: data['mimeType'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      isPublic: data['isPublic'] as bool? ?? true,
      downloadCount: (data['downloadCount'] as num?)?.toInt() ?? 0,
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      createdAt: toDate(data['createdAt']),
      updatedAt: toDate(data['updatedAt']),
      lastAccessedAt: toDateNullable(data['lastAccessedAt']),
    );
  }

  /// Constructs a Resource from a Firestore document snapshot.
  factory Resource.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    if (data == null) {
      return Resource(
        id: doc.id,
        title: '',
        description: '',
        fileUrl: '',
        storagePath: '',
        uploaderUserId: '',
        tags: const [],
        sizeInBytes: 0,
        mimeType: '',
        isActive: false,
        isPublic: false,
        downloadCount: 0,
        viewCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastAccessedAt: null,
      );
    }
    return Resource.fromMap(data, documentId: doc.id);
  }
}
