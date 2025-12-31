import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../resources/screens/resource_viewer_screen.dart';
import '../../../core/localization/app_localizations.dart';

/// Displays a list of bookmarked resources for the current user.
/// Data is read-only and synced from Firestore.
class BookmarkListScreen extends StatelessWidget {
  const BookmarkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // User must be authenticated to access bookmarks
    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Text(t.t('auth.signIn')),
        ),
      );
    }

    final bookmarksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc('resources')
        .collection('items');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('nav.bookmarks'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookmarksRef
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];

          // Empty state when user has no bookmarks
          if (docs.isEmpty) {
            return Center(
              child: Text(
                t.t('resources.noBookmarks'),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.disabledColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final bookmark = docs[index];
              final resourceId = bookmark.id;

              return _BookmarkedResourceCard(
                resourceId: resourceId,
                uid: uid,
              );
            },
          );
        },
      ),
    );
  }
}

/* ───────────────── BOOKMARKED RESOURCE CARD ───────────────── */

/// Individual bookmarked resource preview.
/// Fetches the resource document and allows quick removal.
class _BookmarkedResourceCard extends StatelessWidget {
  final String resourceId;
  final String uid;

  const _BookmarkedResourceCard({
    required this.resourceId,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resourceRef = FirebaseFirestore.instance
        .collection('resources')
        .doc(resourceId);

    final bookmarkRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc('resources')
        .collection('items')
        .doc(resourceId);

    return FutureBuilder<DocumentSnapshot>(
      future: resourceRef.get(),
      builder: (context, snap) {
        // Resource was deleted or no longer exists
        if (!snap.hasData || !snap.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snap.data!.data() as Map<String, dynamic>;

        final title = data['title'] ?? '—';
        final desc = data['description'] ?? '';
        final category = data['category'];
        final course = data['courseCode'];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResourceViewerScreen(
                  resource: {
                    ...data,
                    'id': resourceId,
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + remove bookmark action
                Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.bookmark,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () async {
                        await bookmarkRef.delete();
                      },
                    ),
                  ],
                ),

                // Optional description
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],

                const SizedBox(height: 8),

                // Metadata (category / course)
                Text(
                  [
                    if (category != null) category,
                    if (course != null) course,
                  ].join(' • '),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}