import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_user_service.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreUserService _userService = FirestoreUserService();

  /// Base path:
  /// users/{uid}/bookmarks/{type}/items/{itemId}
  CollectionReference<Map<String, dynamic>> _itemsRef({
    required String uid,
    required String type,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(type)
        .collection('items');
  }

  /// True when the item document exists.
  Stream<bool> isBookmarked({
    required String uid,
    required String type,
    required String itemId,
  }) {
    return _itemsRef(uid: uid, type: type)
        .doc(itemId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Adds a bookmark document (with optional metadata).
  Future<void> addBookmark({
    required String uid,
    required String type,
    required String itemId,
    Map<String, dynamic>? meta,
  }) async {
    await _itemsRef(uid: uid, type: type).doc(itemId).set({
      'createdAt': FieldValue.serverTimestamp(),
      if (meta != null) ...meta,
    });

    // Onboarding: user bookmarked a resource at least once.
    await _userService.updateOnboardingFlag(
      uid,
      'bookmarkedResource',
      true,
    );
  }

  /// Removes the bookmark document.
  Future<void> removeBookmark({
    required String uid,
    required String type,
    required String itemId,
  }) async {
    await _itemsRef(uid: uid, type: type).doc(itemId).delete();
  }

  /// Adds/removes bookmark based on current state.
  Future<void> toggleBookmark({
    required String uid,
    required String type,
    required String itemId,
    required bool currentlyBookmarked,
    Map<String, dynamic>? meta,
  }) async {
    if (currentlyBookmarked) {
      await removeBookmark(
        uid: uid,
        type: type,
        itemId: itemId,
      );
      return;
    }

    await addBookmark(
      uid: uid,
      type: type,
      itemId: itemId,
      meta: meta,
    );
  }

  /// Streams bookmarks for a given type.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookmarks({
    required String uid,
    required String type,
  }) {
    return _itemsRef(uid: uid, type: type)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}