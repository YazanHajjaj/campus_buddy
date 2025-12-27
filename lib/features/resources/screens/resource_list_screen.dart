import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'resource_upload_screen.dart';
import 'resource_pdf_viewer.dart';

class ResourceListScreen extends StatefulWidget {
  const ResourceListScreen({super.key});

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  String _selectedCategory = 'All';

  Stream<QuerySnapshot> _query() {
    Query ref = FirebaseFirestore.instance
        .collection('resources')
        .where('isActive', isEqualTo: true)
        .where('isPublic', isEqualTo: true);

    if (_selectedCategory != 'All') {
      ref = ref.where('category', isEqualTo: _selectedCategory);
    }

    return ref.orderBy('createdAt', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),

      // =====================
      // UPLOAD BUTTON
      // =====================
      floatingActionButton: FloatingActionButton(
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
          // =====================
          // FILTER BAR
          // =====================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _filterChip('All'),
                _filterChip('Math'),
                _filterChip('Physics'),
                _filterChip('Programming'),
              ],
            ),
          ),

          const Divider(height: 1),

          // =====================
          // RESOURCE LIST
          // =====================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _query(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No resources found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () async {
                          // =====================
                          // VIEW COUNT
                          // =====================
                          await FirebaseFirestore.instance
                              .collection('resources')
                              .doc(doc.id)
                              .update({
                            'viewCount': FieldValue.increment(1),
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResourceDetailsScreen(
                                resource: data,
                                resourceId: doc.id,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 36),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['description'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Category: ${data['category'] ?? '—'}',
                                      style:
                                      const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Course: ${data['courseCode'] ?? '—'}',
                                      style:
                                      const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // =====================
  // FILTER CHIP
  // =====================
  Widget _filterChip(String label) {
    final bool selected = _selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = label;
          });
        },
      ),
    );
  }
}

// =======================================================
// RESOURCE DETAILS SCREEN
// =======================================================

class ResourceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> resource;
  final String resourceId;

  const ResourceDetailsScreen({
    super.key,
    required this.resource,
    required this.resourceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource['title'] ?? 'Resource'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              resource['title'] ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(resource['description'] ?? ''),
            const SizedBox(height: 12),
            Text('Category: ${resource['category']}'),
            Text('Course: ${resource['courseCode']}'),
            const SizedBox(height: 24),

            // =====================
            // OPEN PDF (TRACKED)
            // =====================
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('resources')
                    .doc(resourceId)
                    .update({
                  'openCount': FieldValue.increment(1),
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResourcePdfViewerScreen(
                      url: resource['fileUrl'],
                      title: resource['title'],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Open PDF'),
            ),
          ],
        ),
      ),
    );
  }
}