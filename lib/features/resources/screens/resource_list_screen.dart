import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/firestore_user_service.dart';
import '../../bookmarks/services/bookmark_service.dart';
import 'resource_upload_screen.dart';
import 'resource_viewer_screen.dart';

class ResourceListScreen extends StatefulWidget {
  final String? department;
  final String? courseCode;

  const ResourceListScreen({
    super.key,
    this.department,
    this.courseCode,
  });

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _userService = FirestoreUserService();

  bool _markedBrowse = false;

  Stream<QuerySnapshot> _query() {
    Query ref = FirebaseFirestore.instance
        .collection('resources')
        .where('isActive', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (widget.department != null && widget.department!.isNotEmpty) {
      ref = ref.where('department', isEqualTo: widget.department);
    }

    if (widget.courseCode != null && widget.courseCode!.isNotEmpty) {
      ref = ref.where('courseCode', isEqualTo: widget.courseCode);
    }

    if (_selectedCategory != 'all') {
      ref = ref.where('category', isEqualTo: _selectedCategory);
    }

    return ref.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('resources.title'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ResourceUploadScreen(),
            ),
          );
        },
        child: const Icon(Icons.upload),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildFilterBar(context),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _query(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Onboarding: browse resources
                if (!_markedBrowse && _uid != null && snapshot.hasData) {
                  _markedBrowse = true;
                  _userService.updateOnboardingFlag(
                    _uid!,
                    'browsedResources',
                    true,
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title =
                  (data['title'] ?? '').toString().toLowerCase();
                  final desc =
                  (data['description'] ?? '').toString().toLowerCase();
                  final q = _searchQuery.toLowerCase();

                  return title.contains(q) || desc.contains(q);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(t.t('resources.empty')),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _ResourceCard(
                      resourceId: doc.id,
                      data: data,
                      uid: _uid,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* ───────── SEARCH ───────── */

  Widget _buildSearchBar(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        decoration: InputDecoration(
          hintText: t.t('resources.search'),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /* ───────── FILTERS ───────── */

  Widget _buildFilterBar(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _filterChip(context, 'all', t.t('common.all')),
          _filterChip(context, 'Math', t.t('categories.math')),
          _filterChip(context, 'Physics', t.t('categories.physics')),
          _filterChip(context, 'Programming', t.t('categories.programming')),
        ],
      ),
    );
  }

  Widget _filterChip(
      BuildContext context,
      String value,
      String label,
      ) {
    final selected = _selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedCategory = value);
        },
      ),
    );
  }
}

/* ───────────────── RESOURCE CARD ───────────────── */

class _ResourceCard extends StatelessWidget {
  final String resourceId;
  final Map<String, dynamic> data;
  final String? uid;

  const _ResourceCard({
    required this.resourceId,
    required this.data,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = data['title'] ?? '';
    final desc = data['description'] ?? '';
    final category = data['category'];
    final course = data['courseCode'];

    final bookmarkRef = uid == null
        ? null
        : FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc('resources')
        .collection('items')
        .doc(resourceId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 28,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (bookmarkRef != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: bookmarkRef.snapshots(),
                      builder: (context, snap) {
                        final bookmarked = snap.data?.exists == true;

                        return IconButton(
                          icon: Icon(
                            bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: colors.primary,
                          ),
                          onPressed: () async {
                            if (uid == null) return;

                            if (bookmarked) {
                              await bookmarkRef.delete();
                            } else {
                              await bookmarkRef.set({
                                'createdAt':
                                FieldValue.serverTimestamp(),
                              });

                              final bookmarkService = BookmarkService();
                              bookmarkService.toggleBookmark(
                                uid: uid!,
                                type: 'resources',
                                itemId: resourceId,
                                currentlyBookmarked: false,
                              );
                            }
                          },
                        );
                      },
                    ),
                ],
              ),
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
              Text(
                [
                  if (category != null) category,
                  if (course != null) course,
                ].join(' • '),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}